//
//  Created on 20.03.2025.
//
//  Copyright (c) 2025 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

import SwiftUI
import AVFoundation

struct QRCodeCameraView: UIViewControllerRepresentable {

    var handleQRCodeString: (String) -> Void

    /// Handle "Don't Allow" pressed when asked to allow camera use
    var handleCameraUsePermissionRequestRejection: () -> Void
    /// Handle camera not allowed to be used by this app. Can be due to rejection when prompted or turning off permissions in Settings.
    var handleCameraUseNotAllowed: () -> Void

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = QRCodeCameraViewController()
        controller.cameraPermissionsDelegate = context.coordinator
        controller.scannerDelegate = context.coordinator
        return controller
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(qrCodeHandler: handleQRCodeString, requestRejectionHandler: handleCameraUsePermissionRequestRejection, cameraNotAllowedHandler: handleCameraUseNotAllowed)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    class Coordinator: NSObject, CameraUsagePermissionsHandler, QRScannerDelegate {
        var qrCodeHandler: (String) -> Void
        var requestRejectionHandler: () -> Void
        var cameraNotAllowedHandler: () -> Void

        init(qrCodeHandler: @escaping (String) -> Void, requestRejectionHandler: @escaping () -> Void, cameraNotAllowedHandler: @escaping () -> Void) {
            self.qrCodeHandler = qrCodeHandler
            self.requestRejectionHandler = requestRejectionHandler
            self.cameraNotAllowedHandler = cameraNotAllowedHandler
        }

        func handleCameraUsePermissionRequestRejection() {
            Task { @MainActor in
                requestRejectionHandler()
            }
        }

        func handleCameraUseNotAllowed() {
            Task { @MainActor in
                cameraNotAllowedHandler()
            }
        }

        func didDetectQRCode(_ code: String) {
            Task { @MainActor in
                qrCodeHandler(code)
            }
        }
    }
}

protocol CameraUsagePermissionsHandler: AnyObject {
    func handleCameraUsePermissionRequestRejection() -> Void
    func handleCameraUseNotAllowed() -> Void
}

protocol QRScannerDelegate: AnyObject {
    func didDetectQRCode(_ code: String)
}

class QRCodeCameraViewController: UIViewController {

    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?

    weak var cameraPermissionsDelegate: CameraUsagePermissionsHandler?
    weak var scannerDelegate: QRScannerDelegate?

    // Coordinate session start and stop. Concurrent calls to start and stop session can cause crashes.
    var sessionQueue = DispatchQueue(label: "qr.session.queue", qos: .userInitiated)

    var allowMoreQRCodeNotifications: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func checkCameraPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .notDetermined:
            askForPermission()
        case .denied, .restricted:
            cameraPermissionsDelegate?.handleCameraUseNotAllowed()
        case .authorized:
            setupCamera()
        @unknown default:
            cameraPermissionsDelegate?.handleCameraUseNotAllowed()
        }
    }

    private func askForPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            Task { @MainActor [weak self] in
                if granted {
                    self?.setupCamera()
                } else {
                    self?.cameraPermissionsDelegate?.handleCameraUsePermissionRequestRejection()
                }
            }
        }
    }

    private func setupCamera() {
        guard captureSession == nil else { return }

        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            assertionFailure("Failed to access camera. Make sure the camera you are trying to access exists on this device. Use .builtInWideAngleCamera. It should always be present.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)

            guard session.canAddInput(input) else {
                assertionFailure("Error setting up the camera. Please check the code!")
                return
            }
            session.addInput(input)

            let metadataOutput = AVCaptureMetadataOutput()
            guard session.canAddOutput(metadataOutput) else {
                assertionFailure("Error setting up the camera. Please check the code!")
                return
            }

            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            preview.frame = view.bounds
            view.layer.addSublayer(preview)

            self.previewLayer = preview
            self.captureSession = session
            
            startSession()
        } catch {
            assertionFailure("Error setting up the camera. Make sure you first check if we have access to the camera!")
        }
    }

    private func startSession() {
        allowMoreQRCodeNotifications = true
        sessionQueue.async { [weak self] in
            guard let session = self?.captureSession, !session.isRunning else { return }
            session.startRunning()
        }
    }

    private func stopSession() {
        sessionQueue.async { [weak self] in
            guard let session = self?.captureSession, session.isRunning else { return }
            session.stopRunning()
        }
    }
}

extension QRCodeCameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let qrString = metadataObject.stringValue else {
#if DEBUG
            debugPrint("Could not extract the QR code string")
#endif
            return
        }

        // This function is called a multiple times for the same valid qr code. allowQRCodeNotification stops the multiple calls from being propagated.
        guard allowMoreQRCodeNotifications else {
            return
        }

        allowMoreQRCodeNotifications = false

        stopSession()
        // Vibrate the phone
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        scannerDelegate?.didDetectQRCode(qrString)
    }
}

#endif

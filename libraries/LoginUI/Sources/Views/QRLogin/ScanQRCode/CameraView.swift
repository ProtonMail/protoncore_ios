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

struct CameraView: UIViewControllerRepresentable {

    /// Handle "Don't Allow" pressed when asked to allow camera use
    var handleCameraUsePermissionRequestRejection: () -> Void
    /// Handle camera not allowed to be used by this app. Can be due to rejection when prompted or turning off permissions in Settings.
    var handleCameraUseNotAllowed: () -> Void

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = CameraViewController()
        controller.cameraPermissionsDelegate = context.coordinator
        return controller
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(requestRejectionHandler: handleCameraUsePermissionRequestRejection, cameraNotAllowedHandler: handleCameraUseNotAllowed)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    class Coordinator: NSObject, CameraUsagePermissionsHandler {
        var requestRejectionHandler: () -> Void
        var cameraNotAllowedHandler: () -> Void

        init(requestRejectionHandler: @escaping () -> Void, cameraNotAllowedHandler: @escaping () -> Void) {
            self.requestRejectionHandler = requestRejectionHandler
            self.cameraNotAllowedHandler = cameraNotAllowedHandler
        }

        func handleCameraUsePermissionRequestRejection() {
            requestRejectionHandler()
        }

        func handleCameraUseNotAllowed() {
            cameraNotAllowedHandler()
        }
    }
}

protocol CameraUsagePermissionsHandler: AnyObject {
    func handleCameraUsePermissionRequestRejection() -> Void
    func handleCameraUseNotAllowed() -> Void
}

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?

    weak var cameraPermissionsDelegate: CameraUsagePermissionsHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
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

            if session.canAddInput(input) {
                session.addInput(input)
            }

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            preview.frame = view.bounds
            view.layer.addSublayer(preview)

            self.previewLayer = preview
            self.captureSession = session
        } catch {
            assertionFailure("Error setting up the camera. Make sure you first check if we have access to the camera!")
        }
    }

    private func startSession() {
        guard let session = self.captureSession, !session.isRunning else { return }
        // startRunning needs to run on a background thread
        Task.detached(priority: .userInitiated) {
            guard !session.isRunning else { return }
            session.startRunning()
        }
    }

    private func stopSession() {
        guard let session = self.captureSession, session.isRunning else { return }
        // stopRunning needs to run on a background thread
        Task.detached(priority: .userInitiated) {
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }
}

#endif

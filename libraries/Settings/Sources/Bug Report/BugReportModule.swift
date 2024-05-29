//
//  BugReportModule.swift
//  ProtonCore-Settings - Created on 29.05.2024.
//
//  Copyright (c) 2024 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import SwiftUI
import ProtonCoreNetworking
import ProtonCoreUIFoundations
import ProtonCoreServices

#if os(iOS)
@available(iOS 15.0, *)
public typealias BugReportViewController = UIHostingController<BugReportView>

/// Useful parameters to have handy
@available(iOS 15.0, *)
public enum BugReportModule {

    /// Resource bundle for the Password Change module
    public static var resourceBundle: Bundle {
        #if SWIFT_PACKAGE
        let resourceBundle = Bundle.module
        return resourceBundle
        #else
        let podBundle = Bundle(for: BugReportClass.self)
        if let bundleURL = podBundle.url(forResource: "Resources-Settings", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            }
        }
        return podBundle
        #endif
    }

    /// Method to obtain the BugReportViewController
    @MainActor
    public static func makeBugReportViewController(
        apiService: APIService,
        username: String = "",
        email: String
    ) -> BugReportViewController {
        let viewModel = BugReportView.ViewModel(
            dependencies: .init(
                apiService: apiService,
                username: username,
                email: email
            )
        )
        let viewController = UIHostingController(rootView: BugReportView(viewModel: viewModel))
        viewController.view.backgroundColor = ColorProvider.BackgroundNorm
        Self.initialViewController = viewController
        return viewController
    }

    static weak var initialViewController: UIViewController?
}

private class BugReportClass {}
#endif

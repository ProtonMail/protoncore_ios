//
//  File.swift
//  
//
//  Created by Victor Jalencas on 14/5/24.
//

#if os(iOS)

import XCTest
@testable import ProtonCoreLoginUI
import ProtonCoreServices
#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#endif

class SecurityKeysViewSnapshotTests: SnapshotTestCase {

    let defaultPrecision: Float = 0.98

    func testSecurityKeysList() {
        let viewModel = SecurityKeysView.ViewModel()
        let keys = (1...8).map(RegisteredKey.init)
        viewModel.viewState = .loaded(keys)

        let view = SecurityKeysView(viewModel: viewModel)

        checkSnapshots(view: view,
                       perceptualPrecision: defaultPrecision)
    }

    func testSecurityKeysEmptyList() {
        let viewModel = SecurityKeysView.ViewModel()
        let keys: [RegisteredKey] = []
        viewModel.viewState = .loaded(keys)

        let view = SecurityKeysView(viewModel: viewModel)

        checkSnapshots(view: view,
                       perceptualPrecision: defaultPrecision)
    }

    func testSecurityKeysLoadingList() {
        let viewModel = SecurityKeysView.ViewModel()
        viewModel.viewState = .loading

        let view = SecurityKeysView(viewModel: viewModel)

        checkSnapshots(view: view,
                       perceptualPrecision: defaultPrecision)
    }

    func testSecurityKeysListError() {
        let viewModel = SecurityKeysView.ViewModel()
        viewModel.viewState = .error

        let view = SecurityKeysView(viewModel: viewModel)

        checkSnapshots(view: view,
                       perceptualPrecision: defaultPrecision)
    }
}

#endif

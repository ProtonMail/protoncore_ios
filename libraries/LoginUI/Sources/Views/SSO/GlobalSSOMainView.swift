//
//  GlobalSSOMainView.swift
//  ProtonCore-LoginUI - Created on 23/11/2024.
//
//  Copyright (c) 2024 Proton AG
//
//  This file is part of Proton AG and ProtonCore.
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

#if os(iOS)

import SwiftUI

struct GlobalSSOMainView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        mainView
            .navigationBarBackButtonHidden()
            .task {
                await viewModel.invokePostLoginSetup()
            }
    }

    @ViewBuilder
    var mainView: some View {
        switch viewModel.screenState {
        case .loading(let dependencies):
            SSOLoginLoaderView(viewModel: .init(dependencies: dependencies))
        case .error(let dependencies):
            SSOLoginErrorView(viewModel: .init(dependencies: dependencies))
        case .newBackupPassword(let dependencies):
            JoinOrganizationView(viewModel: .init(dependencies: dependencies))
        case .requestApproveFromAnotherDevice(let dependencies):
            SignInRequestView(viewModel: .init(dependencies: dependencies))
        case .enterBackupPassword(let dependencies):
            EnterBackupPasswordView(viewModel: .init(dependencies: dependencies))
        case .accessGrantedDenied(let dependencies):
            AccessGrantedDeniedView(viewModel: .init(dependencies: dependencies))
        }
    }
}

#endif

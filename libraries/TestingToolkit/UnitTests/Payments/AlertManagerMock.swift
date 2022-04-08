//
//  AlertManagerMock.swift
//  ProtonCore-TestingToolkit - Created on 23/12/2020.
//
//  Copyright (c) 2022 Proton Technologies AG
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

import ProtonCore_Payments

public class AlertManagerMock: AlertManagerProtocol {

    public init() {}

    @PropertyStub(\AlertManagerProtocol.title, initialGet: nil) public var titleStub
    public var title: String? { get { titleStub() } set { titleStub(newValue) } }

    @PropertyStub(\AlertManagerProtocol.message, initialGet: .empty) public var messageStub
    public var message: String { get { messageStub() } set { messageStub(newValue) } }

    @PropertyStub(\AlertManagerProtocol.confirmButtonTitle, initialGet: nil) public var confirmButtonTitleStub
    public var confirmButtonTitle: String? { get { confirmButtonTitleStub() } set { confirmButtonTitleStub(newValue) } }

    @PropertyStub(\AlertManagerProtocol.cancelButtonTitle, initialGet: nil) public var cancelButtonTitleStub
    public var cancelButtonTitle: String? { get { cancelButtonTitleStub() } set { cancelButtonTitleStub(newValue) } }

    @PropertyStub(\AlertManagerProtocol.confirmButtonStyle, initialGet: .default) public var confirmButtonStyleStub
    public var confirmButtonStyle: AlertActionStyle { get { confirmButtonStyleStub() } set { confirmButtonStyleStub(newValue) } }

    @PropertyStub(\AlertManagerProtocol.cancelButtonStyle, initialGet: .default) public var cancelButtonStyleStub
    public var cancelButtonStyle: AlertActionStyle { get { cancelButtonStyleStub() } set { cancelButtonStyleStub(newValue) } }

    @FuncStub(AlertManagerProtocol.showAlert) public var showAlertStub
    public func showAlert(confirmAction: ActionCallback, cancelAction: ActionCallback) { showAlertStub(confirmAction, cancelAction) }

}

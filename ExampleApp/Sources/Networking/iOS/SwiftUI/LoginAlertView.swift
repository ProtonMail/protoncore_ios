//
//  LoginAlertView.swift
//  ExampleApp - Created on 22/01/2021.
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

import SwiftUI

struct LoginAlertView: View {
    let screenSize = UIScreen.main.bounds
    @Binding var isShown: Bool
    @State private var userName: String = ""
    @State private var password: String = ""
    var onDone: (String, String) -> Void = { _, _  in }
    var onCancel: () -> Void = { }

    var body: some View {

        VStack(spacing: 20) {
            Text("Log in")
                .font(.headline)
            Text("Enter your credentials").fontWeight(.light)
            TextField("Login", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .autocapitalization(.none)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            HStack(spacing: 20) {
                Button(action: {
                    isShown = false
                    onCancel()
                    removeCredentials()
                }, label: {
                    Text("Cancel")
                })
                .padding(.horizontal)
                Spacer()
                Button(action: {
                    isShown = false
                    onDone(userName, password)
                    removeCredentials()
                }, label: {
                    Text("Log in").fontWeight(.bold)
                })
                .padding(.horizontal)
            }
        }
        .padding()
        .frame(width: screenSize.width * 0.7, height: screenSize.height * 0.3)
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
        .offset(y: isShown ? 0 : screenSize.height)
        .animation(.spring())
    }

    func removeCredentials() {
        userName = ""
        password = ""
        UIApplication.shared.endEditing()
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        LoginAlertView(isShown: .constant(true))
    }
}

// extension for keyboard to dismiss
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

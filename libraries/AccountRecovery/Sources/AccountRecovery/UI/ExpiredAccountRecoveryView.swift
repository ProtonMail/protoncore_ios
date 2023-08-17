//
//  ExpiredAccountRecoveryView.swift
//  Pods - Created on 13/7/23.
//
//  Copyright (c) 2023 Proton AG
//
//  This file is part of ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import SwiftUI

public struct ExpiredAccountRecoveryView: View {
    public var body: some View {
        VStack(spacing: 24) {
            Text("The account recovery process expired due to inaction ")
        }
        .padding(16)
        .navigationTitle("Recovery process cancelled")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExpiredAccountRecoveryView_Previews: PreviewProvider {
    static var previews: some View {
        ExpiredAccountRecoveryView()
    }
}

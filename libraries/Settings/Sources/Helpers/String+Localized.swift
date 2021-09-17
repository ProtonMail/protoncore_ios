//
//  String+Localized.swift
//  ProtonCore-Settings - Created on 23.10.2020.
//
//  Copyright (c) 2019 Proton Technologies AG
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

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: PMSettings.bundle, comment: "Localized string for key: \(self) in PMSettings bundle")
    }

    func localized(in bundle: Bundle) -> String {
        NSLocalizedString(self, bundle: bundle, comment: "Localized string for key: \(self) in bundle \(bundle)")
    }
}
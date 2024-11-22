//
//  LocalizationProvider.swift
//  ProtonCoreUI - Created on 7/11/2024.
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

public protocol LocalizationProvider: CaseIterable {
    var l10n: String { get }

    static var bundle: Bundle { get }
    static var prefixForMissingValue: String { get set }
}

public extension LocalizationProvider {

    func localize(key: String,
                  defaultValue value: String? = nil,
                  comment: String) -> String {
        guard let defaultValue = value else {
            return NSLocalizedString(key, bundle: Self.bundle, value: "\(Self.prefixForMissingValue)\(key)", comment: comment)
        }

        return NSLocalizedString(key, bundle: Self.bundle, value: "\(Self.prefixForMissingValue)\(defaultValue)", comment: comment)
    }

    func localizeWithInterpolation<T: CVarArg>(key: String,
                                               defaultValue value: String? = nil,
                                               interpolationValue: T,
                                               comment: String) -> String {

        String(format: localize(key: key, comment: comment), interpolationValue)
    }
}

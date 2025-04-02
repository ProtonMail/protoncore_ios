//
//  PMUIFoundations.swift
//  ProtonCore-UIFoundations - Created on 09.06.20.
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

import Foundation

fileprivate func isResourceBundlePath(_ path: String) -> Bool {
    /*
     * https://developer.apple.com/documentation/swift/fileid()
     * "The unique identifier has the form `module/file`, where `file` is the name of the file in which the expression
     *  appears and `module` is the name of the module that this file is part of."
     */
    let name = #fileID.components(separatedBy: "/").first!
    return path.hasSuffix("\(name).bundle")
}

public let spmResourcesBundle: Bundle = {
#if DEBUG
    if let testBundlePath = ProcessInfo.processInfo.environment["XCTestBundlePath"],
       let paths = Bundle(path: testBundlePath)?.paths(forResourcesOfType: "bundle", inDirectory: nil),
       let resourceBundlePath = paths.first(where: isResourceBundlePath),
       let resourceBundle = Bundle(path: resourceBundlePath) {
        return resourceBundle
    }
#endif
    return Bundle.module
}()

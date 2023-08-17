//
//  main.swift
//  ProtonCore-ObfuscatedConstants - Created on 06.07.23.
//
//  Copyright (c) 2023 Proton Technologies AG
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
import PackagePlugin

@main
struct GenerateObfuscatedConstants: CommandPlugin {
        
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        guard let obfuscated = context.package.targets.first(where: { $0.name == "ProtonCore-ObfuscatedConstants" })
        else { return }

        let scriptPath = obfuscated.directory.appending(["..", "Scripts", "create_obfuscated_constants.sh"])

        let process = Process()
        let bashPath = "/bin/bash"
        if #available(macOS 13.0, *) {
            process.executableURL = URL(filePath: bashPath)
        } else {
            process.executableURL = URL(fileURLWithPath: bashPath)
        }

        process.arguments = [
            scriptPath.string
        ]

        try process.run()
        process.waitUntilExit()
    }
}

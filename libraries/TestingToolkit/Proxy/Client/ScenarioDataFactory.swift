//
//  ScenarioDataFactory.swift
//  ProtonCore-Performance - Created on 12.09.2024.
//
// Copyright (c) 2023. Proton Technologies AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import Foundation

public class ScenarioDataFactory {

    public static func readScenarioFile(filename: String, subdirectory: String, bundle: Bundle) throws -> ScenarioFileWithName {

        guard let data = bundle.getDataFor(fileName: filename, subdirectory: subdirectory) else {
            throw ScenarioDataError.missingFile("Missing scenario file: \(filename) in folder: \(subdirectory)")
        }

        do {
            let scenarioFile = try JSONDecoder().decode(ScenarioFile.self, from: data)

            guard !scenarioFile.mockFiles.isEmpty else {
                throw ScenarioDataError.jsonParsingError("Scenario file validation failed: 'mockFiles' cannot be empty.")
            }

            return ScenarioFileWithName(name: filename, directory: subdirectory, scenarioFile: scenarioFile)

        } catch {
            throw ScenarioDataError.jsonParsingError("Failed to read or parse scenario file: \(error.localizedDescription)")
        }
    }

    public static func parseScenarioFile(from scenarioFileWithName: ScenarioFileWithName, bundle: Bundle) throws -> [MockObject] {
        var parsedMockRoutes: [MockObject] = []

        for mockFile in scenarioFileWithName.scenarioFile.mockFiles {
            guard let data = bundle.getDataFor(fileName: mockFile, subdirectory: scenarioFileWithName.directory) else {
                throw ScenarioDataError.missingFile("Missing mock file: \(mockFile) in folder: \(scenarioFileWithName.directory)")
            }

            do {
                // Ensure that we add the 'name' field and enabled to the mock data before decoding
                var jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
                jsonObject["name"] = "\(scenarioFileWithName.name)-\(mockFile)"
                jsonObject["enabled"] = true
                let updatedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                let generatedMock = try JSONDecoder().decode(MockObject.self, from: updatedData)

                try generatedMock.request.validate()

                parsedMockRoutes.append(
                    MockObject(
                        name: generatedMock.name,
                        enabled: generatedMock.enabled,
                        updateFile: generatedMock.updateFile,
                        request: generatedMock.request,
                        response: generatedMock.response
                    )
                )
            } catch {
                throw ScenarioDataError.jsonParsingError("Failed to read or parse mock file '\(mockFile)': \(error.localizedDescription)")
            }
        }

        return parsedMockRoutes
    }
}

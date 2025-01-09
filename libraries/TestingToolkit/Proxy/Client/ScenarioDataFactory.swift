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
            if let fileURL = bundle.url(forResource: mockFile, withExtension: nil) {
                var isDirectory: ObjCBool = false

                if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
                    // Treat as a folder
                    let folderRoutes = try processDirectory(directory: mockFile, scenarioFileWithName: scenarioFileWithName, bundle: bundle)
                    parsedMockRoutes.append(contentsOf: folderRoutes)
                } else {
                    // Treat as a single file
                    guard let mock = try processFile(fileURL: fileURL, directory: scenarioFileWithName.directory, scenarioName: scenarioFileWithName.name, bundle: bundle) else {
                        throw ScenarioDataError.missingFile("Missing mock file: \(mockFile) in folder: \(scenarioFileWithName.directory)")
                    }
                    parsedMockRoutes.append(mock)
                }
            } else {
                throw ScenarioDataError.missingFile("Missing resource: \(mockFile) in bundle")
            }
        }

        return parsedMockRoutes
    }

    private static func processFile(fileURL: URL, directory: String, scenarioName: String, bundle: Bundle) throws -> MockObject? {
        guard fileURL.pathExtension == "json",
              let data = bundle.getDataFor(fileName: fileURL.lastPathComponent, subdirectory: directory) else {
            return nil
        }

        var jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]

        // "name" cannot be null
        if jsonObject["name"] == nil {
            let relativePath = fileURL.path.replacingOccurrences(of: bundle.bundlePath, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            jsonObject["name"] = "\(scenarioName)-\(relativePath)"
        }
        jsonObject["enabled"] = true

        let updatedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        let generatedMock = try JSONDecoder().decode(MockObject.self, from: updatedData)
        try generatedMock.request.validate()

        return MockObject(
            name: generatedMock.name,
            enabled: generatedMock.enabled,
            updateFile: generatedMock.updateFile,
            request: generatedMock.request,
            response: generatedMock.response
        )
    }


    private static func processDirectory(directory: String, scenarioFileWithName: ScenarioFileWithName, bundle: Bundle) throws -> [MockObject] {
        guard let directoryURL = bundle.url(forResource: directory, withExtension: nil) else {
            throw ScenarioDataError.missingFile("Missing directory: \(directory)")
        }

        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        var mockRoutes: [MockObject] = []

        for fileURL in contents {
            if fileURL.hasDirectoryPath {
                let subdirectoryPath = "\(directory)/\(fileURL.lastPathComponent)"
                let subdirectoryRoutes = try processDirectory(directory: subdirectoryPath, scenarioFileWithName: scenarioFileWithName, bundle: bundle)
                mockRoutes.append(contentsOf: subdirectoryRoutes)
            } else if let mock = try processFile(fileURL: fileURL, directory: directory, scenarioName: scenarioFileWithName.name, bundle: bundle) {
                mockRoutes.append(mock)
            }
        }

        return mockRoutes
    }
}

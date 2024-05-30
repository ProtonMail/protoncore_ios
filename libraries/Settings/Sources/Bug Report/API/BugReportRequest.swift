//
//  BugReportRequest.swift
//  ProtonCore-Settings - Created on 28.05.2024.
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
import ProtonCoreDataModel
import ProtonCoreNetworking

/// Reports API
///
/// Documentation: https://protonmail.gitlab-pages.protontech.ch/Slim-API/core/#tag/Reports
struct ReportsAPI {
    static let Path: String = "/reports"
}

/// Report a bug
///
/// Documentation: https://protonmail.gitlab-pages.protontech.ch/Slim-API/core/#tag/Reports/operation/post_core-%7B_version%7D-reports-bug
final class BugReportRequest: Request {
    let bugReport: BugReport

    init(bugReport: BugReport) {
        self.bugReport = bugReport
    }

    var parameters: [String: Any]? {
        return [
            "OS": bugReport.os,
            "OSVersion": bugReport.osVersion,
            "Client": bugReport.client,
            "ClientVersion": bugReport.clientVersion,
            "Title": bugReport.title,
            "Description": bugReport.description,
            "Username": bugReport.username,
            "Email": bugReport.email,
        ]
    }

    var method: HTTPMethod { .post }
    var path: String {
        ReportsAPI.Path + "/bug"
    }
}

struct BugReport {
    var os: String
    var osVersion: String
    var client: String
    var clientVersion: String
    var title: String
    var description: String
    var username: String
    var email: String

    init(
        os: String,
        osVersion: String,
        client: String,
        clientVersion: String,
        title: String,
        description: String,
        username: String,
        email: String
    ) {
        self.os = os
        self.osVersion = osVersion
        self.client = client
        self.clientVersion = clientVersion
        self.title = title
        self.description = description
        self.username = username
        self.email = email
    }

}

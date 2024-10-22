//
//  EmailBuilder.swift
//  ProtonCore-QuarkCommands - Created on 15.10.2024.
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
import Yams

public enum MimeType: String, Codable {
    case html = "text/html"
    case plainText = "text/plain"
    case xlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case zip = "application/zip"
    case png = "image/png"
    case jpg = "image/jpg"
    case pdf = "application/pdf"
    case ics = "text/calendar"
}

public struct Attachment: Codable {
    public let filename: String
    public let content: String
    public let contentType: MimeType
    
    public init(filename: String, content: String, contentType: MimeType) {
        self.filename = filename
        self.content = content
        self.contentType = contentType
    }
    
    private enum CodingKeys: String, CodingKey {
        case filename = "filename"
        case content = "content"
        case contentType = "contentType"
    }
}

public class EmailOptions: Codable {
    public var from: String?
    public var to: String
    public var subject: String
    public var text: String?
    public var html: String?
    public var date: String?
    public var labels: String?
    public var plainTextEml: String?
    public var subscription: String?
    public var cc: String?
    public var bcc: String?
    public var mimeType: MimeType?
    public var attachments: [Attachment]?
    public var path: String?
    
    public init(
        from: String? = "",
        to: String = "",
        subject: String = "",
        text: String? = nil,
        html: String? = nil,
        date: String? = nil,
        labels: String? = nil,
        plainTextEml: String? = nil,
        subscription: String? = nil,
        cc: String? = nil,
        bcc: String? = nil,
        mimeType: MimeType? = .plainText,
        attachments: [Attachment]? = nil,
        path: String = String(UUID().uuidString.prefix(8)) + ".eml"
        
    ) {
        self.from = from
        self.to = to
        self.subject = subject
        self.text = text
        self.html = html
        self.date = date
        self.labels = labels
        self.plainTextEml = plainTextEml
        self.subscription = subscription
        self.cc = cc
        self.bcc = bcc
        self.mimeType = mimeType
        self.attachments = attachments
        self.path = path
    }
    
    private enum CodingKeys: String, CodingKey {
        case from = "from"
        case to = "to"
        case subject = "subject"
        case text = "text"
        case html = "html"
        case date = "date"
        case labels = "labels"
        case plainTextEml = "plainTextEml"
        case subscription = "subscription"
        case cc = "cc"
        case bcc = "bcc"
        case mimeType = "mimeType"
        case attachments = "attachments"
    }
}

// EmailBuilder class to generate RFC 2822 compliant email
public class EmailBuilder {
    public var options: EmailOptions
    
    public init(options: EmailOptions) {
        self.options = options
    }
    
    public func generateRFC2822() -> String {
        let from = options.from ?? "unknown@domain.com"  // Unwrap optional values
        let date = options.date ?? "Unknown Date"        // If date is optional, provide a fallback
        
        var emailContent = "From: \(from)\r\n"
        emailContent += "To: \(options.to)\r\n"
        emailContent += "Subject: \(options.subject)\r\n"
        emailContent += "Date: \(date)\r\n"
        emailContent += "MIME-Version: 1.0\r\n"
        
        if let htmlBody = options.html {
            emailContent += "Content-Type: text/html; charset=UTF-8\r\n\r\n"
            emailContent += "\(htmlBody)\r\n"
        } else if let textBody = options.text {
            emailContent += "Content-Type: text/plain; charset=UTF-8\r\n\r\n"
            emailContent += "\(textBody)\r\n"
        }
        
        return emailContent
    }
}

//
//  UIFoundationsHelpItem.swift
//  Showcase
//
//  Created by Igor Kulman on 16.12.2020.
//

import Foundation
import UIKit

enum UIFoundationsHelpItem: CaseIterable {
    case forgotUsername
    case forgotPassword
    case otherIssues
    case support
}

extension UIFoundationsHelpItem: CustomStringConvertible {
    var description: String {
        switch self {
        case .forgotUsername:
            return "Forgot username"
        case .forgotPassword:
            return "Forgot password"
        case .otherIssues:
            return "Other issues"
        case .support:
            return "Support"
        }
    }
}

extension UIFoundationsHelpItem {
    var icon: UIImage {
        switch self {
        case .forgotUsername:
            return UIImage(named: "ForgotUsernameIcon")!
        case .forgotPassword:
            return UIImage(named: "ForgotPasswordIcon")!
        case .otherIssues:
            return UIImage(named: "OtherIssuesIcon")!
        case .support:
            return UIImage(named: "SupportIcon")!
        }
    }
}

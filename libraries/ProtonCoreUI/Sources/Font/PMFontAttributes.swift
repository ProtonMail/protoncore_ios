//
//  PMFontAttributes.swift
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

#if os(iOS)

import UIKit

/// When needing customization, this typealias can make life easier to access the attributes.
public typealias PMFontAttributes = [NSAttributedString.Key: Any]

/// Sample usage:
/// `let str = NSAttributedString(string: "your string", attributes: .Headline )`
///
/// ```
/// let attributes = PMFontAttributes.Headline
/// attributes.alignment = .center
/// let str = NSAttributedString(string: "your string", attributes: attributes )
/// ```
///
/// Then, `label.attributedText = str`
extension Dictionary where Key == NSAttributedString.Key, Value: Any {

    // MARK: Headline
    public static var headline: [NSAttributedString.Key: Any] {
        let font = UIFont.boldSystemFont(ofSize: 22)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.07

        let foregroundColor: UIColor = Theme.color.textNorm
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: 0.35,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var headlineHint: [NSAttributedString.Key: Any] {
        let font = UIFont.boldSystemFont(ofSize: 22)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.07

        let foregroundColor: UIColor = Theme.color.textWeak
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: 0.35,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var headlineSmall: [NSAttributedString.Key: Any] {
        return headlineSmall(color: Theme.color.textNorm)
    }

    public static var headlineWelcomeSmall: [NSAttributedString.Key: Any] {
        return headlineSmall(color: Theme.color.white)
    }

    static func headlineSmall(color: UIColor) -> [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18

        let foregroundColor: UIColor = Theme.color.white
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.41,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    // MARK: Default

    public static var defaultStrong: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18

        let foregroundColor: UIColor = Theme.color.textNorm
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.41,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var `default`: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 17)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18

        let foregroundColor: UIColor = Theme.color.textNorm
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.41,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var defaultWeak: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 17)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18

        let foregroundColor: UIColor = Theme.color.textWeak
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.41,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var defaultHint: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 17)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18

        let foregroundColor: UIColor = Theme.color.textHint
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.41,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var defaultDisabled: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 17)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18

        let foregroundColor: UIColor = Theme.color.textDisabled
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.41,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var defaultInverted: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 17)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18

        let foregroundColor: UIColor = Theme.color.textInverted
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.41,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    // MARK: DefaultSmall

    public static var defaultSmallStrong: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.12

        let foregroundColor: UIColor = Theme.color.textNorm
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.24,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var defaultSmall: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 15)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.12

        let foregroundColor: UIColor = Theme.color.textNorm
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.24,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var defaultSmallWeek: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 15)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.12

        let foregroundColor: UIColor = Theme.color.textWeak
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.24,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var defaultSmallDisabled: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 15)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.12

        let foregroundColor: UIColor = Theme.color.textDisabled
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.24,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var defaultSmallInverted: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 15)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.12

        let foregroundColor: UIColor = Theme.color.textInverted
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.24,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    // MARK: Caption

    public static var captionStrong: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.03

        let foregroundColor: UIColor = Theme.color.textNorm
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.08,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var caption: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 13)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.03

        let foregroundColor: UIColor = Theme.color.textNorm
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.08,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var captionWeak: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 13)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.03

        let foregroundColor: UIColor = Theme.color.textWeak
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.08,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    public static var captionHint: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 13)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.03

        let foregroundColor: UIColor = Theme.color.textHint
        let attributes: [NSAttributedString.Key: Any] = [
            .kern: -0.08,
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]
        return attributes
    }

    // MARK: Helper

    public var paragraphStyle: NSParagraphStyle? {
        self[.paragraphStyle] as? NSParagraphStyle
    }

    public var mutableParagraphStyle: NSMutableParagraphStyle? {
        paragraphStyle?.mutableCopy() as? NSMutableParagraphStyle
    }

    public var alignment: NSTextAlignment? {
        get { paragraphStyle?.alignment }
        set( value ) {
            let paragraphStyle = mutableParagraphStyle ?? NSMutableParagraphStyle()
            paragraphStyle.alignment = value ?? .natural
            self[.paragraphStyle] = paragraphStyle as? Value
        }
    }

    public var lineHeightMultiple: CGFloat? {
        get { paragraphStyle?.lineHeightMultiple }
        set( value ) {
            let paragraphStyle = mutableParagraphStyle ?? NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = value ?? 1.0
            self[.paragraphStyle] = paragraphStyle as? Value
        }
    }

    public var foregroundColor: UIColor? {
        get { self[.foregroundColor] as? UIColor }
        set( color ) { self[.foregroundColor] = color as? Value }
    }
}

#endif

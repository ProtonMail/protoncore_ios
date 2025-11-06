//
//  SystemHelpers.swift
//  ProtonCore
//
//  Created by Tiziano Bruni on 03/11/2025.
//

#if os(macOS)
        import AppKit
#elseif os(iOS)
        import UIKit
#endif

public struct SystemHelpers {
    static var currentOS: String {
#if os(macOS)
        return ProcessInfo.processInfo.operatingSystemVersionString
#elseif os(iOS)
        return UIDevice.current.systemVersion
#endif
    }
}

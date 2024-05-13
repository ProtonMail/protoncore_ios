//
//  File.swift
//  
//
//  Created by Victor Jalencas on 8/5/24.
//

import Foundation

public enum LoginUIModule {
    /// Resource bundle for the LoginUI module
    public static var resourceBundle: Bundle {
        #if SWIFT_PACKAGE
        let resourceBundle = Bundle.module
        return resourceBundle
        #else
        let podBundle = Bundle(for: Choose2FAView.self)
        if let bundleURL = podBundle.url(forResource: "Resources-LoginUI", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            }
        }
        return podBundle
        #endif
    }
}

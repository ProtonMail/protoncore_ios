//
//  UiElements+iOSExtension.swift
//  pmtest
//
//  Created by Robert Patchett on 11.10.22.
//

import XCTest

extension UiElement {

    @discardableResult
    public func typeText(_ text: String) -> UiElement {
        uiElement()!.typeText(text)
        return self
    }
}

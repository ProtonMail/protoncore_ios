//
//  FeatureFactory.swift
//  ProtonCore-FeatureSwitch - Created on 9/20/22.
//
//  Copyright (c) 2022 Proton Technologies AG
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
//

public class FeatureFactory {
    internal init() { }
    public static let shared = FeatureFactory()

    
    /// this list will override the static features
    internal var currentFeatures: [Feature] = []
    
    public func getCurrentFeatures() -> [Feature] {
        return self.currentFeatures
    }
    
    public func setCurrentFeatures(features: [Feature]) {
        // for feature in features {
        //  //TODO:: loop inputs. and release the exsiting one in currentFeature
        // }
    }
    
    func clear() {
        currentFeatures.removeAll()
    }
    
    /// pass in the environment
    public func setup(env: String) {
        
    }
    
    public func fetchFeature(local: FeatureProvider) {
        
    }
    
    public func fetchFeature(remote: FeatureProvider) {
        
    }
    
    public func isEnabled(_ feature: Feature) -> Bool {
        var isEnabled: Bool = feature.isEnable
        if feature.featureFlags.contains(.availableCoreInternal) {
            if isCoreInternal() {
                isEnabled = feature.isEnable
            } else {
                return false
            }
        } else if feature.featureFlags.contains(.availableInternal) {
            if isInternal () {
                isEnabled = feature.isEnable
            } else {
                return false
            }
        } else {
            // check if need overried by local config
            if feature.featureFlags.contains(.localOverride) {
                
            }
            // check if need overried by remote config
            if feature.featureFlags.contains(.remoteOverride) {
                
            }
        }
        return isEnabled
    }
    
    public func setEnabled(_ feature: inout Feature, isEnable: Bool) {
        if isEnable {
            self.enable(&feature)
        } else {
            self.disable(&feature)
        }
    }
    
    ///
    public func enable(_ feature: inout Feature) {
        if feature.featureFlags.contains(.availableCoreInternal) {
            if isCoreInternal() {
                feature.isEnable = true
            }
        } else if feature.featureFlags.contains(.availableInternal) {
            if isInternal () {
                feature.isEnable = true
            }
        } else {
            feature.isEnable = true
            // check if need overried by local config
            if feature.featureFlags.contains(.localOverride) {

            }
            // check if need overried by remote config
            if feature.featureFlags.contains(.remoteOverride) {

            }
        }
    }

    ///
    public func disable(_ feature: inout Feature) {
        if feature.featureFlags.contains(.availableCoreInternal) {
            if isCoreInternal() {
                feature.isEnable = false
            }
        } else if feature.featureFlags.contains(.availableInternal) {
            if isInternal () {
                feature.isEnable = false
            }
        } else {
            feature.isEnable = false
            // check if need overried by local config
            if feature.featureFlags.contains(.localOverride) {

            }
            // check if need overried by remote config
            if feature.featureFlags.contains(.remoteOverride) {

            }
        }
    }
    
    /// macro environment check
    func isCoreInternal() -> Bool {
        #if DEBUG_CORE_INTERNALS
        return true
        #endif
        return false
    }
    
    /// macro environment check
    func isInternal() -> Bool {
        #if DEBUG_INTERNALS
        return true
        #endif
        return false
    }
}

// feature external wrap up the FeatureFactory isEnabled. try to avoid using this.
extension Feature {
    var isEnabled: Bool {
        FeatureFactory.shared.isEnabled(self)
    }
    
    mutating func enable() {
        FeatureFactory.shared.enable(&self)
    }
    
    mutating func disable() {
        FeatureFactory.shared.disable(&self)
    }
}

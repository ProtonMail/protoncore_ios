//
//  Created on 15/7/23.
//
//  Copyright (c) 2023 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

extension String {
    var l7d: String { NSLocalizedString(self,
                                        // TODO: use Bundle.module here when SPM
                                        bundle: AccountRecoveryModule.resourceBundle ?? Bundle.main,
                                        comment: self)
    }
}

enum LocalizedStrings {
    static let settingsItem = "Account_Recovery_Settings_Item".l7d
    static let insecureViewTitle = "Account_Recovery_Insecure_View_Title".l7d
    static let graceViewTitle = "Account_Recovery_Grace_View_Title".l7d
    static let graceViewLine1 = "Account_Recovery_Grace_View_line1".l7d
    static let insecureViewLine1 = "Account_Recovery_Insecure_View_line1".l7d
    static let insecureViewLine2  = "Account_Recovery_Insecure_View_line2".l7d
    static let insecureViewLine3 = "Account_Recovery_Insecure_View_line3".l7d
    static let graceViewCancelButtonCTA = "Account_Recovery_Grace_View_Cancel_Button_CTA".l7d
    static let graceViewUndefinedTimeLeft = "Account_Recovery_Grace_View_Undefined_Time_Left".l7d
    static let graceViewLine2 = "Account_Recovery_Grace_View_line2".l7d
    static let graceViewLine3 = "Account_Recovery_Grace_View_line3".l7d

}

//
//  WarningEmittingDefaultSubspec.swift
//  ProtonCore-WarningEmittingDefaultSubspec - Created on 23.04.21.
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

/*

  If you see a warning here, it means that you need to update your Podfile 
  to explicitly state on which subspec of the given module your project depends on.

  For example, if you have:

  pod 'ProtonCore-Networking'

  it means that you haven't specified whether you want to use the Alamofire or AFNetworking 
  as the underlying networking engine. Update your Podfile to something like:

  pod 'ProtonCore-Networking/Alamofire'

  In case you're not sure which subspecs are available for the particular module 
  or which one should be used, please consult the iOS core team member — #core-ios on Slack.

*/
#if DEBUG
#error("Compiling empty file indicates a wrong Podfile configuration")
#else
#warning("Compiling empty file indicates a wrong Podfile configuration")
#endif

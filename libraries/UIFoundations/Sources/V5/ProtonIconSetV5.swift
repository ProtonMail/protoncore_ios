//
//  ProtonIconSet.swift
//  ProtonCore-UIFoundations - Created on 08.02.22.
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

public struct ProtonIconSet {
    static let instance = ProtonIconSet()

    private init() {}
    
    // Old icons — to be removed after discussing thew replacements with designers
    @available(*, deprecated, message: "This icon will be replaced, don't use it")
    public let minus = ProtonIcon(name: "ic-minus")
    
    @available(*, deprecated, message: "This icon will be replaced, don't use it")
    public let signIn = ProtonIcon(name: "ic-sign-in")
    
    // Apple-specific icons — to be removed after discussing thew replacements with designers
    
    @available(*, deprecated, message: "This icon could be replaced, don't use it")
    public let faceId = ProtonIcon(name: "ic-face-id")
    
    @available(*, deprecated, message: "This icon could be replaced, don't use it")
    public let touchId = ProtonIcon(name: "ic-touch-id")
    
    // Proton icon set V5
    
    public let archiveBox = ProtonIcon(name: "ic-Archive-box")

    public let arrowDownArrowUp = ProtonIcon(name: "ic-Arrow-down-arrow-up")

    public let arrowDownCircleFilled = ProtonIcon(name: "ic-Arrow-down-circle-filled")

    public let arrowDownCircle = ProtonIcon(name: "ic-Arrow-down-circle")

    public let arrowDownLine = ProtonIcon(name: "ic-Arrow-down-line")

    public let arrowDown = ProtonIcon(name: "ic-Arrow-down")

    public let arrowLeft = ProtonIcon(name: "ic-Arrow-left")

    public let arrowOutFromRectangle = ProtonIcon(name: "ic-Arrow-out-from-rectangle")

    public let arrowOutSquare = ProtonIcon(name: "ic-Arrow-out-square")

    public let arrowRight = ProtonIcon(name: "ic-Arrow-right")

    public let arrowRotateRight = ProtonIcon(name: "ic-Arrow-rotate-right")

    public let arrowUpAndLeft = ProtonIcon(name: "ic-Arrow-up-and-left")

    public let arrowUpBigLine = ProtonIcon(name: "ic-Arrow-up-big-line")

    public let arrowUpFromSquare = ProtonIcon(name: "ic-Arrow-up-from-square")

    public let arrowUpLeft = ProtonIcon(name: "ic-Arrow-up-left")

    public let arrowUpLine = ProtonIcon(name: "ic-Arrow-up-line")

    public let arrowUp = ProtonIcon(name: "ic-Arrow-up")

    public let arrowsCross = ProtonIcon(name: "ic-Arrows-cross")

    public let arrowsFromCenter = ProtonIcon(name: "ic-Arrows-from-center")

    public let arrowsLeftRight = ProtonIcon(name: "ic-Arrows-left-right")

    public let arrowsRotate = ProtonIcon(name: "ic-Arrows-rotate")

    public let arrowsSwitch = ProtonIcon(name: "ic-Arrows-switch")

    public let arrowsToCenter = ProtonIcon(name: "ic-Arrows-to-center")

    public let arrowsUpAndLeft = ProtonIcon(name: "ic-Arrows-up-and-left")

    public let at = ProtonIcon(name: "ic-At")

    public let bell = ProtonIcon(name: "ic-Bell")

    public let brandAndroid = ProtonIcon(name: "ic-Brand-android")

    public let brandApple = ProtonIcon(name: "ic-Brand-apple")

    public let brandLinux = ProtonIcon(name: "ic-Brand-linux")

    public let brandPaypal = ProtonIcon(name: "ic-Brand-paypal")

    public let brandProtonVpn = ProtonIcon(name: "ic-Brand-proton-vpn")

    public let brandWindows = ProtonIcon(name: "ic-Brand-windows")

    public let brandWireguard = ProtonIcon(name: "ic-Brand-wireguard")

    public let broom = ProtonIcon(name: "ic-Broom")

    public let bug = ProtonIcon(name: "ic-Bug")

    public let buildings = ProtonIcon(name: "ic-Buildings")

    public let calendarCells = ProtonIcon(name: "ic-Calendar-cells")

    public let calendarCheckmark = ProtonIcon(name: "ic-Calendar-checkmark")

    public let calendarGrid = ProtonIcon(name: "ic-Calendar-grid")

    public let calendarRow = ProtonIcon(name: "ic-Calendar-row")

    public let calendarToday = ProtonIcon(name: "ic-Calendar-today")

    public let camera = ProtonIcon(name: "ic-Camera")

    public let cardIdentity = ProtonIcon(name: "ic-Card-identity")

    public let checkCircleFull = ProtonIcon(name: "ic-Check-circle-full")

    public let checkmarkCircle = ProtonIcon(name: "ic-Checkmark-circle")

    public let checkmark = ProtonIcon(name: "ic-Checkmark")

    public let chevronDown = ProtonIcon(name: "ic-Chevron_down")

    public let chevronLeft = ProtonIcon(name: "ic-Chevron_left")

    public let chevronRight = ProtonIcon(name: "ic-Chevron_right")

    public let chevronUp = ProtonIcon(name: "ic-Chevron_up")

    public let chevronDownFilled = ProtonIcon(name: "ic-Chevron-down-filled")

    public let chevronLeftFilled = ProtonIcon(name: "ic-Chevron-left-filled")

    public let chevronRightFilled = ProtonIcon(name: "ic-Chevron-right-filled")

    public let chevronUpFilled = ProtonIcon(name: "ic-Chevron-up-filled")

    public let circleFilled = ProtonIcon(name: "ic-Circle-filled")

    public let circleHalfFilled = ProtonIcon(name: "ic-Circle-half-filled")

    public let circleSlash = ProtonIcon(name: "ic-Circle-slash")

    public let circle = ProtonIcon(name: "ic-Circle")

    public let clockRotateLeft = ProtonIcon(name: "ic-Clock-rotate-left")

    public let clock = ProtonIcon(name: "ic-Clock")

    public let cloud = ProtonIcon(name: "ic-Cloud")

    public let code = ProtonIcon(name: "ic-Code")

    public let cogWheel = ProtonIcon(name: "ic-Cog-wheel")

    public let creditCard = ProtonIcon(name: "ic-Credit-card")

    public let crossSmall = ProtonIcon(name: "ic-Cross_small")

    public let crossCircleFilled = ProtonIcon(name: "ic-Cross-circle-filled")

    public let crossCircle = ProtonIcon(name: "ic-Cross-circle")

    public let crossTiny = ProtonIcon(name: "ic-Cross-tiny")

    public let cross = ProtonIcon(name: "ic-Cross")

    public let drive = ProtonIcon(name: "ic-Drive")

    public let earth = ProtonIcon(name: "ic-Earth")

    public let envelopeArrowUpAndRight = ProtonIcon(name: "ic-Envelope-arrow-up-and-right")
    
    public let envelopeCross = ProtonIcon(name: "ic-Envelope-cross")

    public let envelopeDot = ProtonIcon(name: "ic-Envelope-dot")

    public let envelopeOpenText = ProtonIcon(name: "ic-Envelope-open-text")

    public let envelopeOpen = ProtonIcon(name: "ic-Envelope-open")

    public let envelope = ProtonIcon(name: "ic-Envelope")

    public let envelopes = ProtonIcon(name: "ic-Envelopes")

    public let eraser = ProtonIcon(name: "ic-Eraser")

    public let exclamationCircleFilled = ProtonIcon(name: "ic-Exclamation-circle-filled")

    public let exclamationCircle = ProtonIcon(name: "ic-Exclamation-circle")

    public let eyeSlash = ProtonIcon(name: "ic-Eye-slash")

    public let eye = ProtonIcon(name: "ic-Eye")

    public let fileArrowInUp = ProtonIcon(name: "ic-File-arrow-in-up")

    public let fileArrowIn = ProtonIcon(name: "ic-File-arrow-in")

    public let fileArrowOut = ProtonIcon(name: "ic-File-arrow-out")

    public let fileImage = ProtonIcon(name: "ic-File-image")

    public let file = ProtonIcon(name: "ic-File")

    public let fillingCabinet = ProtonIcon(name: "ic-Filling-cabinet")

    public let filter = ProtonIcon(name: "ic-Filter")

    public let fireSlash = ProtonIcon(name: "ic-Fire-slash")

    public let fire = ProtonIcon(name: "ic-Fire")

    public let folderArrowInFilled = ProtonIcon(name: "ic-Folder-arrow-in-filled")

    public let folderArrowIn = ProtonIcon(name: "ic-Folder-arrow-in")

    public let folderFilled = ProtonIcon(name: "ic-Folder-filled")

    public let folderOpenFilled = ProtonIcon(name: "ic-Folder-open-filled")

    public let folderOpen = ProtonIcon(name: "ic-Folder-open")

    public let folderPlus = ProtonIcon(name: "ic-Folder-plus")

    public let folder = ProtonIcon(name: "ic-Folder")

    public let foldersFilled = ProtonIcon(name: "ic-Folders-filled")

    public let folders = ProtonIcon(name: "ic-Folders")

    public let gift = ProtonIcon(name: "ic-Gift")

    public let globe = ProtonIcon(name: "ic-Globe")

    public let grid2 = ProtonIcon(name: "ic-Grid-2")

    public let grid3 = ProtonIcon(name: "ic-Grid-3")

    public let hamburger = ProtonIcon(name: "ic-Hamburger")

    public let hook = ProtonIcon(name: "ic-Hook")

    public let hourglass = ProtonIcon(name: "ic-Hourglass")

    public let houseFilled = ProtonIcon(name: "ic-House-filled")

    public let house = ProtonIcon(name: "ic-House")

    public let image = ProtonIcon(name: "ic-Image")

    public let inbox = ProtonIcon(name: "ic-Inbox")

    public let infoCircleFilled = ProtonIcon(name: "ic-Info-circle-filled")

    public let infoCircle = ProtonIcon(name: "ic-Info-circle")

    public let keySkeleton = ProtonIcon(name: "ic-Key-skeleton")

    public let key = ProtonIcon(name: "ic-Key")

    public let language = ProtonIcon(name: "ic-Language")

    public let lifeRing = ProtonIcon(name: "ic-Life-ring")

    public let lightbulb = ProtonIcon(name: "ic-Lightbulb")

    public let linesLongToSmall = ProtonIcon(name: "ic-Lines-long-to-small")

    public let linesVertical = ProtonIcon(name: "ic-Lines-vertical")

    public let linkPen = ProtonIcon(name: "ic-Link-pen")

    public let linkSlash = ProtonIcon(name: "ic-Link-slash")

    public let link = ProtonIcon(name: "ic-Link")

    public let listBullets = ProtonIcon(name: "ic-List-bullets")

    public let listNumbers = ProtonIcon(name: "ic-List-numbers")

    public let lockFilled = ProtonIcon(name: "ic-Lock-filled")

    public let lock = ProtonIcon(name: "ic-Lock")

    public let lowDash = ProtonIcon(name: "ic-Low-dash")

    public let magnifier = ProtonIcon(name: "ic-Magnifier")

    public let mapPin = ProtonIcon(name: "ic-Map-pin")

    public let minusCircle = ProtonIcon(name: "ic-Minus-circle")

    public let mobilePlus = ProtonIcon(name: "ic-Mobile-plus")

    public let mobile = ProtonIcon(name: "ic-Mobile")

    public let notepadChecklist = ProtonIcon(name: "ic-Notepad-checklist")

    public let paintRoller = ProtonIcon(name: "ic-Paint-roller")

    public let palette = ProtonIcon(name: "ic-Palette")

    public let paperClipVertical = ProtonIcon(name: "ic-Paper-clip-vertical")

    public let paperClip = ProtonIcon(name: "ic-Paper-clip")

    public let paperPlaneHorizontal = ProtonIcon(name: "ic-Paper-plane-horizontal")

    public let paperPlane = ProtonIcon(name: "ic-Paper-plane")

    public let pause = ProtonIcon(name: "ic-Pause")

    public let penSquare = ProtonIcon(name: "ic-Pen-square")

    public let pen = ProtonIcon(name: "ic-Pen")

    public let pencil = ProtonIcon(name: "ic-Pencil")

    public let phone = ProtonIcon(name: "ic-Phone")

    public let play = ProtonIcon(name: "ic-play")

    public let plusCircleFilled = ProtonIcon(name: "ic-Plus-circle-filled")

    public let plusCircle = ProtonIcon(name: "ic-Plus-circle")

    public let plus = ProtonIcon(name: "ic-Plus")

    public let powerOff = ProtonIcon(name: "ic-Power-off")

    public let printer = ProtonIcon(name: "ic-Printer")

    public let questionCircleFilled = ProtonIcon(name: "ic-Question-circle-filled")

    public let questionCircle = ProtonIcon(name: "ic-Question-circle")

    public let rocket = ProtonIcon(name: "ic-Rocket")

    public let servers = ProtonIcon(name: "ic-Servers")

    public let shield = ProtonIcon(name: "ic-Shield")

    public let speechBubble = ProtonIcon(name: "ic-Speech-bubble")

    public let squares = ProtonIcon(name: "ic-Squares")

    public let starFilled = ProtonIcon(name: "ic-Star-filled")

    public let starSlash = ProtonIcon(name: "ic-Star-slash")

    public let star = ProtonIcon(name: "ic-Star")

    public let storage = ProtonIcon(name: "ic-Storage")

    public let tagFilled = ProtonIcon(name: "ic-Tag-filled")

    public let tagPlus = ProtonIcon(name: "ic-Tag-plus")

    public let tag = ProtonIcon(name: "ic-Tag")

    public let tags = ProtonIcon(name: "ic-Tags")

    public let textAlignCenter = ProtonIcon(name: "ic-Text-align-center")

    public let textAlignJustify = ProtonIcon(name: "ic-Text-align-justify")

    public let textAlignLeft = ProtonIcon(name: "ic-Text-align-left")

    public let textAlignRight = ProtonIcon(name: "ic-Text-align-right")

    public let textBold = ProtonIcon(name: "ic-Text-bold")

    public let textItalic = ProtonIcon(name: "ic-Text-italic")

    public let textQuote = ProtonIcon(name: "ic-Text-quote")

    public let textUnderline = ProtonIcon(name: "ic-Text-underline")

    public let threeDotsHorizontal = ProtonIcon(name: "ic-three-dots-horizontal")

    public let threeDotsVertical = ProtonIcon(name: "ic-three-dots-vertical")

    public let trashCrossFilled = ProtonIcon(name: "ic-Trash-cross-filled")

    public let trashCross = ProtonIcon(name: "ic-Trash-cross")

    public let trash = ProtonIcon(name: "ic-Trash")

    public let userArrowLeft = ProtonIcon(name: "ic-User-arrow-left")

    public let userArrowRight = ProtonIcon(name: "ic-User-arrow-right")

    public let userCircle = ProtonIcon(name: "ic-User-circle")

    public let userFilled = ProtonIcon(name: "ic-User-filled")

    public let userPlus = ProtonIcon(name: "ic-User-plus")

    public let user = ProtonIcon(name: "ic-User")

    public let usersFilled = ProtonIcon(name: "ic-Users-filled")

    public let usersMerge = ProtonIcon(name: "ic-Users-merge")

    public let usersPlus = ProtonIcon(name: "ic-Users-plus")

    public let users = ProtonIcon(name: "ic-Users")

    public let vault = ProtonIcon(name: "ic-Vault")

    public let windowTerminal = ProtonIcon(name: "ic-Window-terminal")
    
    // Flags
    
    public func flag(forCountryCode countryCode: String) -> ProtonIcon {
        ProtonIcon(name: "flags-\(countryCode)")
    }
    
    // Logos — MasterBrand
    
    // swiftlint:disable inclusive_language
    
    public let masterBrandBrand = ProtonIcon(name: "MasterBrandBrand")
    
    public let masterBrandDark = ProtonIcon(name: "MasterBrandDark")
    
    public let masterBrandGlyph = ProtonIcon(name: "MasterBrandGlyph")
    
    public let masterBrandLight = ProtonIcon(name: "MasterBrandLight")
    
    public let masterBrandWithEffect = ProtonIcon(name: "MasterBrandWithEffect")
    
    @available(*, deprecated, renamed: "masterBrandBrand")
    public let logoProton = ProtonIcon(name: "MasterBrandBrand")
    
    // swiftlint:enable inclusive_language
    
    // Logos — SuiteIcons
    
    public let calendarMain = ProtonIcon(name: "CalendarMain")
    
    public let driveMain = ProtonIcon(name: "DriveMain")
    
    public let mailMain = ProtonIcon(name: "MailMain")
    
    public let vpnMain = ProtonIcon(name: "VPNMain")
    
    @available(*, deprecated, renamed: "calendarMainTransparent")
    public let loginWelcomeCalendarSmallLogo = ProtonIcon(name: "CalendarMainTransparent")
    @available(*, deprecated, renamed: "calendarMainTransparent")
    public let calendarMainSmall = ProtonIcon(name: "CalendarMainTransparent")
    
    public let calendarMainTransparent = ProtonIcon(name: "CalendarMainTransparent")
    
    @available(*, deprecated, renamed: "driveMainTransparent")
    public let loginWelcomeDriveSmallLogo = ProtonIcon(name: "DriveMainTransparent")
    @available(*, deprecated, renamed: "driveMainTransparent")
    public let driveMainSmall = ProtonIcon(name: "DriveMainTransparent")
    
    public let driveMainTransparent = ProtonIcon(name: "DriveMainTransparent")
    
    @available(*, deprecated, renamed: "mailMainTransparent")
    public let loginWelcomeMailSmallLogo = ProtonIcon(name: "MailMainTransparent")
    @available(*, deprecated, renamed: "mailMainTransparent")
    public let mailMainSmall = ProtonIcon(name: "MailMainTransparent")
    
    public let mailMainTransparent = ProtonIcon(name: "MailMainTransparent")
    
    @available(*, deprecated, renamed: "vpnMainTransparent")
    public let loginWelcomeVPNSmallLogo = ProtonIcon(name: "VPNMainTransparent")
    @available(*, deprecated, renamed: "vpnMainTransparent")
    public let vpnMainSmall = ProtonIcon(name: "VPNMainTransparent")
    
    public let vpnMainTransparent = ProtonIcon(name: "VPNMainTransparent")
    
    public let calendarStroke = ProtonIcon(name: "CalendarStroke")
    
    public let driveStroke = ProtonIcon(name: "DriveStroke")
    
    public let mailStroke = ProtonIcon(name: "MailStroke")
    
    public let vpnStroke = ProtonIcon(name: "VPNStroke")
    
    public let calendarV4 = ProtonIcon(name: "CalendarV4")
    
    public let driveV4 = ProtonIcon(name: "DriveV4")
    
    public let mailV4 = ProtonIcon(name: "MailV4")
    
    public let vpnV4 = ProtonIcon(name: "VPNV4")
    
    // Logos — Wordmarks
    
    public let calendarWordmark = ProtonIcon(name: "CalendarWordmark")
    public let driveWordmark = ProtonIcon(name: "DriveWordmark")
    public let mailWordmark = ProtonIcon(name: "MailWordmark")
    public let vpnWordmark = ProtonIcon(name: "VPNWordmark")
    
    @available(*, deprecated, renamed: "calendarWordmarkNoBackground")
    public let logoProtonCalendar = ProtonIcon(name: "CalendarWordmarkNoBackground")
    @available(*, deprecated, renamed: "calendarWordmarkNoBackground")
    public let loginWelcomeCalendarLogo = ProtonIcon(name: "CalendarWordmarkNoBackground")
    
    public let calendarWordmarkNoBackground = ProtonIcon(name: "CalendarWordmarkNoBackground")
    
    @available(*, deprecated, renamed: "driveWordmarkNoBackground")
    public let logoProtonDrive = ProtonIcon(name: "DriveWordmarkNoBackground")
    @available(*, deprecated, renamed: "driveWordmarkNoBackground")
    public let loginWelcomeDriveLogo = ProtonIcon(name: "DriveWordmarkNoBackground")
    
    public let driveWordmarkNoBackground = ProtonIcon(name: "DriveWordmarkNoBackground")
    
    @available(*, deprecated, renamed: "mailWordmarkNoBackground")
    public let logoProtonMail = ProtonIcon(name: "MailWordmarkNoBackground")
    @available(*, deprecated, renamed: "mailWordmarkNoBackground")
    public let loginWelcomeMailLogo = ProtonIcon(name: "MailWordmarkNoBackground")
    
    public let mailWordmarkNoBackground = ProtonIcon(name: "MailWordmarkNoBackground")
    
    @available(*, deprecated, renamed: "vpnWordmarkNoBackground")
    public let logoProtonVPN = ProtonIcon(name: "VPNWordmarkNoBackground")
    @available(*, deprecated, renamed: "vpnWordmarkNoBackground")
    public let loginWelcomeVPNLogo = ProtonIcon(name: "VPNWordmarkNoBackground")
    
    public let vpnWordmarkNoBackground = ProtonIcon(name: "VPNWordmarkNoBackground")
    
    // Login-specific
    
    public let loginSummaryBottom = ProtonIcon(name: "summary_bottom")
    
    public let loginSummaryProton = ProtonIcon(name: "summary_proton")
    
    public let loginSummaryVPN = ProtonIcon(name: "summary_vpn")
    
    public let loginWelcomeTopImageForProton = ProtonIcon(name: "WelcomeTopImageForProton")
    
    public let loginWelcomeTopImageForVPN = ProtonIcon(name: "WelcomeTopImageForVPN")
    
}

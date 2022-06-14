//
//  UIFoundationsIconsViewController.swift
//  ExampleApp-V5 - Created on 17/03/2022.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import AppKit
import ProtonCore_UIFoundations

final class UIFoundationsIconsViewController: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    private var appearanceObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Icons"
        collectionView.register(
            ImageCollectionViewCell.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewCell")
        )
        
        view.wantsLayer = true
        view.makeBackingLayer()
        view.layer?.backgroundColor = ColorProvider.BackgroundNorm.cgColor
        collectionView.backgroundColors = [ColorProvider.BackgroundNorm]
        
        if #available(macOS 10.14, *) {
            appearanceObserver = NSApp.observe(\.effectiveAppearance) { [weak self] _, _ in
                self?.collectionView.reloadData()
                self?.view.layer?.backgroundColor = ColorProvider.BackgroundNorm.cgColor
                self?.collectionView.backgroundColors = [ColorProvider.BackgroundNorm]
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.styleMask = [.closable, .titled, .resizable]
        view.window?.setFrame(
            NSRect(origin: view.window?.frame.origin ?? .zero, size: NSSize(width: 1200, height: 900)),
            display: true
        )
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        if let layout = collectionView.collectionViewLayout as? NSCollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 300, height: 300)
            layout.sectionInset = .init(top: 32, left: 32, bottom: 32, right: 32)
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    let data: [(String, [(NSImage, String, String)])] = [
        ("Logos — MasterBrand", [
            (IconProvider.masterBrandBrand, "MasterBrand Variant=Brand", "masterBrandBrand"),
            (IconProvider.masterBrandGlyph, "MasterBrand Variant=Glyph", "masterBrandGlyph"),
            (IconProvider.masterBrandLightDark, "MasterBrand Variant=Dark & Variant=Light", "masterBrandLightDark"),
            (IconProvider.masterBrandLightDark.darkModePrefering(), "MasterBrand Variant=Dark", "masterBrandLightDark.darkModePrefering()"),
            (IconProvider.masterBrandWithEffect, "MasterBrand Variant=WithEffect", "masterBrandWithEffect")
        ]),
        ("Logos — SuiteIcons", [
            (IconProvider.calendarMain, "CalendarMain", "calendarMain"),
            (IconProvider.calendarMainTransparent, "CalendarMainTransparent", "calendarMainTransparent"),
            (IconProvider.calendarStroke, "CalendarStroke", "calendarStroke"),
            (IconProvider.driveMain, "DriveMain", "driveMain"),
            (IconProvider.driveMainTransparent, "DriveMainTransparent", "driveMainTransparent"),
            (IconProvider.driveStroke, "DriveStroke", "driveStroke"),
            (IconProvider.mailMain, "MailMain", "mailMain"),
            (IconProvider.mailMainTransparent, "MailMainTransparent", "mailMainTransparent"),
            (IconProvider.mailStroke, "MailStroke", "mailStroke"),
            (IconProvider.vpnMain, "VPNMain", "vpnMain"),
            (IconProvider.vpnMainTransparent, "VPNMainTransparent", "vpnMainTransparent"),
            (IconProvider.vpnStroke, "VPNStroke", "vpnStroke"),
        ]),
        ("Logos — Wordmarks", [
            (IconProvider.calendarWordmark, "CalendarWordmark", "calendarWordmark"),
            (IconProvider.calendarWordmarkNoBackground, "CalendarWordmarkNoBackground", "calendarWordmarkNoBackground"),
            (IconProvider.driveWordmark, "DriveWordmark", "driveWordmark"),
            (IconProvider.driveWordmarkNoBackground, "DriveWordmarkNoBackground", "driveWordmarkNoBackground"),
            (IconProvider.mailWordmark, "MailWordmark", "mailWordmark"),
            (IconProvider.mailWordmarkNoBackground, "MailWordmarkNoBackground", "mailWordmarkNoBackground"),
            (IconProvider.vpnWordmark, "VPNWordmark", "vpnWordmark"),
            (IconProvider.vpnWordmarkNoBackground, "VPNWordmarkNoBackground", "vpnWordmarkNoBackground")
        ]),
        ("Logos — Wordmarks — dark mode prefering", [
            (IconProvider.calendarWordmark.darkModePrefering(), "CalendarWordmark", "calendarWordmark.darkModePrefering()"),
            (IconProvider.calendarWordmarkNoBackground.darkModePrefering(), "CalendarWordmarkNoBackground", "calendarWordmarkNoBackground.darkModePrefering()"),
            (IconProvider.driveWordmark.darkModePrefering(), "DriveWordmark", "driveWordmark.darkModePrefering()"),
            (IconProvider.driveWordmarkNoBackground.darkModePrefering(), "DriveWordmarkNoBackground", "driveWordmarkNoBackground.darkModePrefering()"),
            (IconProvider.mailWordmark.darkModePrefering(), "MailWordmark", "mailWordmark.darkModePrefering()"),
            (IconProvider.mailWordmarkNoBackground.darkModePrefering(), "MailWordmarkNoBackground", "mailWordmarkNoBackground.darkModePrefering()"),
            (IconProvider.vpnWordmark.darkModePrefering(), "VPNWordmark", "vpnWordmark.darkModePrefering()"),
            (IconProvider.vpnWordmarkNoBackground.darkModePrefering(), "VPNWordmarkNoBackground", "vpnWordmarkNoBackground.darkModePrefering()")
        ]),
        ("Proton Icon Set", [
            (IconProvider.arrowInToRectangle, "ic_arrow_in_to_rectangle", "arrowInToRectangle"),
            (IconProvider.alias, "ic-alias", "alias"),
            (IconProvider.archiveBox, "ic-archive-box", "archiveBox"),
            (IconProvider.arrowDownArrowUp, "ic-arrow-down-arrow-up", "arrowDownArrowUp"),
            (IconProvider.arrowDownCircleFilled, "ic-arrow-down-circle-filled", "arrowDownCircleFilled"),
            (IconProvider.arrowDownCircle, "ic-arrow-down-circle", "arrowDownCircle"),
            (IconProvider.arrowDownLine, "ic-arrow-down-line", "arrowDownLine"),
            (IconProvider.arrowDownToSquare, "ic-arrow-down-to-square", "arrowDownToSquare"),
            (IconProvider.arrowDown, "ic-arrow-down", "arrowDown"),
            (IconProvider.arrowLeftAndUp, "ic-arrow-left-and-up", "arrowLeftAndUp"),
            (IconProvider.arrowLeft, "ic-arrow-left", "arrowLeft"),
            (IconProvider.arrowOutFromRectangle, "ic-arrow-out-from-rectangle", "arrowOutFromRectangle"),
            (IconProvider.arrowOutSquare, "ic-arrow-out-square", "arrowOutSquare"),
            (IconProvider.arrowOverSquare, "ic-arrow-over-square", "arrowOverSquare"),
            (IconProvider.arrowRightArrowLeft, "ic-arrow-right-arrow-left", "arrowRightArrowLeft"),
            (IconProvider.arrowRight, "ic-arrow-right", "arrowRight"),
            (IconProvider.arrowRotateRight, "ic-arrow-rotate-right", "arrowRotateRight"),
            (IconProvider.arrowUpAndLeft, "ic-arrow-up-and-left", "arrowUpAndLeft"),
            (IconProvider.arrowUpBigLine, "ic-arrow-up-big-line", "arrowUpBigLine"),
            (IconProvider.arrowUpBounceLeft, "ic-arrow-up-bounce-left", "arrowUpBounceLeft"),
            (IconProvider.arrowUpFromSquare, "ic-arrow-up-from-square", "arrowUpFromSquare"),
            (IconProvider.arrowUpLine, "ic-arrow-up-line", "arrowUpLine"),
            (IconProvider.arrowUp, "ic-arrow-up", "arrowUp"),
            (IconProvider.arrowsCross, "ic-arrows-cross", "arrowsCross"),
            (IconProvider.arrowsFromCenter, "ic-arrows-from-center", "arrowsFromCenter"),
            (IconProvider.arrowsLeftRight, "ic-arrows-left-right", "arrowsLeftRight"),
            (IconProvider.arrowsRotate, "ic-arrows-rotate", "arrowsRotate"),
            (IconProvider.arrowsSwapRight, "ic-arrows-swap-right", "arrowsSwapRight"),
            (IconProvider.arrowsSwitch, "ic-arrows-switch", "arrowsSwitch"),
            (IconProvider.arrowsToCenter, "ic-arrows-to-center", "arrowsToCenter"),
            (IconProvider.arrowsUpAndLeft, "ic-arrows-up-and-left", "arrowsUpAndLeft"),
            (IconProvider.at, "ic-at", "at"),
            (IconProvider.backspace, "ic-backspace", "backspace"),
            (IconProvider.bagPercent, "ic-bag-percent", "bagPercent"),
            (IconProvider.bell, "ic-bell", "bell"),
            (IconProvider.bolt, "ic-bolt", "bolt"),
            (IconProvider.bookmark, "ic-bookmark", "bookmark"),
            (IconProvider.brandAndroid, "ic-brand-android", "brandAndroid"),
            (IconProvider.brandApple, "ic-brand-apple", "brandApple"),
            (IconProvider.brandChrome, "ic-brand-chrome", "brandChrome"),
            (IconProvider.brandLinux, "ic-brand-linux", "brandLinux"),
            (IconProvider.brandPaypal, "ic-brand-paypal", "brandPaypal"),
            (IconProvider.brandProtonVpn, "ic-brand-proton-vpn", "brandProtonVpn"),
            (IconProvider.brandTor, "ic-brand-tor", "brandTor"),
            (IconProvider.brandTwitter, "ic-brand-twitter", "brandTwitter"),
            (IconProvider.brandWindows, "ic-brand-windows", "brandWindows"),
            (IconProvider.brandWireguard, "ic-brand-wireguard", "brandWireguard"),
            (IconProvider.briefcase, "ic-briefcase", "briefcase"),
            (IconProvider.broom, "ic-broom", "broom"),
            (IconProvider.bug, "ic-bug", "bug"),
            (IconProvider.buildings, "ic-buildings", "buildings"),
            (IconProvider.calendarCells, "ic-calendar-cells", "calendarCells"),
            (IconProvider.calendarCheckmark, "ic-calendar-checkmark", "calendarCheckmark"),
            (IconProvider.calendarGrid, "ic-calendar-grid", "calendarGrid"),
            (IconProvider.calendarRow, "ic-calendar-row", "calendarRow"),
            (IconProvider.calendarToday, "ic-calendar-today", "calendarToday"),
            (IconProvider.camera, "ic-camera", "camera"),
            (IconProvider.cardIdentity, "ic-card-identity", "cardIdentity"),
            (IconProvider.checkCircleFull, "ic-check-circle-full", "checkCircleFull"),
            (IconProvider.checkTriple, "ic-check-triple", "checkTriple"),
            (IconProvider.checkmarkCircle, "ic-checkmark-circle", "checkmarkCircle"),
            (IconProvider.checkmark, "ic-checkmark", "checkmark"),
            (IconProvider.chevronDownFilled, "ic-chevron-down-filled", "chevronDownFilled"),
            (IconProvider.chevronDown, "ic-chevron-down", "chevronDown"),
            (IconProvider.chevronLeftFilled, "ic-chevron-left-filled", "chevronLeftFilled"),
            (IconProvider.chevronLeft, "ic-chevron-left", "chevronLeft"),
            (IconProvider.chevronRightFilled, "ic-chevron-right-filled", "chevronRightFilled"),
            (IconProvider.chevronRight, "ic-chevron-right", "chevronRight"),
            (IconProvider.chevronUpFilled, "ic-chevron-up-filled", "chevronUpFilled"),
            (IconProvider.chevronUp, "ic-chevron-up", "chevronUp"),
            (IconProvider.chevronsLeft, "ic-chevrons-left", "chevronsLeft"),
            (IconProvider.chevronsRight, "ic-chevrons-right", "chevronsRight"),
            (IconProvider.circleFilled, "ic-circle-filled", "circleFilled"),
            (IconProvider.circleHalfFilled, "ic-circle-half-filled", "circleHalfFilled"),
            (IconProvider.circleSlash, "ic-circle-slash", "circleSlash"),
            (IconProvider.circle, "ic-circle", "circle"),
            (IconProvider.clockRotateLeft, "ic-clock-rotate-left", "clockRotateLeft"),
            (IconProvider.clock, "ic-clock", "clock"),
            (IconProvider.cloud, "ic-cloud", "cloud"),
            (IconProvider.code, "ic-code", "code"),
            (IconProvider.cogWheel, "ic-cog-wheel", "cogWheel"),
            (IconProvider.creditCard, "ic-credit-card", "creditCard"),
            (IconProvider.crossBig, "ic-cross-big", "crossBig"),
            (IconProvider.crossCircleFilled, "ic-cross-circle-filled", "crossCircleFilled"),
            (IconProvider.crossCircle, "ic-cross-circle", "crossCircle"),
            (IconProvider.crossSmall, "ic-cross-small", "crossSmall"),
            (IconProvider.cross, "ic-cross", "cross"),
            (IconProvider.drive, "ic-drive", "drive"),
            (IconProvider.earth, "ic-earth", "earth"),
            (IconProvider.envelopeArrowUpAndRight, "ic-envelope-arrow-up-and-right", "envelopeArrowUpAndRight"),
            (IconProvider.envelopeCross, "ic-envelope-cross", "envelopeCross"),
            (IconProvider.envelopeDot, "ic-envelope-dot", "envelopeDot"),
            (IconProvider.envelopeOpenText, "ic-envelope-open-text", "envelopeOpenText"),
            (IconProvider.envelopeOpen, "ic-envelope-open", "envelopeOpen"),
            (IconProvider.envelope, "ic-envelope", "envelope"),
            (IconProvider.envelopes, "ic-envelopes", "envelopes"),
            (IconProvider.eraser, "ic-eraser", "eraser"),
            (IconProvider.exclamationCircleFilled, "ic-exclamation-circle-filled", "exclamationCircleFilled"),
            (IconProvider.exclamationCircle, "ic-exclamation-circle", "exclamationCircle"),
            (IconProvider.eyeSlash, "ic-eye-slash", "eyeSlash"),
            (IconProvider.eye, "ic-eye", "eye"),
            (IconProvider.fileArrowInUp, "ic-file-arrow-in-up", "fileArrowInUp"),
            (IconProvider.fileArrowIn, "ic-file-arrow-in", "fileArrowIn"),
            (IconProvider.fileArrowOut, "ic-file-arrow-out", "fileArrowOut"),
            (IconProvider.fileImage, "ic-file-image", "fileImage"),
            (IconProvider.fileLines, "ic-file-lines", "fileLines"),
            (IconProvider.filePdf, "ic-file-pdf", "filePdf"),
            (IconProvider.fileShapes, "ic-file-shapes", "fileShapes"),
            (IconProvider.file, "ic-file", "file"),
            (IconProvider.filingCabinet, "ic-filing-cabinet", "filingCabinet"),
            (IconProvider.filter, "ic-filter", "filter"),
            (IconProvider.fingerprint, "ic-fingerprint", "fingerprint"),
            (IconProvider.fireSlash, "ic-fire-slash", "fireSlash"),
            (IconProvider.fire, "ic-fire", "fire"),
            (IconProvider.folderArrowInFilled, "ic-folder-arrow-in-filled", "folderArrowInFilled"),
            (IconProvider.folderArrowIn, "ic-folder-arrow-in", "folderArrowIn"),
            (IconProvider.folderArrowUp, "ic-folder-arrow-up", "folderArrowUp"),
            (IconProvider.folderFilled, "ic-folder-filled", "folderFilled"),
            (IconProvider.folderOpenFilled, "ic-folder-open-filled", "folderOpenFilled"),
            (IconProvider.folderOpen, "ic-folder-open", "folderOpen"),
            (IconProvider.folderPlus, "ic-folder-plus", "folderPlus"),
            (IconProvider.folder, "ic-folder", "folder"),
            (IconProvider.foldersFilled, "ic-folders-filled", "foldersFilled"),
            (IconProvider.folders, "ic-folders", "folders"),
            (IconProvider.gift, "ic-gift", "gift"),
            (IconProvider.globe, "ic-globe", "globe"),
            (IconProvider.grid2, "ic-grid-2", "grid2"),
            (IconProvider.grid3, "ic-grid-3", "grid3"),
            (IconProvider.hamburger, "ic-hamburger", "hamburger"),
            (IconProvider.heart, "ic-heart", "heart"),
            (IconProvider.hook, "ic-hook", "hook"),
            (IconProvider.hourglass, "ic-hourglass", "hourglass"),
            (IconProvider.houseFilled, "ic-house-filled", "houseFilled"),
            (IconProvider.house, "ic-house", "house"),
            (IconProvider.image, "ic-image", "image"),
            (IconProvider.inbox, "ic-inbox", "inbox"),
            (IconProvider.infoCircleFilled, "ic-info-circle-filled", "infoCircleFilled"),
            (IconProvider.infoCircle, "ic-info-circle", "infoCircle"),
            (IconProvider.keySkeleton, "ic-key-skeleton", "keySkeleton"),
            (IconProvider.key, "ic-key", "key"),
            (IconProvider.language, "ic-language", "language"),
            (IconProvider.lifeRing, "ic-life-ring", "lifeRing"),
            (IconProvider.lightbulb, "ic-lightbulb", "lightbulb"),
            (IconProvider.linesLongToSmall, "ic-lines-long-to-small", "linesLongToSmall"),
            (IconProvider.linesVertical, "ic-lines-vertical", "linesVertical"),
            (IconProvider.linkPen, "ic-link-pen", "linkPen"),
            (IconProvider.linkSlash, "ic-link-slash", "linkSlash"),
            (IconProvider.link, "ic-link", "link"),
            (IconProvider.listBullets, "ic-list-bullets", "listBullets"),
            (IconProvider.listNumbers, "ic-list-numbers", "listNumbers"),
            (IconProvider.lockCheckFilled, "ic-lock-check-filled", "lockCheckFilled"),
            (IconProvider.lockExclamationFilled, "ic-lock-exclamation-filled", "lockExclamationFilled"),
            (IconProvider.lockFilled, "ic-lock-filled", "lockFilled"),
            (IconProvider.lockOpenCheckFilled, "ic-lock-open-check-filled", "lockOpenCheckFilled"),
            (IconProvider.lockOpenExclamationFilled, "ic-lock-open-exclamation-filled", "lockOpenExclamationFilled"),
            (IconProvider.lockOpenPenFilled, "ic-lock-open-pen-filled", "lockOpenPenFilled"),
            (IconProvider.lockPenFilled, "ic-lock-pen-filled", "lockPenFilled"),
            (IconProvider.lock, "ic-lock", "lock"),
            (IconProvider.locks, "ic-locks", "locks"),
            (IconProvider.lowDash, "ic-low-dash", "lowDash"),
            (IconProvider.magnifier, "ic-magnifier", "magnifier"),
            (IconProvider.mailbox, "ic-mailbox", "mailbox"),
            (IconProvider.mapPin, "ic-map-pin", "mapPin"),
            (IconProvider.map, "ic-map", "map"),
            (IconProvider.minusCircle, "ic-minus-circle", "minusCircle"),
            (IconProvider.minus, "ic-minus", "minus"),
            (IconProvider.mobilePlus, "ic-mobile-plus", "mobilePlus"),
            (IconProvider.mobile, "ic-mobile", "mobile"),
            (IconProvider.moon, "ic-moon", "moon"),
            (IconProvider.note, "ic-note", "note"),
            (IconProvider.notepadChecklist, "ic-notepad-checklist", "notepadChecklist"),
            (IconProvider.paintRoller, "ic-paint-roller", "paintRoller"),
            (IconProvider.palette, "ic-palette", "palette"),
            (IconProvider.paperClipVertical, "ic-paper-clip-vertical", "paperClipVertical"),
            (IconProvider.paperClip, "ic-paper-clip", "paperClip"),
            (IconProvider.paperPlaneHorizontal, "ic-paper-plane-horizontal", "paperPlaneHorizontal"),
            (IconProvider.paperPlane, "ic-paper-plane", "paperPlane"),
            (IconProvider.pause, "ic-pause", "pause"),
            (IconProvider.penSquare, "ic-pen-square", "penSquare"),
            (IconProvider.pen, "ic-pen", "pen"),
            (IconProvider.pencil, "ic-pencil", "pencil"),
            (IconProvider.phone, "ic-phone", "phone"),
            (IconProvider.play, "ic-play", "play"),
            (IconProvider.plusCircleFilled, "ic-plus-circle-filled", "plusCircleFilled"),
            (IconProvider.plusCircle, "ic-plus-circle", "plusCircle"),
            (IconProvider.plus, "ic-plus", "plus"),
            (IconProvider.powerOff, "ic-power-off", "powerOff"),
            (IconProvider.presentationScreen, "ic-presentation-screen", "presentationScreen"),
            (IconProvider.printer, "ic-printer", "printer"),
            (IconProvider.questionCircleFilled, "ic-question-circle-filled", "questionCircleFilled"),
            (IconProvider.questionCircle, "ic-question-circle", "questionCircle"),
            (IconProvider.robot, "ic-robot", "robot"),
            (IconProvider.rocket, "ic-rocket", "rocket"),
            (IconProvider.servers, "ic-servers", "servers"),
            (IconProvider.shieldFilled, "ic-shield-filled", "shieldFilled"),
            (IconProvider.shieldHalfFilled, "ic-shield-half-filled", "shieldHalfFilled"),
            (IconProvider.shield, "ic-shield", "shield"),
            (IconProvider.speechBubble, "ic-speech-bubble", "speechBubble"),
            (IconProvider.squares, "ic-squares", "squares"),
            (IconProvider.starFilled, "ic-star-filled", "starFilled"),
            (IconProvider.starSlash, "ic-star-slash", "starSlash"),
            (IconProvider.star, "ic-star", "star"),
            (IconProvider.storage, "ic-storage", "storage"),
            (IconProvider.sun, "ic-sun", "sun"),
            (IconProvider.switchOff, "ic-switch-off", "switchOff"),
            (IconProvider.switchOnLock, "ic-switch-on-lock", "switchOnLock"),
            (IconProvider.switchOn, "ic-switch-on", "switchOn"),
            (IconProvider.tagFilled, "ic-tag-filled", "tagFilled"),
            (IconProvider.tagPlus, "ic-tag-plus", "tagPlus"),
            (IconProvider.tag, "ic-tag", "tag"),
            (IconProvider.tags, "ic-tags", "tags"),
            (IconProvider.textAlignCenter, "ic-text-align-center", "textAlignCenter"),
            (IconProvider.textAlignJustify, "ic-text-align-justify", "textAlignJustify"),
            (IconProvider.textAlignLeft, "ic-text-align-left", "textAlignLeft"),
            (IconProvider.textAlignRight, "ic-text-align-right", "textAlignRight"),
            (IconProvider.textBold, "ic-text-bold", "textBold"),
            (IconProvider.textItalic, "ic-text-italic", "textItalic"),
            (IconProvider.textQuote, "ic-text-quote", "textQuote"),
            (IconProvider.textUnderline, "ic-text-underline", "textUnderline"),
            (IconProvider.threeDotsHorizontal, "ic-three-dots-horizontal", "threeDotsHorizontal"),
            (IconProvider.threeDotsVertical, "ic-three-dots-vertical", "threeDotsVertical"),
            (IconProvider.trashCrossFilled, "ic-trash-cross-filled", "trashCrossFilled"),
            (IconProvider.trashCross, "ic-trash-cross", "trashCross"),
            (IconProvider.trash, "ic-trash", "trash"),
            (IconProvider.tv, "ic-tv", "tv"),
            (IconProvider.userArrowLeft, "ic-user-arrow-left", "userArrowLeft"),
            (IconProvider.userArrowRight, "ic-user-arrow-right", "userArrowRight"),
            (IconProvider.userCircle, "ic-user-circle", "userCircle"),
            (IconProvider.userFilled, "ic-user-filled", "userFilled"),
            (IconProvider.userPlus, "ic-user-plus", "userPlus"),
            (IconProvider.user, "ic-user", "user"),
            (IconProvider.usersFilled, "ic-users-filled", "usersFilled"),
            (IconProvider.usersMerge, "ic-users-merge", "usersMerge"),
            (IconProvider.usersPlus, "ic-users-plus", "usersPlus"),
            (IconProvider.users, "ic-users", "users"),
            (IconProvider.vault, "ic-vault", "vault"),
            (IconProvider.wallet, "ic-wallet", "wallet"),
            (IconProvider.windowImage, "ic-window-image", "windowImage"),
            (IconProvider.windowTerminal, "ic-window-terminal", "windowTerminal"),
            (IconProvider.wrench, "ic-wrench", "wrench")
        ])
    ]

}

extension UIFoundationsIconsViewController: NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        data[section].1.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewCell"),
            for: indexPath
        )
        (item as? ImageCollectionViewCell)?.setImage(data[indexPath.section].1[indexPath.item].0)
        (item as? ImageCollectionViewCell)?.setText(data[indexPath.section].1[indexPath.item].1)
        return item
    }
}

extension UIFoundationsIconsViewController: NSCollectionViewDelegate {
    
}

final class ImageCollectionViewCell: NSCollectionViewItem {
    
    private let image = NSImageView()
    private let label = NSTextField()

    override func loadView() {
        view = NSView(frame: NSRect(origin: .zero, size: NSSize(width: 300, height: 300)))
        view.wantsLayer = true
        view.makeBackingLayer()
        
        view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleProportionallyUpOrDown
        
        view.addSubview(label)
        label.isEditable = false
        label.isSelectable = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalTo: image.widthAnchor),
            image.widthAnchor.constraint(equalTo: view.widthAnchor),
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.topAnchor.constraint(equalTo: view.topAnchor),
            image.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -32),
            
            label.widthAnchor.constraint(equalTo: view.widthAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setImage(_ image: NSImage) {
        self.image.image = image
    }
    
    func setText(_ text: String) {
        label.stringValue = text
    }
    
}

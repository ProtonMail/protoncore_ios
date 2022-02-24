//
//  UIFoundationsIconsViewController.swift
//  ExampleApp-V5 - Created on 18/02/2022.
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

import UIKit
import ProtonCore_UIFoundations

final class UIFoundationsIconsViewController: UIFoundationsAppearanceStyleViewController {
    
    private let layout = UICollectionViewFlowLayout()
    private var collectionView: UICollectionView!
    
    override func loadView() {
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        view = collectionView
    }
    
    override func viewDidLoad() {
        title = "Icons"
        view.backgroundColor = ColorProvider.BackgroundNorm
        layout.sectionHeadersPinToVisibleBounds = true
        collectionView.register(IconCollectionViewCell.self,
                                forCellWithReuseIdentifier: "UIFoundationsIconsViewController.icon")
        collectionView.register(LabelReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "UIFoundationsIconsViewController.title")
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout.itemSize = CGSize(width: collectionView.bounds.width - 128, height: 120)
        layout.sectionInset = .init(top: 0, left: 0, bottom: 40, right: 0)
        layout.minimumLineSpacing = 32
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.reloadData()
    }
    
    let data: [(String, [(UIImage, String, String)])] = [
        ("Proton Icon Set", [
            (IconProvider.archiveBox, "ic-Archive-box", "archiveBox"),
            (IconProvider.arrowDownArrowUp, "ic-Arrow-down-arrow-up", "arrowDownArrowUp"),
            (IconProvider.arrowDownCircleFilled, "ic-Arrow-down-circle-filled", "arrowDownCircleFilled"),
            (IconProvider.arrowDownCircle, "ic-Arrow-down-circle", "arrowDownCircle"),
            (IconProvider.arrowDownLine, "ic-Arrow-down-line", "arrowDownLine"),
            (IconProvider.arrowDown, "ic-Arrow-down", "arrowDown"),
            (IconProvider.arrowLeft, "ic-Arrow-left", "arrowLeft"),
            (IconProvider.arrowOutFromRectangle, "ic-Arrow-out-from-rectangle", "arrowOutFromRectangle"),
            (IconProvider.arrowOutSquare, "ic-Arrow-out-square", "arrowOutSquare"),
            (IconProvider.arrowRight, "ic-Arrow-right", "arrowRight"),
            (IconProvider.arrowRotateRight, "ic-Arrow-rotate-right", "arrowRotateRight"),
            (IconProvider.arrowUpAndLeft, "ic-Arrow-up-and-left", "arrowUpAndLeft"),
            (IconProvider.arrowUpBigLine, "ic-Arrow-up-big-line", "arrowUpBigLine"),
            (IconProvider.arrowUpFromSquare, "ic-Arrow-up-from-square", "arrowUpFromSquare"),
            (IconProvider.arrowUpLeft, "ic-Arrow-up-left", "arrowUpLeft"),
            (IconProvider.arrowUpLine, "ic-Arrow-up-line", "arrowUpLine"),
            (IconProvider.arrowUp, "ic-Arrow-up", "arrowUp"),
            (IconProvider.arrowsCross, "ic-Arrows-cross", "arrowsCross"),
            (IconProvider.arrowsFromCenter, "ic-Arrows-from-center", "arrowsFromCenter"),
            (IconProvider.arrowsLeftRight, "ic-Arrows-left-right", "arrowsLeftRight"),
            (IconProvider.arrowsRotate, "ic-Arrows-rotate", "arrowsRotate"),
            (IconProvider.arrowsSwitch, "ic-Arrows-switch", "arrowsSwitch"),
            (IconProvider.arrowsToCenter, "ic-Arrows-to-center", "arrowsToCenter"),
            (IconProvider.arrowsUpAndLeft, "ic-Arrows-up-and-left", "arrowsUpAndLeft"),
            (IconProvider.at, "ic-At", "at"),
            (IconProvider.bell, "ic-Bell", "bell"),
            (IconProvider.brandAndroid, "ic-Brand-android", "brandAndroid"),
            (IconProvider.brandApple, "ic-Brand-apple", "brandApple"),
            (IconProvider.brandLinux, "ic-Brand-linux", "brandLinux"),
            (IconProvider.brandPaypal, "ic-Brand-paypal", "brandPaypal"),
            (IconProvider.brandProtonVpn, "ic-Brand-proton-vpn", "brandProtonVpn"),
            (IconProvider.brandWindows, "ic-Brand-windows", "brandWindows"),
            (IconProvider.brandWireguard, "ic-Brand-wireguard", "brandWireguard"),
            (IconProvider.broom, "ic-Broom", "broom"),
            (IconProvider.bug, "ic-Bug", "bug"),
            (IconProvider.buildings, "ic-Buildings", "buildings"),
            (IconProvider.calendarCells, "ic-Calendar-cells", "calendarCells"),
            (IconProvider.calendarCheckmark, "ic-Calendar-checkmark", "calendarCheckmark"),
            (IconProvider.calendarGrid, "ic-Calendar-grid", "calendarGrid"),
            (IconProvider.calendarRow, "ic-Calendar-row", "calendarRow"),
            (IconProvider.calendarToday, "ic-Calendar-today", "calendarToday"),
            (IconProvider.camera, "ic-Camera", "camera"),
            (IconProvider.cardIdentity, "ic-Card-identity", "cardIdentity"),
            (IconProvider.checkCircleFull, "ic-Check-circle-full", "checkCircleFull"),
            (IconProvider.checkmarkCircle, "ic-Checkmark-circle", "checkmarkCircle"),
            (IconProvider.checkmark, "ic-Checkmark", "checkmark"),
            (IconProvider.chevronDown, "ic-Chevron_down", "chevronDown"),
            (IconProvider.chevronLeft, "ic-Chevron_left", "chevronLeft"),
            (IconProvider.chevronRight, "ic-Chevron_right", "chevronRight"),
            (IconProvider.chevronUp, "ic-Chevron_up", "chevronUp"),
            (IconProvider.chevronDownFilled, "ic-Chevron-down-filled", "chevronDownFilled"),
            (IconProvider.chevronLeftFilled, "ic-Chevron-left-filled", "chevronLeftFilled"),
            (IconProvider.chevronRightFilled, "ic-Chevron-right-filled", "chevronRightFilled"),
            (IconProvider.chevronUpFilled, "ic-Chevron-up-filled", "chevronUpFilled"),
            (IconProvider.circleFilled, "ic-Circle-filled", "circleFilled"),
            (IconProvider.circleHalfFilled, "ic-Circle-half-filled", "circleHalfFilled"),
            (IconProvider.circleSlash, "ic-Circle-slash", "circleSlash"),
            (IconProvider.circle, "ic-Circle", "circle"),
            (IconProvider.clockRotateLeft, "ic-Clock-rotate-left", "clockRotateLeft"),
            (IconProvider.clock, "ic-Clock", "clock"),
            (IconProvider.cloud, "ic-Cloud", "cloud"),
            (IconProvider.code, "ic-Code", "code"),
            (IconProvider.cogWheel, "ic-Cog-wheel", "cogWheel"),
            (IconProvider.creditCard, "ic-Credit-card", "creditCard"),
            (IconProvider.crossSmall, "ic-Cross_small", "crossSmall"),
            (IconProvider.crossCircleFilled, "ic-Cross-circle-filled", "crossCircleFilled"),
            (IconProvider.crossCircle, "ic-Cross-circle", "crossCircle"),
            (IconProvider.crossTiny, "ic-Cross-tiny", "crossTiny"),
            (IconProvider.cross, "ic-Cross", "cross"),
            (IconProvider.drive, "ic-Drive", "drive"),
            (IconProvider.earth, "ic-Earth", "earth"),
            (IconProvider.envelopeArrowUpAndRight,"ic-Envelope-arrow-up-and-right", "envelopeArrowUpAndRight"),
            (IconProvider.envelopeCross, "ic-Envelope-cross", "envelopeCross"),
            (IconProvider.envelopeDot, "ic-Envelope-dot", "envelopeDot"),
            (IconProvider.envelopeOpenText, "ic-Envelope-open-text", "envelopeOpenText"),
            (IconProvider.envelopeOpen, "ic-Envelope-open", "envelopeOpen"),
            (IconProvider.envelope, "ic-Envelope", "envelope"),
            (IconProvider.envelopes, "ic-Envelopes", "envelopes"),
            (IconProvider.eraser, "ic-Eraser", "eraser"),
            (IconProvider.exclamationCircleFilled, "ic-Exclamation-circle-filled", "exclamationCircleFilled"),
            (IconProvider.exclamationCircle, "ic-Exclamation-circle", "exclamationCircle"),
            (IconProvider.eyeSlash, "ic-Eye-slash", "eyeSlash"),
            (IconProvider.eye, "ic-Eye", "eye"),
            (IconProvider.fileArrowInUp, "ic-File-arrow-in-up", "fileArrowInUp"),
            (IconProvider.fileArrowIn, "ic-File-arrow-in", "fileArrowIn"),
            (IconProvider.fileArrowOut, "ic-File-arrow-out", "fileArrowOut"),
            (IconProvider.fileImage, "ic-File-image", "fileImage"),
            (IconProvider.file, "ic-File", "file"),
            (IconProvider.fillingCabinet, "ic-Filling-cabinet", "fillingCabinet"),
            (IconProvider.filter, "ic-Filter", "filter"),
            (IconProvider.fireSlash, "ic-Fire-slash", "fireSlash"),
            (IconProvider.fire, "ic-Fire", "fire"),
            (IconProvider.folderArrowInFilled, "ic-Folder-arrow-in-filled", "folderArrowInFilled"),
            (IconProvider.folderArrowIn, "ic-Folder-arrow-in", "folderArrowIn"),
            (IconProvider.folderFilled, "ic-Folder-filled", "folderFilled"),
            (IconProvider.folderOpenFilled, "ic-Folder-open-filled", "folderOpenFilled"),
            (IconProvider.folderOpen, "ic-Folder-open", "folderOpen"),
            (IconProvider.folderPlus, "ic-Folder-plus", "folderPlus"),
            (IconProvider.folder, "ic-Folder", "folder"),
            (IconProvider.foldersFilled, "ic-Folders-filled", "foldersFilled"),
            (IconProvider.folders, "ic-Folders", "folders"),
            (IconProvider.gift, "ic-Gift", "gift"),
            (IconProvider.globe, "ic-Globe", "globe"),
            (IconProvider.grid2, "ic-Grid-2", "grid2"),
            (IconProvider.grid3, "ic-Grid-3", "grid3"),
            (IconProvider.hamburger, "ic-Hamburger", "hamburger"),
            (IconProvider.hook, "ic-Hook", "hook"),
            (IconProvider.hourglass, "ic-Hourglass", "hourglass"),
            (IconProvider.houseFilled, "ic-House-filled", "houseFilled"),
            (IconProvider.house, "ic-House", "house"),
            (IconProvider.image, "ic-Image", "image"),
            (IconProvider.inbox, "ic-Inbox", "inbox"),
            (IconProvider.infoCircleFilled, "ic-Info-circle-filled", "infoCircleFilled"),
            (IconProvider.infoCircle, "ic-Info-circle", "infoCircle"),
            (IconProvider.keySkeleton, "ic-Key-skeleton", "keySkeleton"),
            (IconProvider.key, "ic-Key", "key"),
            (IconProvider.language, "ic-Language", "language"),
            (IconProvider.lifeRing, "ic-Life-ring", "lifeRing"),
            (IconProvider.lightbulb, "ic-Lightbulb", "lightbulb"),
            (IconProvider.linesLongToSmall, "ic-Lines-long-to-small", "linesLongToSmall"),
            (IconProvider.linesVertical, "ic-Lines-vertical", "linesVertical"),
            (IconProvider.linkPen, "ic-Link-pen", "linkPen"),
            (IconProvider.linkSlash, "ic-Link-slash", "linkSlash"),
            (IconProvider.link, "ic-Link", "link"),
            (IconProvider.listBullets, "ic-List-bullets", "listBullets"),
            (IconProvider.listNumbers, "ic-List-numbers", "listNumbers"),
            (IconProvider.lockFilled, "ic-Lock-filled", "lockFilled"),
            (IconProvider.lock, "ic-Lock", "lock"),
            (IconProvider.lowDash, "ic-Low-dash", "lowDash"),
            (IconProvider.magnifier, "ic-Magnifier", "magnifier"),
            (IconProvider.mapPin, "ic-Map-pin", "mapPin"),
            (IconProvider.minusCircle, "ic-Minus-circle", "minusCircle"),
            (IconProvider.mobilePlus, "ic-Mobile-plus", "mobilePlus"),
            (IconProvider.mobile, "ic-Mobile", "mobile"),
            (IconProvider.notepadChecklist, "ic-Notepad-checklist", "notepadChecklist"),
            (IconProvider.paintRoller, "ic-Paint-roller", "paintRoller"),
            (IconProvider.palette, "ic-Palette", "palette"),
            (IconProvider.paperClipVertical, "ic-Paper-clip-vertical", "paperClipVertical"),
            (IconProvider.paperClip, "ic-Paper-clip", "paperClip"),
            (IconProvider.paperPlaneHorizontal, "ic-Paper-plane-horizontal", "paperPlaneHorizontal"),
            (IconProvider.paperPlane, "ic-Paper-plane", "paperPlane"),
            (IconProvider.pause, "ic-Pause", "pause"),
            (IconProvider.penSquare, "ic-Pen-square", "penSquare"),
            (IconProvider.pen, "ic-Pen", "pen"),
            (IconProvider.pencil, "ic-Pencil", "pencil"),
            (IconProvider.phone, "ic-Phone", "phone"),
            (IconProvider.play, "ic-play", "play"),
            (IconProvider.plusCircleFilled, "ic-Plus-circle-filled", "plusCircleFilled"),
            (IconProvider.plusCircle, "ic-Plus-circle", "plusCircle"),
            (IconProvider.plus, "ic-Plus", "plus"),
            (IconProvider.powerOff, "ic-Power-off", "powerOff"),
            (IconProvider.printer, "ic-Printer", "printer"),
            (IconProvider.questionCircleFilled, "ic-Question-circle-filled", "questionCircleFilled"),
            (IconProvider.questionCircle, "ic-Question-circle", "questionCircle"),
            (IconProvider.rocket, "ic-Rocket", "rocket"),
            (IconProvider.servers, "ic-Servers", "servers"),
            (IconProvider.shield, "ic-Shield", "shield"),
            (IconProvider.speechBubble, "ic-Speech-bubble", "speechBubble"),
            (IconProvider.squares, "ic-Squares", "squares"),
            (IconProvider.starFilled, "ic-Star-filled", "starFilled"),
            (IconProvider.starSlash, "ic-Star-slash", "starSlash"),
            (IconProvider.star, "ic-Star", "star"),
            (IconProvider.storage, "ic-Storage", "storage"),
            (IconProvider.tagFilled, "ic-Tag-filled", "tagFilled"),
            (IconProvider.tagPlus, "ic-Tag-plus", "tagPlus"),
            (IconProvider.tag, "ic-Tag", "tag"),
            (IconProvider.tags, "ic-Tags", "tags"),
            (IconProvider.textAlignCenter, "ic-Text-align-center", "textAlignCenter"),
            (IconProvider.textAlignJustify, "ic-Text-align-justify", "textAlignJustify"),
            (IconProvider.textAlignLeft, "ic-Text-align-left", "textAlignLeft"),
            (IconProvider.textAlignRight, "ic-Text-align-right", "textAlignRight"),
            (IconProvider.textBold, "ic-Text-bold", "textBold"),
            (IconProvider.textItalic, "ic-Text-italic", "textItalic"),
            (IconProvider.textQuote, "ic-Text-quote", "textQuote"),
            (IconProvider.textUnderline, "ic-Text-underline", "textUnderline"),
            (IconProvider.threeDotsHorizontal, "ic-three-dots-horizontal", "threeDotsHorizontal"),
            (IconProvider.threeDotsVertical, "ic-three-dots-vertical", "threeDotsVertical"),
            (IconProvider.trashCrossFilled, "ic-Trash-cross-filled", "trashCrossFilled"),
            (IconProvider.trashCross, "ic-Trash-cross", "trashCross"),
            (IconProvider.trash, "ic-Trash", "trash"),
            (IconProvider.userArrowLeft, "ic-User-arrow-left", "userArrowLeft"),
            (IconProvider.userArrowRight, "ic-User-arrow-right", "userArrowRight"),
            (IconProvider.userCircle, "ic-User-circle", "userCircle"),
            (IconProvider.userFilled, "ic-User-filled", "userFilled"),
            (IconProvider.userPlus, "ic-User-plus", "userPlus"),
            (IconProvider.user, "ic-User", "user"),
            (IconProvider.usersFilled, "ic-Users-filled", "usersFilled"),
            (IconProvider.usersMerge, "ic-Users-merge", "usersMerge"),
            (IconProvider.usersPlus, "ic-Users-plus", "usersPlus"),
            (IconProvider.users, "ic-Users", "users"),
            (IconProvider.vault, "ic-Vault", "vault"),
            (IconProvider.windowTerminal, "ic-Window-terminal", "windowTerminal")
        ]),
        ("Logos — MasterBrand", [
            (IconProvider.masterBrandBrand, "MasterBrand Variant=Brand", "masterBrandBrand"),
            (IconProvider.masterBrandDark, "MasterBrand Variant=Dark", "masterBrandDark"),
            (IconProvider.masterBrandGlyph, "MasterBrand Variant=Glyph", "masterBrandGlyph"),
            (IconProvider.masterBrandLight, "MasterBrand Variant=Light", "masterBrandLight"),
            (IconProvider.masterBrandWithEffect, "MasterBrand Variant=WithEffect", "masterBrandWithEffect")
        ]),
        ("Logos — SuiteIcons", [
            (IconProvider.calendarMain, "CalendarMain", "calendarMain"),
            (IconProvider.calendarMainTransparent, "CalendarMainTransparent", "calendarMainTransparent"),
            (IconProvider.calendarStroke, "CalendarStroke", "calendarStroke"),
            (IconProvider.calendarV4, "CalendarV4", "calendarV4"),
            (IconProvider.driveMain, "DriveMain", "driveMain"),
            (IconProvider.driveMainTransparent, "DriveMainTransparent", "driveMainTransparent"),
            (IconProvider.driveStroke, "DriveStroke", "driveStroke"),
            (IconProvider.driveV4, "DriveV4", "driveV4"),
            (IconProvider.mailMain, "MailMain", "mailMain"),
            (IconProvider.mailMainTransparent, "MailMainTransparent", "mailMainTransparent"),
            (IconProvider.mailStroke, "MailStroke", "mailStroke"),
            (IconProvider.mailV4, "MailV4", "mailV4"),
            (IconProvider.vpnMain, "VPNMain", "vpnMain"),
            (IconProvider.vpnMainTransparent, "VPNMainTransparent", "vpnMainTransparent"),
            (IconProvider.vpnStroke, "VPNStroke", "vpnStroke"),
            (IconProvider.vpnV4, "VPNV4", "vpnV4")
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
        ])
    ]
}

extension UIFoundationsIconsViewController: UICollectionViewDelegateFlowLayout {
    
}

extension UIFoundationsIconsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data[section].1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "UIFoundationsIconsViewController.icon", for: indexPath
        )
        guard let iconCell = cell as? IconCollectionViewCell else { return cell }
        iconCell.icon = data[indexPath.section].1[indexPath.row].0
        iconCell.text = "figma: \(data[indexPath.section].1[indexPath.row].1) \ncode: \(data[indexPath.section].1[indexPath.row].2)"
        return iconCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "UIFoundationsIconsViewController.title", for: indexPath
        )
        guard let label = view as? LabelReusableView else { return view }
        label.text = data[indexPath.section].0
        return label
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.size.width, height: 50.0)
    }
}

final class IconCollectionViewCell: UICollectionViewCell {
    
    private let image = UIImageView()
    private let label = UILabel()
    
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    var icon: UIImage? {
        get { image.image }
        set { image.image = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = ColorProvider.BackgroundNorm
        addSubview(image)
        image.centerXInSuperview()
        image.contentMode = .scaleAspectFit
        image.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor).isActive = true
        image.heightAnchor.constraint(lessThanOrEqualToConstant: 100.0).isActive = true
        image.tintColor = ColorProvider.IconNorm
        image.topAnchor.constraint(equalTo: topAnchor).isActive = true
        addSubview(label)
        label.textColor = ColorProvider.TextWeak
        label.numberOfLines = 2
        label.textAlignment = .center
        label.centerXInSuperview()
        label.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0).isActive = true
        label.backgroundColor = ColorProvider.BackgroundNorm
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



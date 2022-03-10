//
//  UIFoundationsColorsViewController.swift
//  ExampleApp-V5 - Created on 02/03/2022.
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

final class UIFoundationsColorsViewController: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    private var appearanceObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Colors"
        collectionView.register(
            ColorCollectionViewCell.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ColorCollectionViewCell")
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
            layout.itemSize = CGSize(width: 256, height: 64)
            layout.sectionInset = .init(top: 32, left: 32, bottom: 32, right: 32)
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

#if canImport(ProtonCore_CoreTranslation_V5)
    let data: [(String, [(() -> NSColor, String)])] = [
        ("Backdrop", [
            ({ ColorProvider.BackdropNorm }, "ProtonCarbonBackdropNorm")
        ]),
        
        ("Background", [
            ({ ColorProvider.BackgroundNorm }, "ProtonCarbonBackgroundNorm"),
            ({ ColorProvider.BackgroundStrong }, "ProtonCarbonBackgroundStrong"),
            ({ ColorProvider.BackgroundWeak }, "ProtonCarbonBackgroundWeak")
        ]),
        
        ("Border", [
            ({ ColorProvider.BorderNorm }, "ProtonCarbonBorderNorm"),
            ({ ColorProvider.BorderWeak }, "ProtonCarbonBorderWeak")
        ]),
        
        ("Field", [
            ({ ColorProvider.FieldDisabled }, "ProtonCarbonFieldDisabled"),
            ({ ColorProvider.FieldFocus }, "ProtonCarbonFieldFocus"),
            ({ ColorProvider.FieldHighlight }, "ProtonCarbonFieldHighlight"),
            ({ ColorProvider.FieldHighlightError }, "ProtonCarbonFieldHighlightError"),
            ({ ColorProvider.FieldHover }, "ProtonCarbonFieldHover"),
            ({ ColorProvider.FieldNorm }, "ProtonCarbonFieldNorm")
        ]),
        
        ("Interaction", [
            ({ ColorProvider.InteractionDefault }, "ProtonCarbonInteractionDefault"),
            ({ ColorProvider.InteractionDefaultActive }, "ProtonCarbonInteractionDefaultActive"),
            ({ ColorProvider.InteractionDefaultHover }, "ProtonCarbonInteractionDefaultHover"),
            ({ ColorProvider.InteractionNorm }, "ProtonCarbonInteractionNorm"),
            ({ ColorProvider.InteractionNormActive }, "ProtonCarbonInteractionNormActive"),
            ({ ColorProvider.InteractionNormHover }, "ProtonCarbonInteractionNormHover"),
            ({ ColorProvider.InteractionWeak }, "ProtonCarbonInteractionWeak"),
            ({ ColorProvider.InteractionWeakActive }, "ProtonCarbonInteractionWeakActive"),
            ({ ColorProvider.InteractionWeakHover }, "ProtonCarbonInteractionWeakHover")
        ]),
        
        ("Link", [
            ({ ColorProvider.LinkActive }, "ProtonCarbonLinkActive"),
            ({ ColorProvider.LinkHover }, "ProtonCarbonLinkHover"),
            ({ ColorProvider.LinkNorm }, "ProtonCarbonLinkNorm")
        ]),
        
        ("Primary", [
            ({ ColorProvider.Primary }, "ProtonCarbonPrimary")
        ]),
        
        ("Shade", [
            ({ ColorProvider.Shade0 }, "ProtonCarbonShade0"),
            ({ ColorProvider.Shade10 }, "ProtonCarbonShade10"),
            ({ ColorProvider.Shade20 }, "ProtonCarbonShade20"),
            ({ ColorProvider.Shade40 }, "ProtonCarbonShade40"),
            ({ ColorProvider.Shade50 }, "ProtonCarbonShade50"),
            ({ ColorProvider.Shade60 }, "ProtonCarbonShade60"),
            ({ ColorProvider.Shade80 }, "ProtonCarbonShade80"),
            ({ ColorProvider.Shade100 }, "ProtonCarbonShade100")
        ]),
        
        ("Shadow", [
            ({ ColorProvider.ShadowLifted }, "ProtonCarbonShadowLifted"),
            ({ ColorProvider.ShadowNorm }, "ProtonCarbonShadowNorm")
        ]),
        
        ("Signal", [
            ({ ColorProvider.SignalDanger }, "ProtonCarbonSignalDanger"),
            ({ ColorProvider.SignalDangerActive }, "ProtonCarbonSignalDangerActive"),
            ({ ColorProvider.SignalDangerHover }, "ProtonCarbonSignalDangerHover"),
            ({ ColorProvider.SignalInfo }, "ProtonCarbonSignalInfo"),
            ({ ColorProvider.SignalInfoActive }, "ProtonCarbonSignalInfoActive"),
            ({ ColorProvider.SignalInfoHover }, "ProtonCarbonSignalInfoHover"),
            ({ ColorProvider.SignalSuccess }, "ProtonCarbonSignalSuccess"),
            ({ ColorProvider.SignalSuccessActive }, "ProtonCarbonSignalSuccessActive"),
            ({ ColorProvider.SignalSuccessHover }, "ProtonCarbonSignalSuccessHover"),
            ({ ColorProvider.SignalWarning }, "ProtonCarbonSignalWarning"),
            ({ ColorProvider.SignalWarningActive }, "ProtonCarbonSignalWarningActive"),
            ({ ColorProvider.SignalWarningHover }, "ProtonCarbonSignalWarningHover")
        ]),
        
        ("Text", [
            ({ ColorProvider.TextDisabled }, "ProtonCarbonTextDisabled"),
            ({ ColorProvider.TextHint }, "ProtonCarbonTextHint"),
            ({ ColorProvider.TextInvert }, "ProtonCarbonTextInvert"),
            ({ ColorProvider.TextNorm }, "ProtonCarbonTextNorm"),
            ({ ColorProvider.TextWeak }, "ProtonCarbonTextWeak")
        ])
    ]
    
    #else
    
    let data: [(String, [(() -> NSColor, String)])] = [
        ("Brand", [
            ({ ColorProvider.BrandDarken40 }, "BrandDarken40"),
            ({ ColorProvider.BrandDarken20 }, "BrandDarken20"),
            ({ ColorProvider.BrandNorm }, "BrandNorm"),
            ({ ColorProvider.BrandLighten20 }, "BrandLighten20"),
            ({ ColorProvider.BrandLighten40 }, "BrandLighten40")
        ]),
        
        ("Notification", [
            ({ ColorProvider.NotificationError }, "NotificationError"),
            ({ ColorProvider.NotificationWarning }, "NotificationWarning"),
            ({ ColorProvider.NotificationSuccess }, "NotificationSuccess"),
            ({ ColorProvider.NotificationNorm }, "NotificationNorm")
        ]),
        
        ("Interaction norm", [
            ({ ColorProvider.InteractionNorm }, "InteractionNorm"),
            ({ ColorProvider.InteractionNormPressed }, "InteractionNormPressed"),
            ({ ColorProvider.InteractionNormDisabled }, "InteractionNormDisabled")
        ]),
        
        ("Shade", [
            ({ ColorProvider.Shade100 }, "Shade100"),
            ({ ColorProvider.Shade80 }, "Shade80"),
            ({ ColorProvider.Shade60 }, "Shade60"),
            ({ ColorProvider.Shade50 }, "Shade50"),
            ({ ColorProvider.Shade40 }, "Shade40"),
            ({ ColorProvider.Shade20 }, "Shade20"),
            ({ ColorProvider.Shade10 }, "Shade10"),
            ({ ColorProvider.Shade0 }, "Shade0")
        ]),
        
        ("Text", [
            ({ ColorProvider.TextNorm }, "TextNorm"),
            ({ ColorProvider.TextWeak }, "TextWeak"),
            ({ ColorProvider.TextHint }, "TextHint"),
            ({ ColorProvider.TextDisabled }, "TextDisabled"),
            ({ ColorProvider.TextInverted }, "TextInverted")
        ]),
        
        ("Icon", [
            ({ ColorProvider.IconNorm }, "IconNorm"),
            ({ ColorProvider.IconWeak }, "IconWeak"),
            ({ ColorProvider.IconHint }, "IconHint"),
            ({ ColorProvider.IconDisabled }, "IconDisabled"),
            ({ ColorProvider.IconInverted }, "IconInverted")
        ]),
        
        ("Interaction", [
            ({ ColorProvider.InteractionWeak }, "InteractionWeak"),
            ({ ColorProvider.InteractionWeakPressed }, "InteractionWeakPressed"),
            ({ ColorProvider.InteractionWeakDisabled }, "InteractionWeakDisabled"),
            ({ ColorProvider.InteractionStrong }, "InteractionStrong"),
            ({ ColorProvider.InteractionStrongPressed }, "InteractionStrongPressed")
        ]),
        
        ("Floaty", [
            ({ ColorProvider.FloatyBackground }, "FloatyBackground"),
            ({ ColorProvider.FloatyPressed }, "FloatyPressed"),
            ({ ColorProvider.FloatyText }, "FloatyText")
        ]),
        
        ("Background", [
            ({ ColorProvider.BackgroundNorm }, "BackgroundNorm"),
            ({ ColorProvider.BackgroundSecondary }, "BackgroundSecondary")
        ]),
        
        ("Separator", [
            ({ ColorProvider.SeparatorNorm }, "SeparatorNorm")
        ]),
        
        ("Sidebar", [
            ({ ColorProvider.SidebarBackground }, "SidebarBackground"),
            ({ ColorProvider.SidebarInteractionWeakNorm }, "SidebarInteractionWeakNorm"),
            ({ ColorProvider.SidebarInteractionWeakPressed }, "SidebarInteractionWeakPressed"),
            ({ ColorProvider.SidebarSeparator }, "SidebarSeparator"),
            ({ ColorProvider.SidebarTextNorm }, "SidebarTextNorm"),
            ({ ColorProvider.SidebarTextWeak }, "SidebarTextWeak"),
            ({ ColorProvider.SidebarIconNorm }, "SidebarIconNorm"),
            ({ ColorProvider.SidebarIconWeak }, "SidebarIconWeak"),
            ({ ColorProvider.SidebarInteractionPressed }, "SidebarInteractionPressed")
        ]),
        
        ("Blenders", [
            ({ ColorProvider.BlenderNorm }, "BlenderNorm")
        ])
    ]
    #endif
}

extension UIFoundationsColorsViewController: NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        data[section].1.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ColorCollectionViewCell"),
            for: indexPath
        )
        let color: NSColor = data[indexPath.section].1[indexPath.item].0()
        item.view.layer?.backgroundColor = color.cgColor
        (item as? ColorCollectionViewCell)?.setText(data[indexPath.section].1[indexPath.item].1)
        return item
    }
}

extension UIFoundationsColorsViewController: NSCollectionViewDelegate {
    
}

final class ColorCollectionViewCell: NSCollectionViewItem {
    
    private let label = NSTextField()

    override func loadView() {
        view = NSView(frame: NSRect(origin: .zero, size: NSSize(width: 300, height: 100)))
        view.wantsLayer = true
        view.makeBackingLayer()
        view.addSubview(label)
        label.isEditable = false
        label.isSelectable = true
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: view.widthAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setText(_ text: String) {
        label.stringValue = text
    }
    
}

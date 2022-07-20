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
        view.layer?.backgroundColor = ColorProvider.BackgroundNorm
        collectionView.backgroundColors = [ColorProvider.BackgroundNorm]
        
        if #available(macOS 10.14, *) {
            appearanceObserver = NSApp.observe(\.effectiveAppearance) { [weak self] _, _ in
                self?.collectionView.reloadData()
                self?.view.layer?.backgroundColor = ColorProvider.BackgroundNorm
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
    let data: [(String, [(() -> NSColor, CGColor, String)])] = [
        ("Backdrop", [
            ({ ColorProvider.BackdropNorm }, ColorProvider.BackdropNorm, "ProtonCarbonBackdropNorm")
        ]),
        
        ("Background", [
            ({ ColorProvider.BackgroundNorm }, ColorProvider.BackgroundNorm, "ProtonCarbonBackgroundNorm"),
            ({ ColorProvider.BackgroundStrong }, ColorProvider.BackgroundStrong, "ProtonCarbonBackgroundStrong"),
            ({ ColorProvider.BackgroundWeak }, ColorProvider.BackgroundWeak, "ProtonCarbonBackgroundWeak")
        ]),
        
        ("Border", [
            ({ ColorProvider.BorderNorm }, ColorProvider.BorderNorm, "ProtonCarbonBorderNorm"),
            ({ ColorProvider.BorderWeak }, ColorProvider.BorderWeak, "ProtonCarbonBorderWeak")
        ]),
        
        ("Field", [
            ({ ColorProvider.FieldDisabled }, ColorProvider.FieldDisabled, "ProtonCarbonFieldDisabled"),
            ({ ColorProvider.FieldFocus }, ColorProvider.FieldFocus, "ProtonCarbonFieldFocus"),
            ({ ColorProvider.FieldHighlight }, ColorProvider.FieldHighlight, "ProtonCarbonFieldHighlight"),
            ({ ColorProvider.FieldHighlightError }, ColorProvider.FieldHighlightError, "ProtonCarbonFieldHighlightError"),
            ({ ColorProvider.FieldHover }, ColorProvider.FieldHover, "ProtonCarbonFieldHover"),
            ({ ColorProvider.FieldNorm }, ColorProvider.FieldNorm, "ProtonCarbonFieldNorm")
        ]),
        
        ("Interaction", [
            ({ ColorProvider.InteractionDefault }, ColorProvider.InteractionDefault, "ProtonCarbonInteractionDefault"),
            ({ ColorProvider.InteractionDefaultActive }, ColorProvider.InteractionDefaultActive, "ProtonCarbonInteractionDefaultActive"),
            ({ ColorProvider.InteractionDefaultHover }, ColorProvider.InteractionDefaultHover, "ProtonCarbonInteractionDefaultHover"),
            ({ ColorProvider.InteractionNorm }, ColorProvider.InteractionNorm, "ProtonCarbonInteractionNorm"),
            ({ ColorProvider.InteractionNormActive }, ColorProvider.InteractionNormActive, "ProtonCarbonInteractionNormActive"),
            ({ ColorProvider.InteractionNormHover }, ColorProvider.InteractionNormHover, "ProtonCarbonInteractionNormHover"),
            ({ ColorProvider.InteractionWeak }, ColorProvider.InteractionWeak, "ProtonCarbonInteractionWeak"),
            ({ ColorProvider.InteractionWeakActive }, ColorProvider.InteractionWeakActive, "ProtonCarbonInteractionWeakActive"),
            ({ ColorProvider.InteractionWeakHover }, ColorProvider.InteractionWeakHover, "ProtonCarbonInteractionWeakHover")
        ]),
        
        ("Link", [
            ({ ColorProvider.LinkActive }, ColorProvider.LinkActive, "ProtonCarbonLinkActive"),
            ({ ColorProvider.LinkHover }, ColorProvider.LinkHover, "ProtonCarbonLinkHover"),
            ({ ColorProvider.LinkNorm }, ColorProvider.LinkNorm, "ProtonCarbonLinkNorm")
        ]),
        
        ("Primary", [
            ({ ColorProvider.Primary }, ColorProvider.Primary, "ProtonCarbonPrimary")
        ]),
        
        ("Shade", [
            ({ ColorProvider.Shade0 }, ColorProvider.Shade0, "ProtonCarbonShade0"),
            ({ ColorProvider.Shade10 }, ColorProvider.Shade10, "ProtonCarbonShade10"),
            ({ ColorProvider.Shade20 }, ColorProvider.Shade20, "ProtonCarbonShade20"),
            ({ ColorProvider.Shade40 }, ColorProvider.Shade40, "ProtonCarbonShade40"),
            ({ ColorProvider.Shade50 }, ColorProvider.Shade50, "ProtonCarbonShade50"),
            ({ ColorProvider.Shade60 }, ColorProvider.Shade60, "ProtonCarbonShade60"),
            ({ ColorProvider.Shade80 }, ColorProvider.Shade80, "ProtonCarbonShade80"),
            ({ ColorProvider.Shade100 }, ColorProvider.Shade100, "ProtonCarbonShade100")
        ]),
        
        ("Shadow", [
            ({ ColorProvider.ShadowLifted }, ColorProvider.ShadowLifted, "ProtonCarbonShadowLifted"),
            ({ ColorProvider.ShadowNorm }, ColorProvider.ShadowNorm, "ProtonCarbonShadowNorm")
        ]),
        
        ("Signal", [
            ({ ColorProvider.SignalDanger }, ColorProvider.SignalDanger, "ProtonCarbonSignalDanger"),
            ({ ColorProvider.SignalDangerActive }, ColorProvider.SignalDangerActive, "ProtonCarbonSignalDangerActive"),
            ({ ColorProvider.SignalDangerHover }, ColorProvider.SignalDangerHover, "ProtonCarbonSignalDangerHover"),
            ({ ColorProvider.SignalInfo }, ColorProvider.SignalInfo, "ProtonCarbonSignalInfo"),
            ({ ColorProvider.SignalInfoActive }, ColorProvider.SignalInfoActive, "ProtonCarbonSignalInfoActive"),
            ({ ColorProvider.SignalInfoHover }, ColorProvider.SignalInfoHover, "ProtonCarbonSignalInfoHover"),
            ({ ColorProvider.SignalSuccess }, ColorProvider.SignalSuccess, "ProtonCarbonSignalSuccess"),
            ({ ColorProvider.SignalSuccessActive }, ColorProvider.SignalSuccessActive, "ProtonCarbonSignalSuccessActive"),
            ({ ColorProvider.SignalSuccessHover }, ColorProvider.SignalSuccessHover, "ProtonCarbonSignalSuccessHover"),
            ({ ColorProvider.SignalWarning }, ColorProvider.SignalWarning, "ProtonCarbonSignalWarning"),
            ({ ColorProvider.SignalWarningActive }, ColorProvider.SignalWarningActive, "ProtonCarbonSignalWarningActive"),
            ({ ColorProvider.SignalWarningHover }, ColorProvider.SignalWarningHover, "ProtonCarbonSignalWarningHover")
        ]),
        
        ("Text", [
            ({ ColorProvider.TextDisabled }, ColorProvider.TextDisabled, "ProtonCarbonTextDisabled"),
            ({ ColorProvider.TextHint }, ColorProvider.TextHint, "ProtonCarbonTextHint"),
            ({ ColorProvider.TextInvert }, ColorProvider.TextInvert, "ProtonCarbonTextInvert"),
            ({ ColorProvider.TextNorm }, ColorProvider.TextNorm, "ProtonCarbonTextNorm"),
            ({ ColorProvider.TextWeak }, ColorProvider.TextWeak, "ProtonCarbonTextWeak")
        ]),
        
        ("Accent", [
            ({ ColorProvider.PurpleBase }, ColorProvider.PurpleBase, "PurpleBase"),
            ({ ColorProvider.PurpleBase.computedStrongVariant }, ColorProvider.PurpleBase.computedStrongVariant, "PurpleBase.computedStrongVariant"),
            ({ ColorProvider.PurpleBase.computedIntenseVariant }, ColorProvider.PurpleBase.computedIntenseVariant, "PurpleBase.computedIntenseVariant"),
            
            ({ ColorProvider.EnzianBase }, ColorProvider.EnzianBase, "EnzianBase"),
            ({ ColorProvider.EnzianBase.computedStrongVariant }, ColorProvider.EnzianBase.computedStrongVariant, "EnzianBase.computedStrongVariant"),
            ({ ColorProvider.EnzianBase.computedIntenseVariant }, ColorProvider.EnzianBase.computedIntenseVariant, "EnzianBase.computedIntenseVariant"),
            
            ({ ColorProvider.PinkBase }, ColorProvider.PinkBase, "PinkBase"),
            ({ ColorProvider.PinkBase.computedStrongVariant }, ColorProvider.PinkBase.computedStrongVariant, "PinkBase.computedStrongVariant"),
            ({ ColorProvider.PinkBase.computedIntenseVariant }, ColorProvider.PinkBase.computedIntenseVariant, "PinkBase.computedIntenseVariant"),
            
            ({ ColorProvider.PlumBase }, ColorProvider.PlumBase, "PlumBase"),
            ({ ColorProvider.PlumBase.computedStrongVariant }, ColorProvider.PlumBase.computedStrongVariant, "PlumBase.computedStrongVariant"),
            ({ ColorProvider.PlumBase.computedIntenseVariant }, ColorProvider.PlumBase.computedIntenseVariant, "PlumBase.computedIntenseVariant"),
            
            ({ ColorProvider.StrawberryBase }, ColorProvider.StrawberryBase, "StrawberryBase"),
            ({ ColorProvider.StrawberryBase.computedStrongVariant }, ColorProvider.StrawberryBase.computedStrongVariant, "StrawberryBase.computedStrongVariant"),
            ({ ColorProvider.StrawberryBase.computedIntenseVariant }, ColorProvider.StrawberryBase.computedIntenseVariant, "StrawberryBase.computedIntenseVariant"),
            
            ({ ColorProvider.CeriseBase }, ColorProvider.CeriseBase, "CeriseBase"),
            ({ ColorProvider.CeriseBase.computedStrongVariant }, ColorProvider.CeriseBase.computedStrongVariant, "CeriseBase.computedStrongVariant"),
            ({ ColorProvider.CeriseBase.computedIntenseVariant }, ColorProvider.CeriseBase.computedIntenseVariant, "CeriseBase.computedIntenseVariant"),
            
            ({ ColorProvider.CarrotBase }, ColorProvider.CarrotBase, "CarrotBase"),
            ({ ColorProvider.CarrotBase.computedStrongVariant }, ColorProvider.CarrotBase.computedStrongVariant, "CarrotBase.computedStrongVariant"),
            ({ ColorProvider.CarrotBase.computedIntenseVariant }, ColorProvider.CarrotBase.computedIntenseVariant, "CarrotBase.computedIntenseVariant"),
            
            ({ ColorProvider.CopperBase }, ColorProvider.CopperBase, "CopperBase"),
            ({ ColorProvider.CopperBase.computedStrongVariant }, ColorProvider.CopperBase.computedStrongVariant, "CopperBase.computedStrongVariant"),
            ({ ColorProvider.CopperBase.computedIntenseVariant }, ColorProvider.CopperBase.computedIntenseVariant, "CopperBase.computedIntenseVariant"),
            
            ({ ColorProvider.SaharaBase }, ColorProvider.SaharaBase, "SaharaBase"),
            ({ ColorProvider.SaharaBase.computedStrongVariant }, ColorProvider.SaharaBase.computedStrongVariant, "SaharaBase.computedStrongVariant"),
            ({ ColorProvider.SaharaBase.computedIntenseVariant }, ColorProvider.SaharaBase.computedIntenseVariant, "SaharaBase.computedIntenseVariant"),
            
            ({ ColorProvider.SoilBase }, ColorProvider.SoilBase, "SoilBase"),
            ({ ColorProvider.SoilBase.computedStrongVariant }, ColorProvider.SoilBase.computedStrongVariant, "SoilBase.computedStrongVariant"),
            ({ ColorProvider.SoilBase.computedIntenseVariant }, ColorProvider.SoilBase.computedIntenseVariant, "SoilBase.computedIntenseVariant"),
            
            ({ ColorProvider.SlateblueBase }, ColorProvider.SlateblueBase, "SlateblueBase"),
            ({ ColorProvider.SlateblueBase.computedStrongVariant }, ColorProvider.SlateblueBase.computedStrongVariant, "SlateblueBase.computedStrongVariant"),
            ({ ColorProvider.SlateblueBase.computedIntenseVariant }, ColorProvider.SlateblueBase.computedIntenseVariant, "SlateblueBase.computedIntenseVariant"),
            
            ({ ColorProvider.CobaltBase }, ColorProvider.CobaltBase, "CobaltBase"),
            ({ ColorProvider.CobaltBase.computedStrongVariant }, ColorProvider.CobaltBase.computedStrongVariant, "CobaltBase.computedStrongVariant"),
            ({ ColorProvider.CobaltBase.computedIntenseVariant }, ColorProvider.CobaltBase.computedIntenseVariant, "CobaltBase.computedIntenseVariant"),
            
            ({ ColorProvider.PacificBase }, ColorProvider.PacificBase, "PacificBase"),
            ({ ColorProvider.PacificBase.computedStrongVariant }, ColorProvider.PacificBase.computedStrongVariant, "PacificBase.computedStrongVariant"),
            ({ ColorProvider.PacificBase.computedIntenseVariant }, ColorProvider.PacificBase.computedIntenseVariant, "PacificBase.computedIntenseVariant"),
            
            ({ ColorProvider.OceanBase }, ColorProvider.OceanBase, "OceanBase"),
            ({ ColorProvider.OceanBase.computedStrongVariant }, ColorProvider.OceanBase.computedStrongVariant, "OceanBase.computedStrongVariant"),
            ({ ColorProvider.OceanBase.computedIntenseVariant }, ColorProvider.OceanBase.computedIntenseVariant, "OceanBase.computedIntenseVariant"),
            
            ({ ColorProvider.ReefBase }, ColorProvider.ReefBase, "ReefBase"),
            ({ ColorProvider.ReefBase.computedStrongVariant }, ColorProvider.ReefBase.computedStrongVariant, "ReefBase.computedStrongVariant"),
            ({ ColorProvider.ReefBase.computedIntenseVariant }, ColorProvider.ReefBase.computedIntenseVariant, "ReefBase.computedIntenseVariant"),
            
            ({ ColorProvider.PineBase }, ColorProvider.PineBase, "PineBase"),
            ({ ColorProvider.PineBase.computedStrongVariant }, ColorProvider.PineBase.computedStrongVariant, "PineBase.computedStrongVariant"),
            ({ ColorProvider.PineBase.computedIntenseVariant }, ColorProvider.PineBase.computedIntenseVariant, "PineBase.computedIntenseVariant"),
            
            ({ ColorProvider.FernBase }, ColorProvider.FernBase, "FernBase"),
            ({ ColorProvider.FernBase.computedStrongVariant }, ColorProvider.FernBase.computedStrongVariant, "FernBase.computedStrongVariant"),
            ({ ColorProvider.FernBase.computedIntenseVariant }, ColorProvider.FernBase.computedIntenseVariant, "FernBase.computedIntenseVariant"),
            
            ({ ColorProvider.ForestBase }, ColorProvider.ForestBase, "ForestBase"),
            ({ ColorProvider.ForestBase.computedStrongVariant }, ColorProvider.ForestBase.computedStrongVariant, "ForestBase.computedStrongVariant"),
            ({ ColorProvider.ForestBase.computedIntenseVariant }, ColorProvider.ForestBase.computedIntenseVariant, "ForestBase.computedIntenseVariant"),
            
            ({ ColorProvider.OliveBase }, ColorProvider.OliveBase, "OliveBase"),
            ({ ColorProvider.OliveBase.computedStrongVariant }, ColorProvider.OliveBase.computedStrongVariant, "OliveBase.computedStrongVariant"),
            ({ ColorProvider.OliveBase.computedIntenseVariant }, ColorProvider.OliveBase.computedIntenseVariant, "OliveBase.computedIntenseVariant"),
            
            ({ ColorProvider.PickleBase }, ColorProvider.PickleBase, "PickleBase"),
            ({ ColorProvider.PickleBase.computedStrongVariant }, ColorProvider.PickleBase.computedStrongVariant, "PickleBase.computedStrongVariant"),
            ({ ColorProvider.PickleBase.computedIntenseVariant }, ColorProvider.PickleBase.computedIntenseVariant, "PickleBase.computedIntenseVariant")
        ])
    ]
    
    #else
    
    let data: [(String, [(() -> NSColor, CGColor, String)])] = [
        ("Brand", [
            ({ ColorProvider.BrandDarken40 }, ColorProvider.BrandDarken40, "BrandDarken40"),
            ({ ColorProvider.BrandDarken20 }, ColorProvider.BrandDarken20, "BrandDarken20"),
            ({ ColorProvider.BrandNorm }, ColorProvider.BrandNorm, "BrandNorm"),
            ({ ColorProvider.BrandLighten20 }, ColorProvider.BrandLighten20, "BrandLighten20"),
            ({ ColorProvider.BrandLighten40 }, ColorProvider.BrandLighten40, "BrandLighten40")
        ]),
        
        ("Notification", [
            ({ ColorProvider.NotificationError }, ColorProvider.NotificationError, "NotificationError"),
            ({ ColorProvider.NotificationWarning }, ColorProvider.NotificationWarning, "NotificationWarning"),
            ({ ColorProvider.NotificationSuccess }, ColorProvider.NotificationSuccess, "NotificationSuccess"),
            ({ ColorProvider.NotificationNorm }, ColorProvider.NotificationNorm, "NotificationNorm")
        ]),
        
        ("Interaction norm", [
            ({ ColorProvider.InteractionNorm }, ColorProvider.InteractionNorm, "InteractionNorm"),
            ({ ColorProvider.InteractionNormPressed }, ColorProvider.InteractionNormPressed, "InteractionNormPressed"),
            ({ ColorProvider.InteractionNormDisabled }, ColorProvider.InteractionNormDisabled, "InteractionNormDisabled")
        ]),
        
        ("Shade", [
            ({ ColorProvider.Shade100 }, ColorProvider.Shade100, "Shade100"),
            ({ ColorProvider.Shade80 }, ColorProvider.Shade80, "Shade80"),
            ({ ColorProvider.Shade60 }, ColorProvider.Shade60, "Shade60"),
            ({ ColorProvider.Shade50 }, ColorProvider.Shade50, "Shade50"),
            ({ ColorProvider.Shade40 }, ColorProvider.Shade40, "Shade40"),
            ({ ColorProvider.Shade20 }, ColorProvider.Shade20, "Shade20"),
            ({ ColorProvider.Shade10 }, ColorProvider.Shade10, "Shade10"),
            ({ ColorProvider.Shade0 }, ColorProvider.Shade0, "Shade0")
        ]),
        
        ("Text", [
            ({ ColorProvider.TextNorm }, ColorProvider.TextNorm, "TextNorm"),
            ({ ColorProvider.TextWeak }, ColorProvider.TextWeak, "TextWeak"),
            ({ ColorProvider.TextHint }, ColorProvider.TextHint, "TextHint"),
            ({ ColorProvider.TextDisabled }, ColorProvider.TextDisabled, "TextDisabled"),
            ({ ColorProvider.TextInverted }, ColorProvider.TextInverted, "TextInverted")
        ]),
        
        ("Icon", [
            ({ ColorProvider.IconNorm }, ColorProvider.IconNorm, "IconNorm"),
            ({ ColorProvider.IconWeak }, ColorProvider.IconWeak, "IconWeak"),
            ({ ColorProvider.IconHint }, ColorProvider.IconHint, "IconHint"),
            ({ ColorProvider.IconDisabled }, ColorProvider.IconDisabled, "IconDisabled"),
            ({ ColorProvider.IconInverted }, ColorProvider.IconInverted, "IconInverted")
        ]),
        
        ("Interaction", [
            ({ ColorProvider.InteractionWeak }, ColorProvider.InteractionWeak, "InteractionWeak"),
            ({ ColorProvider.InteractionWeakPressed }, ColorProvider.InteractionWeakPressed, "InteractionWeakPressed"),
            ({ ColorProvider.InteractionWeakDisabled }, ColorProvider.InteractionWeakDisabled, "InteractionWeakDisabled"),
            ({ ColorProvider.InteractionStrong }, ColorProvider.InteractionStrong, "InteractionStrong"),
            ({ ColorProvider.InteractionStrongPressed }, ColorProvider.InteractionStrongPressed, "InteractionStrongPressed")
        ]),
        
        ("Floaty", [
            ({ ColorProvider.FloatyBackground }, ColorProvider.FloatyBackground, "FloatyBackground"),
            ({ ColorProvider.FloatyPressed }, ColorProvider.FloatyPressed, "FloatyPressed"),
            ({ ColorProvider.FloatyText }, ColorProvider.FloatyText, "FloatyText")
        ]),
        
        ("Background", [
            ({ ColorProvider.BackgroundNorm }, ColorProvider.BackgroundNorm, "BackgroundNorm"),
            ({ ColorProvider.BackgroundSecondary }, ColorProvider.BackgroundSecondary, "BackgroundSecondary")
        ]),
        
        ("Separator", [
            ({ ColorProvider.SeparatorNorm }, ColorProvider.SeparatorNorm, "SeparatorNorm")
        ]),
        
        ("Sidebar", [
            ({ ColorProvider.SidebarBackground }, ColorProvider.SidebarBackground, "SidebarBackground"),
            ({ ColorProvider.SidebarInteractionWeakNorm }, ColorProvider.SidebarInteractionWeakNorm, "SidebarInteractionWeakNorm"),
            ({ ColorProvider.SidebarInteractionWeakPressed }, ColorProvider.SidebarInteractionWeakPressed, "SidebarInteractionWeakPressed"),
            ({ ColorProvider.SidebarSeparator }, ColorProvider.SidebarSeparator, "SidebarSeparator"),
            ({ ColorProvider.SidebarTextNorm }, ColorProvider.SidebarTextNorm, "SidebarTextNorm"),
            ({ ColorProvider.SidebarTextWeak }, ColorProvider.SidebarTextWeak, "SidebarTextWeak"),
            ({ ColorProvider.SidebarIconNorm }, ColorProvider.SidebarIconNorm, "SidebarIconNorm"),
            ({ ColorProvider.SidebarIconWeak }, ColorProvider.SidebarIconWeak, "SidebarIconWeak"),
            ({ ColorProvider.SidebarInteractionPressed }, ColorProvider.SidebarInteractionPressed, "SidebarInteractionPressed")
        ]),
        
        ("Blenders", [
            ({ ColorProvider.BlenderNorm }, ColorProvider.BlenderNorm, "BlenderNorm")
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
        if let item = item as? ColorCollectionViewCell {
            let nsColor: NSColor = data[indexPath.section].1[indexPath.item].0()
            item.leftView.layer?.backgroundColor = nsColor.cgColor
            let cgColor = data[indexPath.section].1[indexPath.item].1
            item.rightView.layer?.backgroundColor = cgColor
            item.setText(data[indexPath.section].1[indexPath.item].2)
            return item
        }
        return item
    }
}

extension UIFoundationsColorsViewController: NSCollectionViewDelegate {
    
}

final class ColorCollectionViewCell: NSCollectionViewItem {
    
    private let label = NSTextField()
    private let container = NSStackView()
    let leftView = NSView()
    let rightView = NSView()

    override func loadView() {
        view = NSView(frame: NSRect(origin: .zero, size: NSSize(width: 300, height: 100)))
        view.wantsLayer = true
        view.makeBackingLayer()
        view.addSubview(label)
        container.wantsLayer = true
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        leftView.translatesAutoresizingMaskIntoConstraints = false
        rightView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            container.leftAnchor.constraint(equalTo: view.leftAnchor),
            container.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        leftView.wantsLayer = true
        rightView.wantsLayer = true
        container.addArrangedSubview(leftView)
        container.addArrangedSubview(rightView)
        container.distribution = .fillEqually
        container.spacing = 8
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

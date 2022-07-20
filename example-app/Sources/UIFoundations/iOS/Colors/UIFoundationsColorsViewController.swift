//
//  UIFoundationsColorsViewController.swift
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

final class UIFoundationsColorsViewController: UIFoundationsAppearanceStyleViewController {
    
    private let layout = UICollectionViewFlowLayout()
    private var collectionView: UICollectionView!
    
    override func loadView() {
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        view = collectionView
    }
    
    override func viewDidLoad() {
        title = "Colors"
        layout.sectionHeadersPinToVisibleBounds = true
        collectionView.register(ColorCollectionViewCell.self,
                                forCellWithReuseIdentifier: "UIFoundationsColorsViewController.color")
        collectionView.register(LabelReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "UIFoundationsColorsViewController.title")
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
    
    let data: [(String, [(UIColor, () -> CGColor, String)])] = [
        ("Brand", [
            (ColorProvider.BrandDarken40, { ColorProvider.BrandDarken40 }, "BrandDarken40"),
            (ColorProvider.BrandDarken20, { ColorProvider.BrandDarken20 }, "BrandDarken20"),
            (ColorProvider.BrandNorm, { ColorProvider.BrandNorm }, "BrandNorm"),
            (ColorProvider.BrandLighten20, { ColorProvider.BrandLighten20 }, "BrandLighten20"),
            (ColorProvider.BrandLighten40, { ColorProvider.BrandLighten40 }, "BrandLighten40")
        ]),
        
        ("Notification", [
            (ColorProvider.NotificationError, { ColorProvider.NotificationError }, "NotificationError"),
            (ColorProvider.NotificationWarning, { ColorProvider.NotificationWarning }, "NotificationWarning"),
            (ColorProvider.NotificationSuccess, { ColorProvider.NotificationSuccess }, "NotificationSuccess"),
            (ColorProvider.NotificationNorm, { ColorProvider.NotificationNorm }, "NotificationNorm")
        ]),
        
        ("Interaction norm", [
            (ColorProvider.InteractionNorm, { ColorProvider.InteractionNorm }, "InteractionNorm"),
            (ColorProvider.InteractionNormPressed, { ColorProvider.InteractionNormPressed }, "InteractionNormPressed"),
            (ColorProvider.InteractionNormDisabled, { ColorProvider.InteractionNormDisabled }, "InteractionNormDisabled")
        ]),
        
        ("Shade", [
            (ColorProvider.Shade100, { ColorProvider.Shade100 }, "Shade100"),
            (ColorProvider.Shade80, { ColorProvider.Shade80 },"Shade80"),
            (ColorProvider.Shade60, { ColorProvider.Shade60 }, "Shade60"),
            (ColorProvider.Shade50, { ColorProvider.Shade50 }, "Shade50"),
            (ColorProvider.Shade40, { ColorProvider.Shade40 }, "Shade40"),
            (ColorProvider.Shade20, { ColorProvider.Shade20 }, "Shade20"),
            (ColorProvider.Shade10, { ColorProvider.Shade10 }, "Shade10"),
            (ColorProvider.Shade0, { ColorProvider.Shade0 }, "Shade0")
        ]),
        
        ("Text", [
            (ColorProvider.TextNorm, { ColorProvider.TextNorm }, "TextNorm"),
            (ColorProvider.TextWeak, { ColorProvider.TextWeak }, "TextWeak"),
            (ColorProvider.TextHint, { ColorProvider.TextHint }, "TextHint"),
            (ColorProvider.TextDisabled, { ColorProvider.TextDisabled }, "TextDisabled"),
            (ColorProvider.TextInverted, { ColorProvider.TextInverted }, "TextInverted")
        ]),
        
        ("Icon", [
            (ColorProvider.IconNorm, { ColorProvider.IconNorm }, "IconNorm"),
            (ColorProvider.IconWeak, { ColorProvider.IconWeak }, "IconWeak"),
            (ColorProvider.IconHint, { ColorProvider.IconHint }, "IconHint"),
            (ColorProvider.IconDisabled, { ColorProvider.IconDisabled }, "IconDisabled"),
            (ColorProvider.IconInverted, { ColorProvider.IconInverted }, "IconInverted")
        ]),
        
        ("Interaction", [
            (ColorProvider.InteractionWeak, { ColorProvider.InteractionWeak }, "InteractionWeak"),
            (ColorProvider.InteractionWeakPressed, { ColorProvider.InteractionWeakPressed }, "InteractionWeakPressed"),
            (ColorProvider.InteractionWeakDisabled, { ColorProvider.InteractionWeakDisabled }, "InteractionWeakDisabled"),
            (ColorProvider.InteractionStrong, { ColorProvider.InteractionStrong }, "InteractionStrong"),
            (ColorProvider.InteractionStrongPressed, { ColorProvider.InteractionStrongPressed }, "InteractionStrongPressed")
        ]),
        
        ("Floaty", [
            (ColorProvider.FloatyBackground, { ColorProvider.FloatyBackground }, "FloatyBackground"),
            (ColorProvider.FloatyPressed, { ColorProvider.FloatyPressed }, "FloatyPressed"),
            (ColorProvider.FloatyText, { ColorProvider.FloatyText }, "FloatyText")
        ]),
        
        ("Background", [
            (ColorProvider.BackgroundNorm, { ColorProvider.BackgroundNorm }, "BackgroundNorm"),
            (ColorProvider.BackgroundSecondary, { ColorProvider.BackgroundSecondary }, "BackgroundSecondary")
        ]),
        
        ("Separator", [
            (ColorProvider.SeparatorNorm, { ColorProvider.SeparatorNorm }, "SeparatorNorm")
        ]),
        
        ("Sidebar", [
            (ColorProvider.SidebarBackground, { ColorProvider.SidebarBackground }, "SidebarBackground"),
            (ColorProvider.SidebarInteractionWeakNorm, { ColorProvider.SidebarInteractionWeakNorm }, "SidebarInteractionWeakNorm"),
            (ColorProvider.SidebarInteractionWeakPressed, { ColorProvider.SidebarInteractionWeakPressed }, "SidebarInteractionWeakPressed"),
            (ColorProvider.SidebarSeparator, { ColorProvider.SidebarSeparator }, "SidebarSeparator"),
            (ColorProvider.SidebarTextNorm, { ColorProvider.SidebarTextNorm }, "SidebarTextNorm"),
            (ColorProvider.SidebarTextWeak, { ColorProvider.SidebarTextWeak }, "SidebarTextWeak"),
            (ColorProvider.SidebarIconNorm, { ColorProvider.SidebarIconNorm }, "SidebarIconNorm"),
            (ColorProvider.SidebarIconWeak, { ColorProvider.SidebarIconWeak }, "SidebarIconWeak"),
            (ColorProvider.SidebarInteractionPressed, { ColorProvider.SidebarInteractionPressed }, "SidebarInteractionPressed")
        ]),
        
        ("Blenders", [
            (ColorProvider.BlenderNorm, { ColorProvider.BlenderNorm }, "BlenderNorm")
        ]),
        
        ("Accent", [
            (ColorProvider.PurpleBase, { ColorProvider.PurpleBase }, "PurpleBase"),
            (ColorProvider.PurpleBase.computedStrongVariant, { ColorProvider.PurpleBase.computedStrongVariant }, "PurpleBase.computedStrongVariant"),
            (ColorProvider.PurpleBase.computedIntenseVariant, { ColorProvider.PurpleBase.computedIntenseVariant }, "PurpleBase.computedIntenseVariant"),
            
            (ColorProvider.EnzianBase, { ColorProvider.EnzianBase} , "EnzianBase"),
            (ColorProvider.EnzianBase.computedStrongVariant, { ColorProvider.EnzianBase.computedStrongVariant }, "EnzianBase.computedStrongVariant"),
            (ColorProvider.EnzianBase.computedIntenseVariant, { ColorProvider.EnzianBase.computedIntenseVariant }, "EnzianBase.computedIntenseVariant"),
            
            (ColorProvider.PinkBase, { ColorProvider.PinkBase} , "PinkBase"),
            (ColorProvider.PinkBase.computedStrongVariant, { ColorProvider.PinkBase.computedStrongVariant }, "PinkBase.computedStrongVariant"),
            (ColorProvider.PinkBase.computedIntenseVariant, { ColorProvider.PinkBase.computedIntenseVariant }, "PinkBase.computedIntenseVariant"),
            
            (ColorProvider.PlumBase, { ColorProvider.PlumBase} , "PlumBase"),
            (ColorProvider.PlumBase.computedStrongVariant, { ColorProvider.PlumBase.computedStrongVariant }, "PlumBase.computedStrongVariant"),
            (ColorProvider.PlumBase.computedIntenseVariant, { ColorProvider.PlumBase.computedIntenseVariant }, "PlumBase.computedIntenseVariant"),
            
            (ColorProvider.StrawberryBase, { ColorProvider.StrawberryBase }, "StrawberryBase"),
            (ColorProvider.StrawberryBase.computedStrongVariant, { ColorProvider.StrawberryBase.computedStrongVariant },  "StrawberryBase.computedStrongVariant"),
            (ColorProvider.StrawberryBase.computedIntenseVariant, { ColorProvider.StrawberryBase.computedIntenseVariant },  "StrawberryBase.computedIntenseVariant"),
            
            (ColorProvider.CeriseBase, { ColorProvider.CeriseBase }, "CeriseBase"),
            (ColorProvider.CeriseBase.computedStrongVariant, { ColorProvider.CeriseBase.computedStrongVariant }, "CeriseBase.computedStrongVariant"),
            (ColorProvider.CeriseBase.computedIntenseVariant, { ColorProvider.CeriseBase.computedIntenseVariant }, "CeriseBase.computedIntenseVariant"),
            
            (ColorProvider.CarrotBase, { ColorProvider.CarrotBase }, "CarrotBase"),
            (ColorProvider.CarrotBase.computedStrongVariant, { ColorProvider.CarrotBase.computedStrongVariant }, "CarrotBase.computedStrongVariant"),
            (ColorProvider.CarrotBase.computedIntenseVariant, { ColorProvider.CarrotBase.computedIntenseVariant }, "CarrotBase.computedIntenseVariant"),
            
            (ColorProvider.CopperBase, { ColorProvider.CopperBase }, "CopperBase"),
            (ColorProvider.CopperBase.computedStrongVariant, { ColorProvider.CopperBase.computedStrongVariant }, "CopperBase.computedStrongVariant"),
            (ColorProvider.CopperBase.computedIntenseVariant, { ColorProvider.CopperBase.computedIntenseVariant }, "CopperBase.computedIntenseVariant"),
            
            (ColorProvider.SaharaBase, { ColorProvider.SaharaBase }, "SaharaBase"),
            (ColorProvider.SaharaBase.computedStrongVariant, { ColorProvider.SaharaBase.computedStrongVariant }, "SaharaBase.computedStrongVariant"),
            (ColorProvider.SaharaBase.computedIntenseVariant, { ColorProvider.SaharaBase.computedIntenseVariant }, "SaharaBase.computedIntenseVariant"),
            
            (ColorProvider.SoilBase, { ColorProvider.SoilBase }, "SoilBase"),
            (ColorProvider.SoilBase.computedStrongVariant, { ColorProvider.SoilBase.computedStrongVariant }, "SoilBase.computedStrongVariant"),
            (ColorProvider.SoilBase.computedIntenseVariant, { ColorProvider.SoilBase.computedIntenseVariant }, "SoilBase.computedIntenseVariant"),
            
            (ColorProvider.SlateblueBase, { ColorProvider.SlateblueBase }, "SlateblueBase"),
            (ColorProvider.SlateblueBase.computedStrongVariant, { ColorProvider.SlateblueBase.computedStrongVariant },  "SlateblueBase.computedStrongVariant"),
            (ColorProvider.SlateblueBase.computedIntenseVariant, { ColorProvider.SlateblueBase.computedIntenseVariant },  "SlateblueBase.computedIntenseVariant"),
            
            (ColorProvider.CobaltBase, { ColorProvider.CobaltBase }, "CobaltBase"),
            (ColorProvider.CobaltBase.computedStrongVariant, { ColorProvider.CobaltBase.computedStrongVariant }, "CobaltBase.computedStrongVariant"),
            (ColorProvider.CobaltBase.computedIntenseVariant, { ColorProvider.CobaltBase.computedIntenseVariant }, "CobaltBase.computedIntenseVariant"),
            
            (ColorProvider.PacificBase, { ColorProvider.PacificBase }, "PacificBase"),
            (ColorProvider.PacificBase.computedStrongVariant, { ColorProvider.PacificBase.computedStrongVariant },  "PacificBase.computedStrongVariant"),
            (ColorProvider.PacificBase.computedIntenseVariant, { ColorProvider.PacificBase.computedIntenseVariant },  "PacificBase.computedIntenseVariant"),
            
            (ColorProvider.OceanBase, { ColorProvider.OceanBase }, "OceanBase"),
            (ColorProvider.OceanBase.computedStrongVariant, { ColorProvider.OceanBase.computedStrongVariant }, "OceanBase.computedStrongVariant"),
            (ColorProvider.OceanBase.computedIntenseVariant, { ColorProvider.OceanBase.computedIntenseVariant }, "OceanBase.computedIntenseVariant"),
            
            (ColorProvider.ReefBase, { ColorProvider.ReefBase }, "ReefBase"),
            (ColorProvider.ReefBase.computedStrongVariant, { ColorProvider.ReefBase.computedStrongVariant }, "ReefBase.computedStrongVariant"),
            (ColorProvider.ReefBase.computedIntenseVariant, { ColorProvider.ReefBase.computedIntenseVariant }, "ReefBase.computedIntenseVariant"),
            
            (ColorProvider.PineBase, { ColorProvider.PineBase }, "PineBase"),
            (ColorProvider.PineBase.computedStrongVariant, { ColorProvider.PineBase.computedStrongVariant }, "PineBase.computedStrongVariant"),
            (ColorProvider.PineBase.computedIntenseVariant, { ColorProvider.PineBase.computedIntenseVariant }, "PineBase.computedIntenseVariant"),
            
            (ColorProvider.FernBase, { ColorProvider.FernBase }, "FernBase"),
            (ColorProvider.FernBase.computedStrongVariant, { ColorProvider.FernBase.computedStrongVariant }, "FernBase.computedStrongVariant"),
            (ColorProvider.FernBase.computedIntenseVariant, { ColorProvider.FernBase.computedIntenseVariant }, "FernBase.computedIntenseVariant"),
            
            (ColorProvider.ForestBase, { ColorProvider.ForestBase }, "ForestBase"),
            (ColorProvider.ForestBase.computedStrongVariant, { ColorProvider.ForestBase.computedStrongVariant }, "ForestBase.computedStrongVariant"),
            (ColorProvider.ForestBase.computedIntenseVariant, { ColorProvider.ForestBase.computedIntenseVariant }, "ForestBase.computedIntenseVariant"),
            
            (ColorProvider.OliveBase, { ColorProvider.OliveBase }, "OliveBase"),
            (ColorProvider.OliveBase.computedStrongVariant, { ColorProvider.OliveBase.computedStrongVariant }, "OliveBase.computedStrongVariant"),
            (ColorProvider.OliveBase.computedIntenseVariant, { ColorProvider.OliveBase.computedIntenseVariant }, "OliveBase.computedIntenseVariant"),
            
            (ColorProvider.PickleBase, { ColorProvider.PickleBase }, "PickleBase"),
            (ColorProvider.PickleBase.computedStrongVariant, { ColorProvider.PickleBase.computedStrongVariant }, "PickleBase.computedStrongVariant"),
            (ColorProvider.PickleBase.computedIntenseVariant, { ColorProvider.PickleBase.computedIntenseVariant }, "PickleBase.computedIntenseVariant")
        ])
    ]
}

extension UIFoundationsColorsViewController: UICollectionViewDelegateFlowLayout {
    
}

extension UIFoundationsColorsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data[section].1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UIFoundationsColorsViewController.color",
                                                      for: indexPath)
        guard let colorCell = cell as? ColorCollectionViewCell else { return cell }
        colorCell.leftView.backgroundColor = data[indexPath.section].1[indexPath.row].0
        colorCell.rightView.layer.backgroundColor = data[indexPath.section].1[indexPath.row].1()
        colorCell.text = data[indexPath.section].1[indexPath.row].2
        return colorCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: "UIFoundationsColorsViewController.title",
                                                                   for: indexPath)
        guard let label = view as? LabelReusableView else { return view }
        label.text = data[indexPath.section].0
        return label
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.size.width, height: 50.0)
    }
}

final class LabelReusableView: UICollectionReusableView {
    
    private let label = UILabel()
    private let effect = UIVisualEffectView()
    
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setEffectEffect()
    }
    
    private func setEffectEffect() {
        if #available(iOS 12.0, *) {
            effect.effect = traitCollection.userInterfaceStyle == .dark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .extraLight)
        } else if ColorProvider.brand == .vpn {
            effect.effect = UIBlurEffect(style: .dark)
        } else {
            effect.effect = UIBlurEffect(style: .extraLight)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setEffectEffect()
        addSubview(effect)
        effect.fillSuperview()
        addSubview(label)
        label.fillSuperview()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ColorCollectionViewCell: UICollectionViewCell {
    
    private let label = UILabel()
    private let container = UIStackView()
    
    let leftView = UIView()
    let rightView = UIView()
    
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        label.removeFromSuperview()
        container.arrangedSubviews.forEach { $0.removeFromSuperview() }
        container.removeFromSuperview()
        
        addSubview(label)
        container.translatesAutoresizingMaskIntoConstraints = false
        leftView.translatesAutoresizingMaskIntoConstraints = false
        rightView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            container.leftAnchor.constraint(equalTo: leftAnchor),
            container.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        container.addArrangedSubview(leftView)
        container.addArrangedSubview(rightView)
        container.axis = .horizontal
        container.distribution = .fillEqually
        container.spacing = 8
        
        label.textAlignment = .center
        label.centerXInSuperview()
        label.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.backgroundColor = ColorProvider.BackgroundNorm
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
import ProtonCoreUIFoundations

final class UIFoundationsColorsViewController: UIFoundationsAppearanceStyleViewController {

    private let layout = UICollectionViewFlowLayout()
    private var collectionView: UICollectionView!

    override func loadView() {
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        view = collectionView
    }

    override func viewDidLoad() {
        title = "Colors"
        view.backgroundColor = ColorProvider.BackgroundNorm
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

    let data: [(String, [(UIColor, String)])] = [
        ("Brand", [
            (ColorProvider.BrandDarken40, "BrandDarken40"),
            (ColorProvider.BrandDarken20, "BrandDarken20"),
            (ColorProvider.BrandNorm, "BrandNorm"),
            (ColorProvider.BrandLighten20, "BrandLighten20"),
            (ColorProvider.BrandLighten40, "BrandLighten40")
        ]),

        ("Notification", [
            (ColorProvider.NotificationError, "NotificationError"),
            (ColorProvider.NotificationWarning, "NotificationWarning"),
            (ColorProvider.NotificationSuccess, "NotificationSuccess"),
            (ColorProvider.NotificationNorm, "NotificationNorm")
        ]),

        ("Interaction norm", [
            (ColorProvider.InteractionNorm, "InteractionNorm"),
            (ColorProvider.InteractionNormPressed, "InteractionNormPressed"),
            (ColorProvider.InteractionNormDisabled, "InteractionNormDisabled")
        ]),

        ("Shade", [
            (ColorProvider.Shade100, "Shade100"),
            (ColorProvider.Shade80, "Shade80"),
            (ColorProvider.Shade60, "Shade60"),
            (ColorProvider.Shade50, "Shade50"),
            (ColorProvider.Shade40, "Shade40"),
            (ColorProvider.Shade20, "Shade20"),
            (ColorProvider.Shade10, "Shade10"),
            (ColorProvider.Shade0, "Shade0")
        ]),

        ("Text", [
            (ColorProvider.TextNorm, "TextNorm"),
            (ColorProvider.TextWeak, "TextWeak"),
            (ColorProvider.TextHint, "TextHint"),
            (ColorProvider.TextDisabled, "TextDisabled"),
            (ColorProvider.TextInverted, "TextInverted")
        ]),

        ("Icon", [
            (ColorProvider.IconNorm, "IconNorm"),
            (ColorProvider.IconWeak, "IconWeak"),
            (ColorProvider.IconHint, "IconHint"),
            (ColorProvider.IconDisabled, "IconDisabled"),
            (ColorProvider.IconInverted, "IconInverted")
        ]),

        ("Interaction", [
            (ColorProvider.InteractionWeak, "InteractionWeak"),
            (ColorProvider.InteractionWeakPressed, "InteractionWeakPressed"),
            (ColorProvider.InteractionWeakDisabled, "InteractionWeakDisabled"),
            (ColorProvider.InteractionStrong, "InteractionStrong"),
            (ColorProvider.InteractionStrongPressed, "InteractionStrongPressed")
        ]),

        ("Floaty", [
            (ColorProvider.FloatyBackground, "FloatyBackground"),
            (ColorProvider.FloatyPressed, "FloatyPressed"),
            (ColorProvider.FloatyText, "FloatyText")
        ]),

        ("Background", [
            (ColorProvider.BackgroundNorm, "BackgroundNorm"),
            (ColorProvider.BackgroundSecondary, "BackgroundSecondary")
        ]),

        ("Separator", [
            (ColorProvider.SeparatorNorm, "SeparatorNorm")
        ]),

        ("Sidebar", [
            (ColorProvider.SidebarBackground, "SidebarBackground"),
            (ColorProvider.SidebarInteractionWeakNorm, "SidebarInteractionWeakNorm"),
            (ColorProvider.SidebarInteractionWeakPressed, "SidebarInteractionWeakPressed"),
            (ColorProvider.SidebarSeparator, "SidebarSeparator"),
            (ColorProvider.SidebarTextNorm, "SidebarTextNorm"),
            (ColorProvider.SidebarTextWeak, "SidebarTextWeak"),
            (ColorProvider.SidebarIconNorm, "SidebarIconNorm"),
            (ColorProvider.SidebarIconWeak, "SidebarIconWeak"),
            (ColorProvider.SidebarInteractionPressed, "SidebarInteractionPressed")
        ]),

        ("Blenders", [
            (ColorProvider.BlenderNorm, "BlenderNorm")
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
        cell.backgroundColor = data[indexPath.section].1[indexPath.row].0
        guard let colorCell = cell as? ColorCollectionViewCell else { return cell }
        colorCell.text = data[indexPath.section].1[indexPath.row].1
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

    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(label)
        label.textAlignment = .center
        label.centerXInSuperview()
        label.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.backgroundColor = ColorProvider.BackgroundNorm
        label.font = UIFont.preferredFont(forTextStyle: .body)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

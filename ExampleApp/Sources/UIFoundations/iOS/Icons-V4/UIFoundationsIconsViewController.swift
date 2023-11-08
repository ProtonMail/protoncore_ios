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
import ProtonCoreUIFoundations

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

    let data: [(String, [(UIImage, String)])] = [
        ("Icons", [
            (IconProvider.arrowLeft, "arrowLeft"),
            (IconProvider.arrowOutFromRectangle, "arrowOutFromRectangle"),
            (IconProvider.arrowRight, "arrowRight"),
            (IconProvider.arrowsRotate, "arrowsRotate"),
            (IconProvider.checkmarkCircle, "checkmarkCircle"),
            (IconProvider.checkmark, "checkmark"),
            (IconProvider.chevronDown, "chevronDown"),
            (IconProvider.crossCircleFilled, "crossCircleFilled"),
            (IconProvider.cogWheel, "cogWheel"),
            (IconProvider.crossSmall, "crossSmall"),
            (IconProvider.envelope, "envelope"),
            (IconProvider.eyeSlash, "eyeSlash"),
            (IconProvider.eye, "eye"),
            (IconProvider.fileArrowIn, "fileArrowIn"),
            (IconProvider.key, "key"),
            (IconProvider.lightbulb, "lightbulb"),
            (IconProvider.plus, "plus"),
            (IconProvider.minus, "minus"),
            (IconProvider.minusCircle, "minusCircle"),
            (IconProvider.mobile, "mobile"),
            (IconProvider.questionCircle, "questionCircle"),
            (IconProvider.signIn, "signIn"),
            (IconProvider.speechBubble, "speechBubble"),
            (IconProvider.threeDotsHorizontal, "threeDotsHorizontal"),
            (IconProvider.userCircle, "userCircle"),
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
        iconCell.icon = data[indexPath.section].1[indexPath.row].0.withRenderingMode(.alwaysTemplate)
        iconCell.text = "\(data[indexPath.section].1[indexPath.row].1)"
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
        image.centerInSuperview()
        image.tintColor = ColorProvider.IconNorm
        addSubview(label)
        label.textColor = ColorProvider.TextWeak
        label.numberOfLines = 0
        label.textAlignment = .center
        label.centerXInSuperview()
        label.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.backgroundColor = ColorProvider.BackgroundNorm
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

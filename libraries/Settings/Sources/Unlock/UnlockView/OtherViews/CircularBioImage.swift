//
//  CircularBioImage.swift
//  ProtonCore-Settings - Created on 30.10.2020.
//
//  Copyright (c) 2019 Proton Technologies AG
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

import ProtonCore_UIFoundations

final class CircularBioImage: UIView {
    private lazy var imageView = UIImageView()
    private lazy var imageCaption = UILabel()

    convenience init() {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupContents()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width * 0.5
    }

    private func setupContents() {
        backgroundColor = AdaptiveColors._N1

        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1 / 3),
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1 / 3)
        ])
        imageView.tintColor = BrandBlue._Blue

        addSubview(imageCaption)
        imageCaption.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            imageCaption.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageCaption.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 60)
        ]
        constraints.last?.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate(constraints)
    }

    func setupImage(authentication: BiometryType) {
        imageView.image = UIImage(name: authentication.imageName)
    }

    func setupCaption(authentication: BiometryType) {
        imageCaption.text = authentication.technologyName
    }
}

//
//  PMButton.swift
//  ProtonCore-UIFoundations - Created on 26.05.20.
//
//  Copyright (c) 2020 Proton Technologies AG
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

import UIKit

public class PMButton: UIButton {

    public enum Style {
        case primary
        case secondary
    }

    public var style: Style = .primary {
        didSet {
            update()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    init() {
        super.init(frame: .zero)
        configure()
    }

    @objc override public var isHighlighted: Bool {
        didSet {
            update()
        }
    }

    private func configure() {
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 25, bottom: 8, right: 25)
        layer.cornerRadius = 2.5
        titleLabel?.font = .preferredFont(forTextStyle: .footnote)

        update()
    }

    private func update() {
        switch style {
        case .primary:
            setTitleColor(UIColorManager.TextInverted, for: .normal)
            setTitleColor(.gray, for: .highlighted)
            backgroundColor = UIColorManager.Shade100
        case .secondary:
            setTitleColor(UIColorManager.TextNorm, for: .normal)
            setTitleColor(.gray, for: .highlighted)
            backgroundColor = UIColorManager.Shade10
        }
    }
}

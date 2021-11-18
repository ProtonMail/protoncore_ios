//
//  SummaryViewController.swift
//  ProtonCore-Login - Created on 07/09/2021.
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

import UIKit
import ProtonCore_CoreTranslation
import ProtonCore_Foundations
import ProtonCore_UIFoundations

public typealias SummaryScreenVariant = ScreenVariant<SummaryStartButtonText, SummaryScreenCustomData>

public typealias SummaryStartButtonText = String

public struct SummaryScreenCustomData {
    let image: UIImage
    let startButtonText: String

    public init(image: UIImage, startButtonText: String) {
        self.image = image
        self.startButtonText = startButtonText
    }
}

protocol SummaryViewControllerDelegate: AnyObject {
    func startButtonTap()
}

class SummaryViewController: UIViewController, AccessibleView {

    weak var delegate: SummaryViewControllerDelegate?
    var viewModel: SummaryViewModel!

    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var header: UILabel! {
        didSet {
            header.textColor = ColorProvider.TextNorm
            header.text = CoreString._su_summary_title
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.textColor = ColorProvider.TextNorm
        }
    }
    @IBOutlet weak var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.textColor = ColorProvider.TextNorm
            welcomeLabel.text = CoreString._su_summary_welcome
        }
    }
    @IBOutlet weak var startButton: ProtonButton!

    // MARK: View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorProvider.BackgroundNorm
        setupUI()
        generateAccessibilityIdentifiers()
    }

    // MARK: Actions
    
    @IBAction func onStartButtonTap(_ sender: ProtonButton) {
        delegate?.startButtonTap()
    }
    
    // MARK: Private methods

    func setupUI() {
        if let summaryImage = viewModel.summaryImage {
            imageView.image = summaryImage
        }
        descriptionLabel.attributedText = viewModel.descriptionText
        startButton.setTitle(viewModel.startButtonText, for: .normal)
    }

}

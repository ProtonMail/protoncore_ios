//
//  PlanCell.swift
//  ProtonCore_PaymentsUI - Created on 01/06/2021.
//
//  Copyright (c) 2021 Proton Technologies AG
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
import ProtonCore_UIFoundations
import ProtonCore_Foundations
import ProtonCore_CoreTranslation
import ProtonCore_CoreTranslation_V5

protocol PlanCellDelegate: AnyObject {
    func userPressedSelectPlanButton(plan: PlanPresentation, completionHandler: @escaping () -> Void)
    func cellDidChange(cell: PlanCell)
}

final class PlanCell: UITableViewCell, AccessibleCell {

    static let reuseIdentifier = "PlanCell"
    static let nib = UINib(nibName: "PlanCell", bundle: PaymentsUI.bundle)
    
    weak var delegate: PlanCellDelegate?
    var plan: PlanPresentation?
    var isSignup: Bool = false
    var isExpanded: Bool?

    // MARK: - Outlets
    
    @IBOutlet weak var mainView: UIView! {
        didSet {
            mainView.layer.cornerRadius = 12.0
        }
    }
    @IBOutlet weak var planNameLabel: UILabel! {
        didSet {
            planNameLabel.textColor = ColorProvider.TextNorm
        }
    }
    @IBOutlet weak var preferredImageView: UIImageView!
    @IBOutlet weak var preferredImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var planDescriptionSeparator: UIView!
    @IBOutlet weak var planDescriptionLabel: UILabel! {
        didSet {
            planDescriptionLabel.textColor = ColorProvider.TextWeak
            planDescriptionLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        }
    }
    @IBOutlet weak var priceLabel: UILabel! {
        didSet {
            priceLabel.textColor = ColorProvider.TextNorm
        }
    }
    @IBOutlet weak var priceDescriptionLabel: UILabel! {
        didSet {
            priceDescriptionLabel.textColor = ColorProvider.TextWeak
        }
    }
    @IBOutlet weak var planDetailsStackView: UIStackView!
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet weak var selectPlanButton: ProtonButton!
    @IBOutlet weak var timeSeparator1View: UIView!
    @IBOutlet weak var separatorLineView: UIView! {
        didSet {
            separatorLineView.backgroundColor = ColorProvider.Shade20
        }
    }
    @IBOutlet weak var timeSeparator2View: UIView!
    @IBOutlet weak var planTimeLabel: UILabel!
    @IBOutlet weak var timeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandButton: UIButton! {
        didSet {
            expandButton.setImage(IconProvider.chevronDown, for: .normal)
            expandButton.contentHorizontalAlignment = .fill
            expandButton.contentVerticalAlignment = .fill
            expandButton.tintColor = ColorProvider.InteractionNorm
        }
    }
    
    // MARK: - Properties
    
    func configurePlan(plan: PlanPresentation, isSignup: Bool, isExpanded: Bool) {
        planDetailsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        self.plan = plan
        self.isSignup = isSignup
        if self.isExpanded == nil {
            self.isExpanded = isExpanded
            if isExpanded {
                expandButton.isHidden = true
            }
        }
        generateCellAccessibilityIdentifiers(plan.name)
        
        planNameLabel.text = plan.name
        if plan.isPreferred {
            let image = IconProvider.starFilled
            preferredImageView.tintColor = ColorProvider.InteractionNorm
            preferredImageView.image = image
        } else {
            preferredImageViewWidthConstraint.constant = 0
        }
        switch plan.title {
        case .description(let description):
            if let description = description {
                planDescriptionLabel.text = description
            } else {
                planDescriptionSeparator.isHidden = true
                planDescriptionLabel.isHidden = true
            }
        case .current:
            planDescriptionLabel.text = CoreString._pu_current_plan_title
            planDescriptionSeparator.isHidden = true
            self.isExpanded = true
            expandButton.isHidden = true

        case .unavailable:
            priceLabel.text = ""
            priceDescriptionLabel.text = ""
            planDescriptionLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
            planDescriptionLabel.text = CoreString._pu_plan_details_plan_details_unavailable_contact_administrator
            planDescriptionLabel.textColor = ColorProvider.TextNorm
        }
        
        if let price = plan.price {
            priceLabel.isHidden = false
            priceDescriptionLabel.isHidden = false
            priceLabel.text = price
            priceDescriptionLabel.text = plan.cycle
        } else {
            priceLabel.isHidden = true
            priceDescriptionLabel.isHidden = true
        }
        plan.details.forEach {
            let detailView = PlanDetailView()
            detailView.configure(icon: $0.0.icon, text: $0.1)
            planDetailsStackView.addArrangedSubview(detailView)
        }
        drawView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard let plan = plan else { return }
        configureMainView(isSelectable: plan.isSelectable)
    }
    
    // MARK: - Actions
    
    @IBAction func onSelectPlanButtonTap(_ sender: ProtonButton) {
        if let plan = plan {
            selectPlanButton.isSelected = true
            delegate?.userPressedSelectPlanButton(plan: plan) {
                DispatchQueue.main.async {
                    self.selectPlanButton.isSelected = false
                }
            }
        }
    }
    
    @IBAction func onExpandButtonTap(_ sender: UIButton) {
        isExpanded?.toggle()

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.drawView()
        })
        delegate?.cellDidChange(cell: self)
    }
    
    // MARK: Private interface
    
    private func drawView() {
        guard let plan = plan, let isExpanded = isExpanded else { return }
        rotateArrow()
        spacerView.isHidden = !plan.isSelectable || !isExpanded
        selectPlanButton.isHidden = !plan.isSelectable || !isExpanded
        selectPlanButton.alpha = isExpanded ? 1 : 0
        if let endDate = plan.endDate {
            enableTimeView(enabled: true)
            planTimeLabel.attributedText = endDate
        } else {
            enableTimeView(enabled: false)
        }
        if plan.accountPlan.isFreePlan {
            selectPlanButton.setTitle(CoreString_V5._new_plans_get_free_plan_button, for: .normal)
        } else {
            selectPlanButton.setTitle(String(format: CoreString_V5._new_plans_get_plan_button, plan.name), for: .normal)
        }
        if plan.isSelectable {
            priceLabel.font = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        } else {
            priceLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
        }
        selectPlanButton.setMode(mode: .solid)
        planDetailsStackView.subviews.forEach {
            $0.isHidden = !isExpanded
            $0.alpha = isExpanded ? 1 : 0
        }
        configureMainView(isSelectable: plan.isSelectable)
        timeBottomConstraint.constant = isExpanded ? 16 : 0
    }
    
    private func configureMainView(isSelectable: Bool) {
        if isSelectable {
            guard let isExpanded = isExpanded else { return }
            if isExpanded {
                mainView.layer.borderWidth = 1.0
                mainView.layer.borderColor = ColorProvider.InteractionNorm.cgColor
            } else {
                mainView.layer.borderWidth = 0.0
            }
            mainView.backgroundColor = ColorProvider.BackgroundSecondary
        } else {
            mainView.layer.borderWidth = 1.0
            mainView.layer.borderColor = ColorProvider.SeparatorNorm.cgColor
        }
    }
    
    private func enableTimeView(enabled: Bool) {
        guard let isExpanded = isExpanded else { return }
        timeSeparator1View.isHidden = !enabled || !isExpanded
        separatorLineView.isHidden = !enabled || !isExpanded
        timeSeparator2View.isHidden = !enabled || !isExpanded
        planTimeLabel.isHidden = !enabled || !isExpanded
        planTimeLabel.alpha = isExpanded ? 1 : 0
    }
    
    private func rotateArrow() {
        expandButton.transform = CGAffineTransform(rotationAngle: isExpanded ?? true ? -Double.pi : Double.pi * 2)
    }
}

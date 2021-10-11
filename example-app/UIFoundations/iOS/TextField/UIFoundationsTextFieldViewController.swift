//
//  UIFoundationsTextFieldViewController.swift
//  Showcase
//
//  Created by Igor Kulman on 09/11/2020.
//

import UIKit
import ProtonCore_UIFoundations

final class UIFoundationsTextFieldViewController: UIFoundationsAppearanceStyleViewController {

    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!

    init() {
        super.init(nibName: "UIFoundationsTextFieldViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ColorProvider.BackgroundNorm
        mainView.backgroundColor = ColorProvider.BackgroundNorm

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
}

//
//  ConfirmDialog.swift
//  PrankSounds
//
//  Created by Linh Nguyen Duc on 08/08/2022.
//

import UIKit

protocol ConfirmDialogDelegate: AnyObject {
    func confirmDialogDidTapConfirm(_ confirmDialog: ConfirmDialog)
}

class ConfirmDialog: UIView {
    static var shared = ConfirmDialog.loadView()

    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!

    weak var delegate: ConfirmDialogDelegate?

    // MARK: - Action
    @IBAction func confirmButtonDidTap(_ sender: Any) {
        delegate?.confirmDialogDidTapConfirm(self)
        self.dismiss()
    }

    @IBAction func cancelButtonDidTap(_ sender: Any) {
        self.dismiss()
    }

    // MARK: - Helper
    private func dismiss() {
        guard self.superview != nil else {
            return
        }

        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    private func show(superview: UIView, message: String) {
        self.alpha = 0
        self.messageLabel.text = message
        superview.addSubview(self)
        self.fitSuperviewConstraint()

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    // MARK: - Static function
    static func show(message: String) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              shared.superview == nil else {
            return
        }

        shared.show(superview: window, message: message)
    }

    static func dismiss() {
        shared.dismiss()
    }

    static func loadView() -> ConfirmDialog {
        return ConfirmDialog.loadView(fromNib: "ConfirmDialog")!
    }
}

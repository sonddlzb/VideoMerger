//
//  AddAudioViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 20/02/2024.
//

import RIBs
import RxSwift
import UIKit

protocol AddAudioPresentableListener: AnyObject {
    func didTapCancel()
}

final class AddAudioViewController: UIViewController, AddAudioPresentable, AddAudioViewControllable {
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!

    // MARK: - Variables
    weak var listener: AddAudioPresentableListener?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.layer.shadowColor = UIColor.gray.cgColor
        self.containerView.layer.shadowOpacity = 0.25
        self.containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        self.containerView.layer.shadowRadius = 4
    }

    // MARK: - Actions
    @IBAction func didTapGetAudioFromVideos(_ sender: Any) {
    }

    @IBAction func didTapGetAudioFromDevices(_ sender: Any) {
    }

    @IBAction func didTapCancel(_ sender: Any) {
        self.listener?.didTapCancel()
    }
}

//
//  ExportViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 23/01/2024.
//

import RIBs
import RxSwift
import UIKit

protocol ExportPresentableListener: AnyObject {
    func didTapCancel()
}

final class ExportViewController: UIViewController, ExportPresentable, ExportViewControllable {
    // MARK: - Outlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var resolutionBar: PointSelectionBar!
    @IBOutlet private weak var fpsBar: PointSelectionBar!
    @IBOutlet private weak var audioSwitch: UISwitch!
    @IBOutlet weak var videoOptionStackView: UIStackView!

    // MARK: - Variables
    weak var listener: ExportPresentableListener?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.layer.shadowColor = UIColor.gray.cgColor
        self.containerView.layer.shadowOpacity = 0.25
        self.containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        self.containerView.layer.shadowRadius = 4

        // MARK: - fake data
        self.resolutionBar.pointsData = ["540p", "720p", "1080p", "2k", "4k"]
        self.resolutionBar.selectedIndex = 2

        self.fpsBar.pointsData = ["24", "25", "30", "50", "60"]
        self.fpsBar.selectedIndex = 2
    }

    // MARK: - Actions
    @IBAction func didTapCancel(_ sender: Any) {
        self.listener?.didTapCancel()
    }
    @IBAction func didChangeAudioSwitch(_ sender: Any) {
        if self.audioSwitch.isOn {
            self.videoOptionStackView.isUserInteractionEnabled = false
            self.videoOptionStackView.alpha = 0.5
        } else {
            self.videoOptionStackView.isUserInteractionEnabled = true
            self.videoOptionStackView.alpha = 1.0
        }
    }
}

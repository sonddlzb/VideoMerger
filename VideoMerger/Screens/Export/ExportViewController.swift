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
    func didTapExport()
}

final class ExportViewController: UIViewController, ExportViewControllable {
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

        self.resolutionBar.pointsData = VideoResolution.allCases.map {$0.symbol()}
        self.resolutionBar.selectedIndex = 2

        self.fpsBar.pointsData = VideoFps.allCases.map {$0.rawValue}
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

    @IBAction func didTapExport(_ sender: Any) {
        self.listener?.didTapExport()
    }
}

// MARK: - ExportPresentable
extension ExportViewController: ExportPresentable {
    func bind(viewModel: ExportViewModel) {
        self.loadViewIfNeeded()
        if let resolutionIndex = VideoResolution.allCases.firstIndex(of: viewModel.config.resolution) {
            self.resolutionBar.selectedIndex = resolutionIndex
        }

        if let fpsIndex = VideoFps.allCases.firstIndex(of: viewModel.config.fps) {
            self.fpsBar.selectedIndex = fpsIndex
        }
    }
}

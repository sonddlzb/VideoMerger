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
    func estimatedStorage(videoResolution: VideoResolution?, fps: VideoFps?)
}

final class ExportViewController: UIViewController, ExportViewControllable {
    // MARK: - Outlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var resolutionBar: PointSelectionBar!
    @IBOutlet private weak var fpsBar: PointSelectionBar!
    @IBOutlet private weak var audioSwitch: UISwitch!
    @IBOutlet private weak var videoOptionStackView: UIStackView!
    @IBOutlet private weak var estimatedSizeLabel: UILabel!

    // MARK: - Variables
    weak var listener: ExportPresentableListener?
    private var viewModel: ExportViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fpsBar.delegate = self
        self.resolutionBar.delegate = self
        self.listener?.estimatedStorage(videoResolution: self.viewModel?.config.resolution, fps: self.viewModel?.config.fps)
    }

    // MARK: - Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.layer.shadowColor = UIColor.gray.cgColor
        self.containerView.layer.shadowOpacity = 0.25
        self.containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        self.containerView.layer.shadowRadius = 4

        if self.resolutionBar.pointsData.count < VideoResolution.allCases.count {
            if let viewModel = self.viewModel {
                self.resolutionBar.pointsData = VideoResolution.allCases.map {$0.symbol()}
                self.resolutionBar.selectedIndex = VideoResolution.allCases.firstIndex(of: VideoResolution(rawValue: (viewModel.config.resolution).rawValue) ?? .p720) ?? 2

                self.fpsBar.pointsData = VideoFps.allCases.map {$0.rawValue}
                self.fpsBar.selectedIndex = VideoFps.allCases.firstIndex(of: VideoFps(rawValue: (viewModel.config.fps).rawValue) ?? .fps30) ?? 2
            }
        }
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
    func bind(estimatedSize: String) {
        DispatchQueue.main.async {
            self.estimatedSizeLabel.text = estimatedSize
        }
    }

    func bind(viewModel: ExportViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: PointSelectionBarDelegate
extension ExportViewController: PointSelectionBarDelegate {
    func pointSelectionBar(_ pointSelectionBar: PointSelectionBar, didSelected state: Int) {
        if pointSelectionBar == resolutionBar {
            var resolution: VideoResolution = .p540
            switch state {
            case 0:
                resolution = .p540
            case 1:
                resolution = .p720
            case 2:
                resolution = .p1080
            case 3:
                resolution = .p2K
            case 4:
                resolution = .p4K
            default:
                break
            }

            self.listener?.estimatedStorage(videoResolution: resolution, fps: nil)
        } else if pointSelectionBar == fpsBar {
            var fps: VideoFps = .fps24
            switch state {
            case 0:
                fps = .fps24
            case 1:
                fps = .fps25
            case 2:
                fps = .fps30
            case 3:
                fps = .fps50
            case 4:
                fps = .fps60
            default:
                break
            }

            self.listener?.estimatedStorage(videoResolution: nil, fps: fps)
        }
    }
}

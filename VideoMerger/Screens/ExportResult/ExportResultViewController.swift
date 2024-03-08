//
//  ExportResultViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 05/03/2024.
//

import RIBs
import RxSwift
import UIKit
import AVFoundation

protocol ExportResultPresentableListener: AnyObject {
    func didTapBack()
    func didTapHome()
    func exportVideo()
    func showPreviewVideo()
}

final class ExportResultViewController: UIViewController, ExportResultViewControllable {
    // MARK: - Outlets
    @IBOutlet private weak var thumbnailUIImageView: UIImageView!
    @IBOutlet private weak var exportStateLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private var exportSuccessImage: [UIImageView]!
    @IBOutlet private weak var contentPreviewImage: UIView!
    private lazy var borderProgressView: BorderProgressView = {
        return BorderProgressView()
    }()
    private lazy var playView: TapableView = {
        let playView = TapableView()
        let imagePlay = UIImageView(image: UIImage(named: "ic_play_white"))
        imagePlay.fixInView(playView)
        playView.translatesAutoresizingMaskIntoConstraints = false
        return playView
    }()
    // MARK: - Variables
    weak var listener: ExportResultPresentableListener?
    var viewModel: ExportResultViewModel?
    var outputURL: URL?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }

    private func config() {
        self.thumbnailUIImageView.addSubview(borderProgressView)
        self.thumbnailUIImageView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleShowPreviewVideo(_:)))
        thumbnailUIImageView.isUserInteractionEnabled = false
        thumbnailUIImageView.addGestureRecognizer(tapGesture)
        borderProgressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            borderProgressView.topAnchor.constraint(equalTo: self.thumbnailUIImageView.topAnchor, constant: -5.0),
            borderProgressView.bottomAnchor.constraint(equalTo: self.thumbnailUIImageView.bottomAnchor, constant: 5.0),
            borderProgressView.leadingAnchor.constraint(equalTo: self.thumbnailUIImageView.leadingAnchor, constant: -5.0),
            borderProgressView.trailingAnchor.constraint(equalTo: self.thumbnailUIImageView.trailingAnchor, constant: 5.0)
        ])
        self.listener?.exportVideo()
    }

    // MARK: - Actions
    private func exportedVideo() {
        DispatchQueue.main.async {
            self.exportSuccessImage.forEach { image in
                image.isHidden = false
            }

            self.exportStateLabel.text = """
Congratulation!
Your video is ready
"""
            self.contentLabel.isHidden = true
            self.contentPreviewImage.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            self.contentPreviewImage.layer.shadowOpacity = 0.9
            self.contentPreviewImage.layer.shadowColor = UIColor.lightGray.cgColor
            self.thumbnailUIImageView.isUserInteractionEnabled = true
            self.thumbnailUIImageView.subviews.forEach { $0.removeFromSuperview() }
            self.thumbnailUIImageView.addSubview(self.playView)
            NSLayoutConstraint.activate([
                self.thumbnailUIImageView.centerXAnchor.constraint(equalTo: self.playView.centerXAnchor),
                self.thumbnailUIImageView.centerYAnchor.constraint(equalTo: self.playView.centerYAnchor)
            ])
        }
    }
    @objc private func handleShowPreviewVideo(_ gesture: UITapGestureRecognizer) {
        self.listener?.showPreviewVideo()
    }
    @IBAction func didTapBack(_ sender: Any) {
        self.listener?.didTapBack()
    }

    @IBAction func didTapHome(_ sender: Any) {
        self.listener?.didTapHome()
    }
}

// MARK: ExportResultPresentable
extension ExportResultViewController: ExportResultPresentable {
    func bind(viewModel: ExportResultViewModel, outputURL: URL?, progress: Float) {
        DispatchQueue.main.async {
            if self.thumbnailUIImageView.image == nil {
                self.thumbnailUIImageView.image = viewModel.exportSession?.asset.thumbnailImage
            }

            self.borderProgressView.setProgress(CGFloat(progress), animated: true)
            if progress == 1.0 {
                self.viewModel = viewModel
                self.exportedVideo()
                self.outputURL = outputURL
            }
        }
    }
}

//
//  ExportResultViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 05/03/2024.
//

import RIBs
import RxSwift
import UIKit

protocol ExportResultPresentableListener: AnyObject {
    func didTapBack()
    func didTapHome()
    func exportVideo()
}

final class ExportResultViewController: UIViewController, ExportResultViewControllable {
    // MARK: - Outlets
    @IBOutlet private weak var thumbnailUIImageView: UIImageView!
    private lazy var borderProgressView: BorderProgressView = {
        return BorderProgressView()
    }()
    // MARK: - Variables
    weak var listener: ExportResultPresentableListener?
    var viewModel: ExportResultViewModel?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }

    private func config() {
        self.thumbnailUIImageView.addSubview(borderProgressView)
        self.thumbnailUIImageView.translatesAutoresizingMaskIntoConstraints = false
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
        }
    }
}

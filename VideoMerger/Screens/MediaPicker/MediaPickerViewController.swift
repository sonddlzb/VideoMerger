//
//  MediaPickerViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 27/11/2023.
//

import RIBs
import RxSwift
import UIKit
import Photos

private struct Const {
    static let contentInset = UIEdgeInsets(top: 0.0, left: 4.0, bottom: 0.0, right: 4.0)
    static let cellPadding = 2.0
    static let cellSpacing = 2.0
}

protocol MediaPickerPresentableListener: AnyObject {
    func didTapDismiss()
    func didSelect(at index: Int, isVideo: Bool)
    func shouldReloadData()
    func didSelect(_ listSelectedAsset: [PHAsset])
}

final class MediaPickerViewController: UIViewController, MediaPickerViewControllable {
    // MARK: - Outlets
    @IBOutlet weak var videosSelectedBorder: UIView!
    @IBOutlet weak var photosSelectedBorder: UIView!
    @IBOutlet weak var addMediaView: TapableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var videosCollectionView: UICollectionView!
    @IBOutlet weak var photosCollectionView: UICollectionView!

    // MARK: - Variables
    weak var listener: MediaPickerPresentableListener?
    var photosRefresher: UIRefreshControl!
    var videosRefresher: UIRefreshControl!
    var viewModel = MediaPickerViewModel.makeEmptyListAsset()
    var isVideosSelected = true {
        didSet {
            reloadSelectedState()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    private func config() {
        self.configCollectionView()
        self.scrollView.isScrollEnabled = false
    }

    private func configCollectionView() {
        self.videosCollectionView.showsVerticalScrollIndicator = false
        self.videosCollectionView.showsHorizontalScrollIndicator = false
        self.videosCollectionView.contentInset = Const.contentInset
        self.videosCollectionView.delegate = self
        self.videosCollectionView.dataSource = self
        self.videosCollectionView.registerCell(type: MediaCell.self)

        self.photosCollectionView.showsVerticalScrollIndicator = false
        self.photosCollectionView.showsHorizontalScrollIndicator = false
        self.photosCollectionView.contentInset = Const.contentInset
        self.photosCollectionView.delegate = self
        self.photosCollectionView.dataSource = self
        self.photosCollectionView.registerCell(type: MediaCell.self)

        self.photosRefresher = UIRefreshControl()
        self.photosRefresher.tintColor = .white
        self.photosCollectionView.alwaysBounceVertical = true
        self.photosRefresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        self.photosCollectionView.refreshControl = photosRefresher

        self.videosRefresher = UIRefreshControl()
        self.videosRefresher.tintColor = .white
        self.videosCollectionView.alwaysBounceVertical = true
        self.videosRefresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        self.videosCollectionView.refreshControl = videosRefresher
    }

    func reloadSelectedState() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.videosSelectedBorder.isHidden = !self.isVideosSelected
            self.photosSelectedBorder.isHidden = self.isVideosSelected
            self.scrollView.setContentOffset(CGPoint(x: self.isVideosSelected ? 0.0 : self.view.frame.width, y: 0.0), animated: true)
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions
    @objc func reloadData() {
        if isVideosSelected {
            self.videosRefresher.beginRefreshing()
        } else {
            self.photosRefresher.beginRefreshing()
        }

        self.listener?.shouldReloadData()
     }

    @IBAction func didTapCancel(_ sender: Any) {
        self.listener?.didTapDismiss()
    }

    @IBAction func didTapVideos(_ sender: Any) {
        guard !self.isVideosSelected else {
            return
        }

        self.isVideosSelected = true
    }

    @IBAction func didTapPhotos(_ sender: Any) {
        guard self.isVideosSelected else {
            return
        }

        self.isVideosSelected = false
    }
    @IBAction func didTapAddMedia(_ sender: Any) {
        self.listener?.didSelect(self.viewModel.listSelectedAssets)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MediaPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == videosCollectionView {
            return self.viewModel.numberOfVideos()
        } else {
            return self.viewModel.numberOfPhotos()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: MediaCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }

        cell.delegate = self
        cell.bind(itemViewModel: self.viewModel.item(at: indexPath.row, isVideo: collectionView == self.videosCollectionView))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.listener?.didSelect(at: indexPath.row, isVideo: collectionView == self.videosCollectionView)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MediaPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - Const.contentInset.left - Const.contentInset.right - 2*Const.cellPadding)/3
        let height = width
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Const.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Const.cellPadding
    }
}

// MARK: - MediaPickerPresentable
extension MediaPickerViewController: MediaPickerPresentable {
    func bind(viewModel: MediaPickerViewModel) {
        self.loadViewIfNeeded()
        self.viewModel = viewModel
        self.videosCollectionView.reloadData()
        self.photosCollectionView.reloadData()
        if self.photosRefresher != nil {
            self.photosRefresher.endRefreshing()
        }

        if self.videosRefresher != nil {
            self.videosRefresher.endRefreshing()
        }
    }
}

// MARK: - MediaCellDelegate
extension MediaPickerViewController: MediaCellDelegate {
    func mediaCell(_ mediaCell: MediaCell, didSelect itemViewModel: MediaPickerItemViewModel, isSelected: Bool) {
        if !isSelected {
            self.viewModel.listSelectedAssets.append(itemViewModel.asset)
        } else {
            self.viewModel.listSelectedAssets.removeObject(itemViewModel.asset)
            if let index = viewModel.index(of: itemViewModel.asset) {
                if itemViewModel.isVideo() {
                    (self.videosCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? MediaCell)?.bindSelectedState(itemViewModel: self.viewModel.item(at: index, isVideo: true))
                } else {
                    (self.photosCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? MediaCell)?.bindSelectedState(itemViewModel: self.viewModel.item(at: index, isVideo: false))
                }
            }
        }

        self.addMediaView.isHidden = self.viewModel.listSelectedAssets.isEmpty

        for asset in self.viewModel.listSelectedAssets {
            let index = self.viewModel.index(of: asset)!
            if asset.mediaType == .video {
                (self.videosCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? MediaCell)?.bindSelectedState(itemViewModel: self.viewModel.item(at: index, isVideo: true))
            } else {
                (self.photosCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? MediaCell)?.bindSelectedState(itemViewModel: self.viewModel.item(at: index, isVideo: false))
            }
        }
    }
}

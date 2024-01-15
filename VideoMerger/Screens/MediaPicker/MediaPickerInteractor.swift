//
//  MediaPickerInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 27/11/2023.
//

import RIBs
import RxSwift
import UIKit
import Photos

protocol MediaPickerRouting: ViewableRouting {
    func openPreviewImage(_ asset: PHAsset)
    func dismissPreviewImage()
    func openPreviewVideo(_ asset: PHAsset)
    func dismissPreviewVideo()
}

protocol MediaPickerPresentable: Presentable {
    var listener: MediaPickerPresentableListener? { get set }

    func bind(viewModel: MediaPickerViewModel)
}

protocol MediaPickerListener: AnyObject {
    func mediaPickerWantToDismiss()
    func mediaPickerWantToOpenEditor(for listAssets: [PHAsset], isAddMore: Bool)
}

final class MediaPickerInteractor: PresentableInteractor<MediaPickerPresentable>, MediaPickerInteractable {

    weak var router: MediaPickerRouting?
    weak var listener: MediaPickerListener?
    var viewModel = MediaPickerViewModel.makeEmptyListAsset()
    var isAddMore: Bool

    init(presenter: MediaPickerPresentable, isAddMore: Bool) {
        self.isAddMore = isAddMore
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        self.fetchAsset()
    }

    override func willResignActive() {
        super.willResignActive()
    }

    func fetchAsset() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.handleLoadingLibrary(authorizationStatus: status)
            }
        }
    }

    func handleLoadingLibrary(authorizationStatus: PHAuthorizationStatus) {
        var listAssets: [PHAsset] = []
        if authorizationStatus == .authorized {
            self.viewModel.isGrantedAccess = true
            let assets = PHAsset.fetchAssets(with: nil)
            assets.enumerateObjects { (object, _, _) in
                listAssets.append(object)
            }

            viewModel.listAsset = listAssets
            self.viewModel.listAsset = listAssets
            viewModel.sortMediaFromNewestToOldest()
            self.presenter.bind(viewModel: viewModel)
        } else {
            self.viewModel.isGrantedAccess = false
        }
    }
}

// MARK: - MediaPickerPresentableListener
extension MediaPickerInteractor: MediaPickerPresentableListener {
    func didTapDismiss() {
        self.listener?.mediaPickerWantToDismiss()
    }

    func didSelect(at index: Int, isVideo: Bool) {
        let asset = isVideo ? self.viewModel.listVideoAssets()[index] : self.viewModel.listPhotoAssets()[index]
        if !isVideo {
            self.router?.openPreviewImage(asset)
        } else {
            self.router?.openPreviewVideo(asset)
        }
    }

    func shouldReloadData() {
        self.fetchAsset()
    }

    func didSelect(_ listSelectedAsset: [PHAsset]) {
        self.listener?.mediaPickerWantToOpenEditor(for: listSelectedAsset, isAddMore: isAddMore)
    }
}

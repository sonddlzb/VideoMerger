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
}

protocol MediaPickerPresentable: Presentable {
    var listener: MediaPickerPresentableListener? { get set }

    func bind(viewModel: MediaPickerViewModel)
}

protocol MediaPickerListener: AnyObject {
    func mediaPickerWantToDismiss()
    func mediaPickerWantToOpenEditor(for listAssets: [PHAsset], isAddMore: Bool)
    func mediaPickerWantToOpenPreviewImage(asset: PHAsset)
    func mediaPickerWantToOpenPreviewVideo(asset: PHAsset)
}

final class MediaPickerInteractor: PresentableInteractor<MediaPickerPresentable>, MediaPickerInteractable {

    weak var router: MediaPickerRouting?
    weak var listener: MediaPickerListener?
    var viewModel = MediaPickerViewModel.makeEmptyListAsset()
    var isAddMore: Bool
    var disposeBag = DisposeBag()

    init(presenter: MediaPickerPresentable, isAddMore: Bool, isSelectAudio: Bool = false) {
        self.isAddMore = isAddMore
        self.viewModel.isSelectAudio = isSelectAudio
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
            self.listener?.mediaPickerWantToOpenPreviewImage(asset: asset)
        } else {
            self.listener?.mediaPickerWantToOpenPreviewVideo(asset: asset)
        }
    }

    func shouldReloadData() {
        self.fetchAsset()
    }

    func didSelect(_ listSelectedAsset: [PHAsset]) {
        if self.viewModel.isSelectAudio {
            if let asset = listSelectedAsset.first {
                asset.exportAudio(using: disposeBag) {[weak self] audioURL in
                    DispatchQueue.main.async {
                        self?.listener?.mediaPickerWantToDismiss()
                    }

                    // MARK: - handle using audioURL later
                }
            }
        } else {
            self.listener?.mediaPickerWantToOpenEditor(for: listSelectedAsset, isAddMore: isAddMore)
        }
    }
}

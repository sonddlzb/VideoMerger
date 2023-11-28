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
}

final class MediaPickerInteractor: PresentableInteractor<MediaPickerPresentable>, MediaPickerInteractable {

    weak var router: MediaPickerRouting?
    weak var listener: MediaPickerListener?
    var viewModel = MediaPickerViewModel.makeEmptyListAsset()

    override init(presenter: MediaPickerPresentable) {
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
}

//
//  HomeInteractor+MediaPicker.swift
//  VideoMerger
//
//  Created by đào sơn on 27/11/2023.
//

import Foundation
import Photos

extension HomeInteractor: MediaPickerListener {
    func mediaPickerWantToDismiss() {
        self.router?.dismissMediaPicker()
    }

    func mediaPickerWantToOpenEditor(for listAssets: [PHAsset], isAddMore: Bool) {
        self.router?.dismissMediaPicker()
        self.router?.openEditor(listAssets, isAddMore: isAddMore)
    }

    func mediaPickerWantToOpenPreviewImage(asset: PHAsset) {
        self.router?.openPreviewImage(asset)
    }

    func mediaPickerWantToOpenPreviewVideo(asset: PHAsset) {
        self.router?.openPreviewVideo(asset)
    }
}

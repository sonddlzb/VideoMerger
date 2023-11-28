//
//  MediaPickerViewModel.swift
//  VideoMerger
//
//  Created by đào sơn on 27/11/2023.
//

import Foundation
import Photos
import UIKit

struct MediaPickerViewModel {
    var listAsset: [PHAsset]
    var listSelectedAssets: [PHAsset]
    var isGrantedAccess = true

    static func makeEmptyListAsset() -> MediaPickerViewModel {
        return MediaPickerViewModel(listAsset: [], listSelectedAssets: [])
    }

    func item(at index: Int, isVideo: Bool) -> MediaPickerItemViewModel {
        let asset = isVideo ? self.listVideoAssets()[index] : self.listPhotoAssets()[index]
        return MediaPickerItemViewModel(asset: asset, selectedIndex: self.listSelectedAssets.firstIndex(of: asset))
    }

    func numberOfAssets() -> Int {
        return self.listAsset.count
    }

    func numberOfSelectedItems() -> Int {
        return listSelectedAssets.count
    }

    func isItemSelected(_ itemViewModel: MediaPickerItemViewModel) -> Bool {
        return listSelectedAssets.contains(itemViewModel.asset)
    }

    func selectedIndex(for itemViewModel: MediaPickerItemViewModel) -> Int? {
        return listSelectedAssets.firstIndex(of: itemViewModel.asset)
    }

    func index(of asset: PHAsset) -> Int? {
        if asset.mediaType == .video {
            return listVideoAssets().firstIndex(of: asset)
        } else {
            return listPhotoAssets().firstIndex(of: asset)
        }
    }

    mutating func sortMediaFromNewestToOldest() {
        self.listAsset.sort {
            return $0.creationDate ?? Date() > $1.creationDate ?? Date()
        }
    }

    func filter(isVideo: Bool) -> MediaPickerViewModel {
        return MediaPickerViewModel(listAsset: listAsset.filter{isVideo ? $0.mediaType == .video : $0.mediaType == .image}, listSelectedAssets: listSelectedAssets)
    }

    func numberOfVideos() -> Int {
        self.listVideoAssets().count
    }

    func listVideoAssets() -> [PHAsset] {
        return self.listAsset.filter {
            $0.mediaType == .video
        }
    }

    func numberOfPhotos() -> Int {
        self.listPhotoAssets().count
    }

    func listPhotoAssets() -> [PHAsset] {
        return self.listAsset.filter {
            $0.mediaType == .image
        }
    }
}

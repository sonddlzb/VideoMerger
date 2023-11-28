//
//  MediaPickerItemViewModel.swift
//  VideoMerger
//
//  Created by đào sơn on 27/11/2023.
//

import Foundation
import UIKit
import Photos

struct MediaPickerItemViewModel {
    var asset: PHAsset
    var selectedIndex: Int?

    func fetchThumbnail(completion: @escaping ((_ image: UIImage?) -> Void)) {
        DispatchQueue.global().async {
            let thumbnail = self.asset.thumbnail(size: CGSize(width: 500, height: 500))
            DispatchQueue.main.async {
                completion(thumbnail)
            }
        }
    }

    func duration() -> String {
        if asset.mediaType == .video {
            return asset.formatVideoDuration()
        } else {
            return ""
        }
    }

    func isVideo() -> Bool {
        return self.asset.mediaType == .video
    }
}

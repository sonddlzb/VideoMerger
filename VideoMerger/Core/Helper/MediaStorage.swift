//
//  MediaStorage.swift
//  VideoMerger
//
//  Created by đào sơn on 26/11/2023.
//

import UIKit

protocol MediaStorage {
    func isExisted(id: String) -> Bool
    func thumbnailImage(id: String, size: CGSize?) -> UIImage?
    func fileURL(id: String) -> URL
    func getAllIds() -> [String]
}

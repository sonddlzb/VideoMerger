//
//  MediaPickerInteractor+PreviewImage.swift
//  VideoMerger
//
//  Created by đào sơn on 28/11/2023.
//

import Foundation

extension HomeInteractor: PreviewImageListener {
    func previewImageWantToDismiss() {
        self.router?.dismissPreviewImage()
    }
}

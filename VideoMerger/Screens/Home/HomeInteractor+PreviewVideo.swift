//
//  MediaPickerInteractor+PreviewVideo.swift
//  VideoMerger
//
//  Created by đào sơn on 28/11/2023.
//

import Foundation

extension HomeInteractor: PreviewVideoListener {
    func previewVideoWantToDismiss() {
        self.router?.dismissPreviewVideo()
    }
}

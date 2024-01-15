//
//  HomeInteractor+Editor.swift
//  VideoMerger
//
//  Created by đào sơn on 04/01/2024.
//

import Foundation
import Photos

extension HomeInteractor: EditorListener {
    func editorWantToDismiss() {
        self.router?.dismissEditor()
    }

    func editorWantToOpenMediaPicker() {
        self.router?.showMediaPicker(isAddMore: true)
    }

    func editorWantToOpenPreview(avAsset: AVAsset) {
        self.router?.openPreviewVideo(avAsset)
    }
}

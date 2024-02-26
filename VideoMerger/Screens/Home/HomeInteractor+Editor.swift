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

    func editorWantToOpenMediaPicker(isSelectAudio: Bool) {
        self.router?.showMediaPicker(isAddMore: true, isSelectAudio: isSelectAudio)
    }

    func editorWantToOpenPreview(avAsset: AVAsset) {
        self.router?.openPreviewVideo(avAsset)
    }
}

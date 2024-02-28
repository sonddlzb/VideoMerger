//
//  EditorInteractor+AddAudio.swift
//  VideoMerger
//
//  Created by đào sơn on 20/02/2024.
//

import Foundation

extension EditorInteractor: AddAudioListener {
    func addAudioWantToDismiss() {
        self.router?.dismissAddAudio()
    }

    func addAudioDidSelectAudio(_ url: URL) {
        self.router?.dismissAddAudio()
        // MARK: - handle selected audio here
        self.viewModel.listAudio.append(url)
        self.presenter.bind(viewModel: self.viewModel, isNeedToReload: false)
    }

    func addAudioWantToOpenMediaPicker() {
        self.listener?.editorWantToOpenMediaPicker(isSelectAudio: true)
    }
}

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
}

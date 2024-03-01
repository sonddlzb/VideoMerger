//
//  EditorInteractor+ExportResult.swift
//  VideoMerger
//
//  Created by đào sơn on 05/03/2024.
//

import Foundation

extension EditorInteractor: ExportResultListener {
    func exportResultWantToDismiss() {
        self.router?.dismissExportResult()
    }

    func exportResultWantToBackToHome() {
        self.listener?.editorWantToBackToHome()
    }
}

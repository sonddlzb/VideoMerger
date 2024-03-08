//
//  EditorInteractor+Export.swift
//  VideoMerger
//
//  Created by đào sơn on 16/02/2024.
//

import Foundation
import AVFoundation

extension EditorInteractor: ExportListener {
    func exportWantToDismiss() {
        self.router?.dismissExport()
    }

    func exportWantToShowExportResult(exportSession: AVAssetExportSession?) {
        self.router?.dismissExport()
        if let avAsset = self.viewModel.currentComposedAsset {
            self.router?.showExportResult(exportSession: exportSession, name: self.viewModel.projectName)
        }
    }
}

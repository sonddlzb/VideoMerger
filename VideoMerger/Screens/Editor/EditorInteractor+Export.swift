//
//  EditorInteractor+Export.swift
//  VideoMerger
//
//  Created by đào sơn on 16/02/2024.
//

import Foundation

extension EditorInteractor: ExportListener {
    func exportWantToDismiss() {
        self.router?.dismissExport()
    }

    func exportWantToShowExportResult(config: ExportConfiguration) {
        self.router?.dismissExport()
        if let avAsset = self.viewModel.currentComposedAsset {
            self.router?.showExportResult(avAsset: avAsset, config: config)
        }
    }
}

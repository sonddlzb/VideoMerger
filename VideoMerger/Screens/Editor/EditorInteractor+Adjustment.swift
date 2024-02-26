//
//  EditorInteractor+Adjustment.swift
//  VideoMerger
//
//  Created by đào sơn on 15/01/2024.
//

import Foundation

extension EditorInteractor: AdjustmentListener {
    func adjustmentWantToDone(speedType: SpeedType) {
        self.router?.dismissAdjustment()
        self.changeVideoSpeed(speedType: speedType, startTime: self.viewModel.startTimeEdit, endTime: self.viewModel.endTimeEdit)
    }

    func adjusmentWantToDismiss() {
        self.router?.dismissAdjustment()
    }
}

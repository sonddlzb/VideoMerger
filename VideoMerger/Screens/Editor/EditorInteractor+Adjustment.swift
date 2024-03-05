//
//  EditorInteractor+Adjustment.swift
//  VideoMerger
//
//  Created by đào sơn on 15/01/2024.
//

import Foundation

extension EditorInteractor: AdjustmentListener {
    func adjustmentWantToDone(adjustmentViewModel: AdjustmentViewModelType) {
        self.router?.dismissAdjustment()
        if adjustmentViewModel is SpeedViewModel, let speedType = adjustmentViewModel.getValue() as? SpeedType {
            self.changeVideoSpeed(speedType: speedType, startTime: self.viewModel.startTimeEdit, endTime: self.viewModel.endTimeEdit)
        } else if adjustmentViewModel is VolumeViewModel, let volume = adjustmentViewModel.getValue() as? Float {
            self.changeVideoVolume(volume: volume)
        }
    }

    func adjusmentWantToDismiss() {
        self.router?.dismissAdjustment()
        self.presenter.showExpandableView(isShow: true)
    }
}

//
//  EditorInteractor+Adjustment.swift
//  VideoMerger
//
//  Created by đào sơn on 15/01/2024.
//

import Foundation

extension EditorInteractor: AdjustmentListener {
    func adjusmentWantToDismiss() {
        self.router?.dismissAdjustment()
    }
}

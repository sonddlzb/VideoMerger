//
//  VolumeViewModel.swift
//  VideoMerger
//
//  Created by Hưng Hà Quang on 04/03/2024.
//

import Foundation

struct VolumeViewModel: AdjustmentViewModelType {
    private var value: Float

    init(value: Float) {
        self.value = value
    }

    func getValue() -> Any {
        return value
    }

    mutating func setValue(value: Any) {
        if let value = value as? Float {
            self.value = value
        }
    }
}

//
//  SpeedViewModel.swift
//  VideoMerger
//
//  Created by Hưng Hà Quang on 04/03/2024.
//

import Foundation

struct SpeedViewModel: AdjustmentViewModel {
    private var value: SpeedType

    init(value: SpeedType) {
        self.value = value
    }

    func getValue() -> Any {
        return value
    }

    mutating func setValue(value: Any) {
        if let value = value as? SpeedType {
            self.value = value
        }
    }
}

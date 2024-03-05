//
//  AdjustmentViewModel.swift
//  VideoMerger
//
//  Created by đào sơn on 17/01/2024.
//

import Foundation

protocol AdjustmentViewModelType {
    func getValue() -> Any
    mutating func setValue(value: Any)
}

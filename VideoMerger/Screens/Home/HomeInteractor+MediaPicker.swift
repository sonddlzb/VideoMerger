//
//  HomeInteractor+MediaPicker.swift
//  VideoMerger
//
//  Created by đào sơn on 27/11/2023.
//

import Foundation

extension HomeInteractor: MediaPickerListener {
    func mediaPickerWantToDismiss() {
        self.router?.dismissMediaPicker()
    }
}

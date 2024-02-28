//
//  EditorViewModel.swift
//  VideoMerger
//
//  Created by đào sơn on 08/01/2024.
//

import Foundation
import Photos
import RxSwift

struct EditorViewModel {
    var listAssets: [PHAsset]
    var listCurrenAssetDuration: [TimeInterval] = []
    var disposeBag = DisposeBag()
    var currentTime = 0.0
    var currentComposedAsset: AVAsset?
    var listAudio: [URL] = []

    init(listAssets: [PHAsset]) {
        self.listAssets = listAssets
        self.listCurrenAssetDuration = self.listAssets.map { $0.duration }
    }

    static func makeEmpty() -> EditorViewModel {
        return EditorViewModel(listAssets: [])
    }

    func fetchAVAsset(asset: PHAsset, completion: @escaping ((_ avAsset: AVAsset?) -> Void)) {
        asset.fetchAVAsset().subscribe(onNext: completion).disposed(by: disposeBag)
    }

    func duration() -> String {
        return self.currentComposedAsset?.duration.toDurationString() ?? "00:00"
    }

    func numberOfAsset() -> Int {
        return self.listAssets.count
    }

    func asset(at index: Int) -> PHAsset {
        return listAssets[index]
    }

    func secondAt(_ localSecond: Int, index: Int) -> Int {
        guard index > 0 else {
            return localSecond
        }

        var currentSecond = 0
        for id in 0...index-1 {
            currentSecond += Int(self.listAssets[id].duration)
        }

        return currentSecond + localSecond
    }

    mutating func addMoreAssets(_ listAssets: [PHAsset]) {
        self.listAssets.append(contentsOf: listAssets)
        self.listCurrenAssetDuration = self.listAssets.map { $0.duration }
    }
}

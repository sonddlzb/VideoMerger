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
    var disposeBag = DisposeBag()
    var currentTime = 0.0

    static func makeEmpty() -> EditorViewModel {
        return EditorViewModel(listAssets: [])
    }

    func fetchAVAsset(completion: @escaping ((_ avAsset: AVAsset?) -> Void)) {
        listAssets.first?.fetchAVAsset().subscribe(onNext: completion).disposed(by: disposeBag)
    }

    func duration() -> String {
        return self.listAssets.first?.formatVideoDuration() ?? "00:00"
    }
}

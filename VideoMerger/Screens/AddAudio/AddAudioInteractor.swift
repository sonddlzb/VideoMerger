//
//  AddAudioInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 20/02/2024.
//

import RIBs
import RxSwift

protocol AddAudioRouting: ViewableRouting {
}

protocol AddAudioPresentable: Presentable {
    var listener: AddAudioPresentableListener? { get set }
}

protocol AddAudioListener: AnyObject {
    func addAudioWantToDismiss()
}

final class AddAudioInteractor: PresentableInteractor<AddAudioPresentable>, AddAudioInteractable {

    weak var router: AddAudioRouting?
    weak var listener: AddAudioListener?

    override init(presenter: AddAudioPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
    }

    override func willResignActive() {
        super.willResignActive()
    }
}

// MARK: - AddAudioPresentableListener
extension AddAudioInteractor: AddAudioPresentableListener {
    func didTapCancel() {
        self.listener?.addAudioWantToDismiss()
    }
}

//
//  SplashInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs
import RxSwift

protocol SplashRouting: ViewableRouting {
}

protocol SplashPresentable: Presentable {
    var listener: SplashPresentableListener? { get set }
}

protocol SplashListener: AnyObject {
}

final class SplashInteractor: PresentableInteractor<SplashPresentable>, SplashInteractable, SplashPresentableListener {

    weak var router: SplashRouting?
    weak var listener: SplashListener?

    override init(presenter: SplashPresentable) {
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

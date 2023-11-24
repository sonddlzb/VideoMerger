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
    func routeToHome()
}

final class SplashInteractor: PresentableInteractor<SplashPresentable>, SplashInteractable {

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

// MARK: - SplashPresentableListener
extension SplashInteractor: SplashPresentableListener {
    func openHome() {
        self.listener?.routeToHome()
    }
}

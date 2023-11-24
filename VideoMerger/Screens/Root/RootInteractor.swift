//
//  RootInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs
import RxSwift

protocol RootRouting: ViewableRouting {
    func routeToSplash()
}

protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
}

protocol RootListener: AnyObject {
}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {

    weak var router: RootRouting?
    weak var listener: RootListener?

    override init(presenter: RootPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        self.router?.routeToSplash()
    }

    override func willResignActive() {
        super.willResignActive()
    }
}

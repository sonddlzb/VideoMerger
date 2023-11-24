//
//  RootRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs

protocol RootInteractable: Interactable, SplashListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
}

final class RootRouter: ViewableRouter<RootInteractable, RootViewControllable> {
    var window: UIWindow
    var splashBuilder: SplashBuildable
    var splashRouter: SplashRouting?

    init(interactor: RootInteractable, viewController: RootViewControllable, window: UIWindow, splashBuilder: SplashBuildable) {
        self.window = window
        self.splashBuilder = splashBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

// MARK: - RootRouting
extension RootRouter: RootRouting {
    func routeToSplash() {
        let router = self.splashBuilder.build(withListener: self.interactor)
        let navigationController = BaseNavigationController(rootViewController: router.viewControllable.uiviewController)
        window.rootViewController = navigationController
        attachChild(router)
        self.splashRouter = router
    }
}

//
//  HomeRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs

protocol HomeInteractable: Interactable, MediaPickerListener {
    var router: HomeRouting? { get set }
    var listener: HomeListener? { get set }
}

protocol HomeViewControllable: ViewControllable {
}

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable> {
    var mediaPickerBuilder: MediaPickerBuildable
    var mediaPickerRouter: MediaPickerRouting?

    init(interactor: HomeInteractable, viewController: HomeViewControllable, mediaPickerBuilder: MediaPickerBuildable) {
        self.mediaPickerBuilder = mediaPickerBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

// MARK: - HomeRouting
extension HomeRouter: HomeRouting {
    func showMediaPicker() {
        guard self.mediaPickerRouter == nil else {
            return
        }

        let router = self.mediaPickerBuilder.build(withListener: self.interactor)
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        self.viewControllable.present(viewControllable: router.viewControllable)
        self.attachChild(router)
        self.mediaPickerRouter = router
    }

    func dismissMediaPicker() {
        guard let router = self.mediaPickerRouter else {
            return
        }

        self.viewControllable.dismiss()
        detachChild(router)
        self.mediaPickerRouter = nil
    }
}

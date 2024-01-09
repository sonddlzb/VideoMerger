//
//  HomeRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs
import Photos

protocol HomeInteractable: Interactable, MediaPickerListener, EditorListener {
    var router: HomeRouting? { get set }
    var listener: HomeListener? { get set }
}

protocol HomeViewControllable: ViewControllable {
}

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable> {
    var mediaPickerBuilder: MediaPickerBuildable
    var mediaPickerRouter: MediaPickerRouting?

    var editorBuilder: EditorBuildable
    var editorRouter: EditorRouting?

    init(interactor: HomeInteractable,
         viewController: HomeViewControllable,
         mediaPickerBuilder: MediaPickerBuildable,
         editorBuilder: EditorBuildable) {
        self.mediaPickerBuilder = mediaPickerBuilder
        self.editorBuilder = editorBuilder
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

    func openEditor(_ listAssets: [PHAsset]) {
        guard self.editorRouter == nil else {
            return
        }

        let router = self.editorBuilder.build(withListener: self.interactor, listAssets: listAssets)
        self.attachChild(router)
        self.viewControllable.push(viewControllable: router.viewControllable)
        self.editorRouter = router
    }

    func dismissEditor() {
        guard let router = self.editorRouter else {
            return
        }

        self.detachChild(router)
        router.viewControllable.popViewControllale()
        self.editorRouter = nil
    }
}

//
//  HomeRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs
import Photos

protocol HomeInteractable: Interactable, MediaPickerListener, EditorListener, PreviewImageListener, PreviewVideoListener  {
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

    private var previewImageRouter: PreviewImageRouting?
    private var previewImageBuilder: PreviewImageBuildable

    private var previewVideoRouter: PreviewVideoRouting?
    private var previewVideoBuilder: PreviewVideoBuildable

    init(interactor: HomeInteractable,
         viewController: HomeViewControllable,
         mediaPickerBuilder: MediaPickerBuildable,
         editorBuilder: EditorBuildable,
         previewImageBuilder: PreviewImageBuildable,
         previewVideoBuilder: PreviewVideoBuildable) {
        self.mediaPickerBuilder = mediaPickerBuilder
        self.editorBuilder = editorBuilder
        self.previewImageBuilder = previewImageBuilder
        self.previewVideoBuilder = previewVideoBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

// MARK: - HomeRouting
extension HomeRouter: HomeRouting {
    func showMediaPicker(isAddMore: Bool) {
        guard self.mediaPickerRouter == nil else {
            return
        }

        let router = self.mediaPickerBuilder.build(withListener: self.interactor, isAddMore: isAddMore)
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

    func openEditor(_ listAssets: [PHAsset], isAddMore: Bool) {
        if self.editorRouter != nil {
            if isAddMore {
                self.editorRouter?.bind(listAddedAssets: listAssets)
            }

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

    func openPreviewImage(_ asset: PHAsset) {
        guard self.previewImageRouter == nil else {
            return
        }

        let router = self.previewImageBuilder.build(withListener: self.interactor, asset: asset)
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        self.viewController.present(viewControllable: router.viewControllable)
        self.attachChild(router)
        self.previewImageRouter = router
    }

    func dismissPreviewImage() {
        guard let router = self.previewImageRouter else {
            return
        }

        router.viewControllable.dismiss()
        self.detachChild(router)
        self.previewImageRouter = nil
    }

    func openPreviewVideo(_ asset: PHAsset) {
        guard self.previewVideoRouter == nil else {
            return
        }

        let router = self.previewVideoBuilder.build(withListener: self.interactor, asset: asset)
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        self.viewController.present(viewControllable: router.viewControllable)
        self.attachChild(router)
        self.previewVideoRouter = router
    }

    func openPreviewVideo(_ asset: AVAsset) {
        guard self.previewVideoRouter == nil else {
            return
        }

        let router = self.previewVideoBuilder.build(withListener: self.interactor, asset: asset)
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        self.viewController.present(viewControllable: router.viewControllable)
        self.attachChild(router)
        self.previewVideoRouter = router
    }

    func dismissPreviewVideo() {
        guard let router = self.previewVideoRouter else {
            return
        }

        router.viewControllable.dismiss()
        self.detachChild(router)
        self.previewVideoRouter = nil
    }
}

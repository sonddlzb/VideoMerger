//
//  MediaPickerRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 27/11/2023.
//

import RIBs
import Photos

protocol MediaPickerInteractable: Interactable, PreviewImageListener {
    var router: MediaPickerRouting? { get set }
    var listener: MediaPickerListener? { get set }
}

protocol MediaPickerViewControllable: ViewControllable {
}

final class MediaPickerRouter: ViewableRouter<MediaPickerInteractable, MediaPickerViewControllable> {
    private var previewImageRouter: PreviewImageRouting?
    private var previewImageBuilder: PreviewImageBuildable

    init(interactor: MediaPickerInteractable,
         viewController: MediaPickerViewControllable,
         previewImageBuilder: PreviewImageBuildable) {
        self.previewImageBuilder = previewImageBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

// MARK: - MediaPickerRouting
extension MediaPickerRouter: MediaPickerRouting {
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
}

//
//  ExportResultRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 05/03/2024.
//

import RIBs
import AVFoundation

protocol ExportResultInteractable: Interactable, PreviewVideoListener {
    var router: ExportResultRouting? { get set }
    var listener: ExportResultListener? { get set }
}

protocol ExportResultViewControllable: ViewControllable {
}

final class ExportResultRouter: ViewableRouter<ExportResultInteractable, ExportResultViewControllable>, ExportResultRouting {
    private var previewVideoRouter: PreviewVideoRouting?
    private var previewVideoBuilder: PreviewVideoBuildable

    init(interactor: ExportResultInteractable, viewController: ExportResultViewControllable, previewVideoBuilder: PreviewVideoBuildable) {
        self.previewVideoBuilder = previewVideoBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func showPreviewVideo(_ asset: AVAsset) {
        guard previewVideoRouter == nil else {
            return
        }

        let router = self.previewVideoBuilder.build(withListener: self.interactor, asset: asset)
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        self.viewControllable.uiviewController.present(router.viewControllable.uiviewController, animated: true)
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

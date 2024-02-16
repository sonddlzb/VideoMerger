//
//  EditorRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 04/01/2024.
//

import RIBs
import Photos

protocol EditorInteractable: Interactable, AdjustmentListener, ExportListener {
    var router: EditorRouting? { get set }
    var listener: EditorListener? { get set }

    func bind(listAddedAssets: [PHAsset])
}

protocol EditorViewControllable: ViewControllable {
}

final class EditorRouter: ViewableRouter<EditorInteractable, EditorViewControllable> {

    private var adjustmentBuilder: AdjustmentBuildable
    private var adjustmentRouter: AdjustmentRouting?

    private var exportBuilder: ExportBuildable
    private var exportRouter: ExportRouting?

    init(interactor: EditorInteractable,
         viewController: EditorViewControllable,
         adjustmentBuilder: AdjustmentBuildable,
         exportBuilder: ExportBuildable) {
        self.adjustmentBuilder = adjustmentBuilder
        self.exportBuilder = exportBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

// MARK: - EditorRouting
extension EditorRouter: EditorRouting {
    func bind(listAddedAssets: [PHAsset]) {
        self.interactor.bind(listAddedAssets: listAddedAssets)
    }

    func showAdjustment(type: AdjustmentType) {
        guard self.adjustmentRouter == nil else {
            return
        }

        let router = self.adjustmentBuilder.build(withListener: self.interactor, type: type)
        self.attachChild(router)
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        self.viewController.present(viewControllable: router.viewControllable)
        self.adjustmentRouter = router
    }

    func dismissAdjustment() {
        guard let router = self.adjustmentRouter else {
            return
        }

        router.viewControllable.dismiss()
        self.detachChild(router)
        self.adjustmentRouter = nil
    }

    func showExport() {
        guard self.adjustmentRouter == nil else {
            return
        }

        let router = self.exportBuilder.build(withListener: self.interactor)
        self.attachChild(router)
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        self.viewController.present(viewControllable: router.viewControllable)
        self.exportRouter = router
    }

    func dismissExport() {
        guard let router = self.exportRouter else {
            return
        }

        router.viewControllable.dismiss()
        self.detachChild(router)
        self.exportRouter = nil
    }
}

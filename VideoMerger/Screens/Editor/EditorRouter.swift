//
//  EditorRouter.swift
//  VideoMerger
//
//  Created by đào sơn on 04/01/2024.
//

import RIBs
import Photos

protocol EditorInteractable: Interactable, AdjustmentListener, ExportListener, AddAudioListener, ExportResultListener {
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

    private var addAudioBuilder: AddAudioBuildable
    private var addAudioRouter: AddAudioRouting?

    private var exportResultBuilder: ExportResultBuildable
    private var exportResultRouter: ExportResultRouting?

    init(interactor: EditorInteractable,
         viewController: EditorViewControllable,
         adjustmentBuilder: AdjustmentBuildable,
         exportBuilder: ExportBuildable,
         addAudioBuilder: AddAudioBuildable,
         exportResultBuilder: ExportResultBuildable) {
        self.adjustmentBuilder = adjustmentBuilder
        self.exportBuilder = exportBuilder
        self.addAudioBuilder = addAudioBuilder
        self.exportResultBuilder = exportResultBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

// MARK: - EditorRouting
extension EditorRouter: EditorRouting {
    func bind(listAddedAssets: [PHAsset]) {
        self.interactor.bind(listAddedAssets: listAddedAssets)
    }

    func showAdjustment(adjustmentType: AdjustmentType, value: Any) {
        guard self.adjustmentRouter == nil else {
            return
        }

        guard let editorViewController = self.viewController as? EditorViewController else {
            return
        }

        let router = self.adjustmentBuilder.build(withListener: self.interactor, adjustmentType: adjustmentType, value: value)
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

    func showExport(avAsset: AVAsset, volume: Float) {
        guard self.adjustmentRouter == nil else {
            return
        }

        let router = self.exportBuilder.build(withListener: self.interactor, avAsset: avAsset, volume: volume)
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

    func showAddAudio() {
        guard self.addAudioRouter == nil else {
            return
        }

        let router = self.addAudioBuilder.build(withListener: self.interactor)
        self.attachChild(router)
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        self.viewController.present(viewControllable: router.viewControllable)
        self.addAudioRouter = router
    }

    func dismissAddAudio() {
        guard let router = self.addAudioRouter else {
            return
        }

        router.viewControllable.dismiss()
        self.detachChild(router)
        self.addAudioRouter = nil
    }

    func showExportResult(avAsset: AVAsset, config: ExportConfiguration) {
        guard self.exportResultRouter == nil else {
            return
        }

        let router = self.exportResultBuilder.build(withListener: self.interactor, avAsset: avAsset, config: config)
        self.attachChild(router)
        self.viewControllable.push(viewControllable: router.viewControllable)
        self.exportResultRouter = router
    }

    func dismissExportResult() {
        guard let router = self.exportResultRouter else {
            return
        }

        self.detachChild(router)
        self.viewControllable.popToBefore(viewControllable: router.viewControllable)
        self.exportResultRouter = nil
    }
}

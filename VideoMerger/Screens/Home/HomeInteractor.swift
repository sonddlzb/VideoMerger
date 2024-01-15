//
//  HomeInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import RIBs
import RxSwift
import Photos

protocol HomeRouting: ViewableRouting {
    func showMediaPicker(isAddMore: Bool)
    func dismissMediaPicker()
    func openEditor(_ listAssets: [PHAsset], isAddMore: Bool)
    func dismissEditor()
    func openPreviewImage(_ asset: PHAsset)
    func dismissPreviewImage()
    func openPreviewVideo(_ asset: PHAsset)
    func dismissPreviewVideo()
    func openPreviewVideo(_ asset: AVAsset)
}

protocol HomePresentable: Presentable {
    var listener: HomePresentableListener? { get set }

    func showOpenSettingDialog()
}

protocol HomeListener: AnyObject {
}

final class HomeInteractor: PresentableInteractor<HomePresentable>, HomeInteractable {

    weak var router: HomeRouting?
    weak var listener: HomeListener?

    override init(presenter: HomePresentable) {
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

// MARK: - HomePresentableListener
extension HomeInteractor: HomePresentableListener {
    func didSelectCreateNewProject() {
        PermissionHelper().requestPhotoPermission { granted, isNeedOpenSetting in
            if isNeedOpenSetting {
                self.presenter.showOpenSettingDialog()
                return
            }

            if granted {
                self.router?.showMediaPicker(isAddMore: false)
            }
        }
    }
}

//
//  PreviewVideoBuilder.swift
//  Zip
//
//  Created by đào sơn on 03/09/2022.
//

import RIBs
import Photos

protocol PreviewVideoDependency: Dependency {

}

final class PreviewVideoComponent: Component<PreviewVideoDependency> {
}

// MARK: - Builder

protocol PreviewVideoBuildable: Buildable {
    func build(withListener listener: PreviewVideoListener, asset: PHAsset) -> PreviewVideoRouting
    func build(withListener listener: PreviewVideoListener, asset: AVAsset) -> PreviewVideoRouting
}

final class PreviewVideoBuilder: Builder<PreviewVideoDependency>, PreviewVideoBuildable {

    override init(dependency: PreviewVideoDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PreviewVideoListener, asset: PHAsset) -> PreviewVideoRouting {
        // let component = PreviewVideoComponent(dependency: dependency)
        let viewController = PreviewVideoViewController()
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .fullScreen
        let interactor = PreviewVideoInteractor(presenter: viewController, asset: asset, avAsset: nil)
        interactor.listener = listener
        return PreviewVideoRouter(interactor: interactor, viewController: viewController)
    }

    func build(withListener listener: PreviewVideoListener, asset: AVAsset) -> PreviewVideoRouting {
        // let component = PreviewVideoComponent(dependency: dependency)
        let viewController = PreviewVideoViewController()
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .fullScreen
        let interactor = PreviewVideoInteractor(presenter: viewController, asset: nil, avAsset: asset)
        interactor.listener = listener
        return PreviewVideoRouter(interactor: interactor, viewController: viewController)
    }
}

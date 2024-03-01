//
//  ExportResultBuilder.swift
//  VideoMerger
//
//  Created by đào sơn on 05/03/2024.
//

import RIBs
import AVFoundation

protocol ExportResultDependency: Dependency {

}

final class ExportResultComponent: Component<ExportResultDependency> {
}

// MARK: - Builder

protocol ExportResultBuildable: Buildable {
    func build(withListener listener: ExportResultListener,
               avAsset: AVAsset,
               config: ExportConfiguration) -> ExportResultRouting
}

final class ExportResultBuilder: Builder<ExportResultDependency>, ExportResultBuildable {

    override init(dependency: ExportResultDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ExportResultListener, avAsset: AVAsset, config: ExportConfiguration) -> ExportResultRouting {
        let component = ExportResultComponent(dependency: dependency)
        let viewController = ExportResultViewController()
        let interactor = ExportResultInteractor(presenter: viewController, avAsset: avAsset, config: config)
        interactor.listener = listener
        return ExportResultRouter(interactor: interactor, viewController: viewController)
    }
}

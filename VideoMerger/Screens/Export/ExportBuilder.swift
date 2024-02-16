//
//  ExportBuilder.swift
//  VideoMerger
//
//  Created by đào sơn on 23/01/2024.
//

import RIBs

protocol ExportDependency: Dependency {

}

final class ExportComponent: Component<ExportDependency> {
}

// MARK: - Builder

protocol ExportBuildable: Buildable {
    func build(withListener listener: ExportListener) -> ExportRouting
}

final class ExportBuilder: Builder<ExportDependency>, ExportBuildable {

    override init(dependency: ExportDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ExportListener) -> ExportRouting {
        let component = ExportComponent(dependency: dependency)
        let viewController = ExportViewController()
        let interactor = ExportInteractor(presenter: viewController)
        interactor.listener = listener
        return ExportRouter(interactor: interactor, viewController: viewController)
    }
}

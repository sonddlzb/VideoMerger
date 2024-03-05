//
//  AdjustmentBuilder.swift
//  VideoMerger
//
//  Created by đào sơn on 15/01/2024.
//

import RIBs

protocol AdjustmentDependency: Dependency {

}

final class AdjustmentComponent: Component<AdjustmentDependency> {
}

// MARK: - Builder

protocol AdjustmentBuildable: Buildable {
    func build(withListener listener: AdjustmentListener, adjustmentViewModel: AdjustmentViewModel) -> AdjustmentRouting
}

final class AdjustmentBuilder: Builder<AdjustmentDependency>, AdjustmentBuildable {
    override init(dependency: AdjustmentDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: AdjustmentListener, adjustmentViewModel: AdjustmentViewModel) -> AdjustmentRouting {
        let component = AdjustmentComponent(dependency: dependency)
        let viewController = AdjustmentViewController()
        let interactor = AdjustmentInteractor(presenter: viewController, adjustmentViewModel: adjustmentViewModel)
        interactor.listener = listener
        return AdjustmentRouter(interactor: interactor, viewController: viewController)
    }
}

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
    func build(withListener listener: AdjustmentListener, adjustmentType: AdjustmentType, value: Any) -> AdjustmentRouting
}

final class AdjustmentBuilder: Builder<AdjustmentDependency>, AdjustmentBuildable {
    override init(dependency: AdjustmentDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: AdjustmentListener, adjustmentType: AdjustmentType, value: Any) -> AdjustmentRouting {
        let component = AdjustmentComponent(dependency: dependency)
        let viewController = AdjustmentViewController()
        var adjustmentViewModelType: AdjustmentViewModelType = VolumeViewModel(value: 1.0)
        switch adjustmentType {
        case .volume:
            if let value = value as? Float {
                adjustmentViewModelType = VolumeViewModel(value: value)
            }

        case .speed:
            if let value = value as? SpeedType {
                adjustmentViewModelType = SpeedViewModel(value: value)
            }

        default:
            break
        }

        let interactor = AdjustmentInteractor(presenter: viewController, adjustmentViewModelType: adjustmentViewModelType)
        interactor.listener = listener
        return AdjustmentRouter(interactor: interactor, viewController: viewController)
    }
}

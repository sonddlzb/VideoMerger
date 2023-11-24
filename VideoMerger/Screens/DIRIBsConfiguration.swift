//
//  DIRIBsConfiguration.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import Foundation

extension DIConnector {
    static func registerAllRibs() {
        DIContainer.register(RootBuildable.self) { _, args in
            return RootBuilder(dependency: args.get())
        }

        DIContainer.register(SplashBuildable.self) { _, args in
            return SplashBuilder(dependency: args.get())
        }
    }
}

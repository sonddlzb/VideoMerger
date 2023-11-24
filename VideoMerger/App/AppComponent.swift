//
//  AppComponent.swift
//  VideoMerger
//
//  Created by đào sơn on 24/11/2023.
//

import Foundation
import RIBs

class AppComponent: Component<EmptyDependency>, RootDependency {
    var window: UIWindow

    init(window: UIWindow) {
        self.window = window
        super.init(dependency: EmptyComponent())
    }
}

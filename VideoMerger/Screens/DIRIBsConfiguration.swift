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

        DIContainer.register(HomeBuildable.self) { _, args in
            return HomeBuilder(dependency: args.get())
        }

        DIContainer.register(MediaPickerBuildable.self) { _, args in
            return MediaPickerBuilder(dependency: args.get())
        }

        DIContainer.register(PreviewImageBuildable.self) { _, args in
            return PreviewImageBuilder(dependency: args.get())
        }

        DIContainer.register(PreviewVideoBuildable.self) { _, args in
            return PreviewVideoBuilder(dependency: args.get())
        }

        DIContainer.register(EditorBuildable.self) { _, args in
            return EditorBuilder(dependency: args.get())
        }

        DIContainer.register(AdjustmentBuildable.self) { _, args in
            return AdjustmentBuilder(dependency: args.get())
        }

        DIContainer.register(ExportBuildable.self) { _, args in
            return ExportBuilder(dependency: args.get())
        }

        DIContainer.register(AddAudioBuildable.self) { _, args in
            return AddAudioBuilder(dependency: args.get())
        }

        DIContainer.register(ExportResultBuildable.self) { _, args in
            return ExportResultBuilder(dependency: args.get())
        }
    }
}

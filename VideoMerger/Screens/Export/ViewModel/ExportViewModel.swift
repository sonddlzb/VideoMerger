//
//  ExportViewModel.swift
//  VideoMerger
//
//  Created by đào sơn on 28/02/2024.
//

import Foundation
import AVFoundation

enum VideoResolution: String, CaseIterable {
    case p540 = "960x540"
    case p720 = "1280x720"
    case p1080 = "1920x1080"
    case p2K = "2048x1080"
    case p4K = "3840x2160"

    var size: CGSize {
        let components = self.rawValue.components(separatedBy: "x")
        guard components.count == 2,
              let width = Double(components[0]),
              let height = Double(components[1]) else {
            return CGSize(width: 0, height: 0)
        }

        return CGSize(width: width, height: height)
    }

    func symbol() -> String {
        switch self {
        case .p540:
            return "540p"
        case .p720:
            return "720p"
        case .p1080:
            return "1080p"
        case .p2K:
            return "2k"
        case .p4K:
            return "4k"
        }
    }
}

enum VideoFps: String, CaseIterable {
    case fps24 = "24"
    case fps25 = "25"
    case fps30 = "30"
    case fps50 = "50"
    case fps60 = "60"
}

struct ExportConfiguration {
    var resolution: VideoResolution
    var fps: VideoFps
}

struct ExportViewModel {
    var config: ExportConfiguration
}

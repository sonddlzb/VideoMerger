//
//  ItemFrameViewModel.swift
//  VideoMerger
//
//  Created by Hưng Hà Quang on 01/03/2024.
//

import Foundation
import UIKit

struct ItemFrameViewModel {
    var url: URL?
    var time: String?
    var scale: Double?
    var isFrame: Bool = true
    init(url: URL?, time: String?, scale: Double?, isFrame: Bool?) {
        self.url = url
        self.time = time
        self.scale = scale
        if let isFrame = isFrame {
            self.isFrame = isFrame
        }
    }

    func getImage() -> UIImage? {
        guard let url = self.url else { return nil }
        do {
            if let image = UIImage(data: try Data(contentsOf: url)) {
                return image
            }
        } catch {
            print("Error reading file \(url): \(error.localizedDescription)")
        }

        return nil
    }
}

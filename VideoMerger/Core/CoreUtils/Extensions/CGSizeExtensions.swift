//
//  CGSizeExtensions.swift
//  KiteVid
//
//  Created by Thanh Vu on 29/04/2021.
//  Copyright © 2021 Thanh Vu. All rights reserved.
//

import Foundation
import UIKit

public extension CGSize {
    func ratio() -> CGFloat {
        return self.width / self.height
    }
}

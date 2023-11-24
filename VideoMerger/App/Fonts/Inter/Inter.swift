//
//  Inter.swift
//  ColoringByPixel
//
//  Created by Linh Nguyen Duc on 29/09/2022.
//

import UIKit

class Inter: BaseFont {
    override class func name() -> String {
        return "Inter"
    }

    override class func semiBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "\(name())-SemiBold", size: size)!
    }
}

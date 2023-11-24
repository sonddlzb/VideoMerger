//
//  BaseFont.swift
//  ColoringByPixel
//
//  Created by Linh Nguyen Duc on 28/09/2022.
//

import UIKit

public class BaseFont {
    class func name() -> String {
        return ""
    }

    public class func lightFont(size: CGFloat) -> UIFont {
        return UIFont(name: "\(name())-Light", size: size)!
    }

    public class func regularFont(size: CGFloat) -> UIFont {
        return UIFont(name: "\(name())-Regular", size: size)!
    }

    public class func mediumFont(size: CGFloat) -> UIFont {
        return UIFont(name: "\(name())-Medium", size: size)!
    }

    public class func semiBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "\(name())-SemiBold", size: size)!
    }

    public class func boldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "\(name())-Bold", size: size)!
    }
}

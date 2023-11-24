//
//  Presentable+Loading.swift
//  RIBsExtensions
//
//  Created by Thanh Vu on 08/09/2021.
//

import Foundation
import SVProgressHUD
import RIBs

public extension Presentable {
    func showLoading() {
        SVProgressHUD.show()
    }

    func dismissLoading() {
        SVProgressHUD.dismiss()
    }
}

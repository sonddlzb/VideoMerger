//
//  SolarRequestPermissionResponse.swift
//  GifMaker
//
//  Created by Thanh Vu on 18/10/2021.
//

import Foundation

public typealias SolarRequestPermissionResponse = (_ granted: Bool, _ needOpenAppSetting: Bool) -> Void

public typealias SolarRequestNotificationPermissionResponse = ((_ status: Bool, _ error: Error?) -> Void)

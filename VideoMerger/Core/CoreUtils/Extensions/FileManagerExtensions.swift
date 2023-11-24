//
//  FileManagerExtensions.swift
//
//  Created by Thanh Vu on 12/02/2021.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation

public extension FileManager {
    static func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    }

    static func userPath() -> String {
        var documentURL = self.documentURL()
        documentURL.deleteLastPathComponent()
        return documentURL.path
    }

    static func documentURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }

    static func cacheURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last!
    }

    static func paintPictureFolderURL() -> URL {
        let url = self.documentURL().appendingPathComponent("PaintingPicture")
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }

        return url
    }

    static func myDrawFolderURL() -> URL {
        var isDir: ObjCBool = true
        let url = self.documentURL().appendingPathComponent("MyDraw")
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }

        return url
    }

    private static func createDirIfNeeded(path: String) {
        var isDirectoryOutput: ObjCBool = false
        let pointer = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        pointer.initialize(from: &isDirectoryOutput, count: 1)

        if FileManager.default.fileExists(atPath: path, isDirectory: pointer) == false || isDirectoryOutput.boolValue == false {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
        }
    }
}

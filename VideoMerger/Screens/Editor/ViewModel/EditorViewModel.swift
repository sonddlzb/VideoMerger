//
//  EditorViewModel.swift
//  VideoMerger
//
//  Created by đào sơn on 08/01/2024.
//

import Foundation
import Photos
import RxSwift

struct EditorViewModel {
    var listAssets: [PHAsset]
    var disposeBag = DisposeBag()
    var currentTime = 0.0
    var currentComposedAsset: AVAsset?
    var speedType: SpeedType = .speedC {
        didSet {
            self.oldSpeedType = oldValue
        }
    }

    var volume: Float = 1.0
    var oldSpeedType: SpeedType = .speedC
    var startTimeEdit: TimeInterval = 0.0
    var endTimeEdit: TimeInterval = 0.0
    var projectName: String = "Project 1"
    private lazy var editorDirectory: URL = {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("editorData")
    }()
    init(listAssets: [PHAsset]) {
        self.listAssets = listAssets
        createDirectoryIfNotExists(editorDirectory)
    }

    static func makeEmpty() -> EditorViewModel {
        return EditorViewModel(listAssets: [])
    }

    func fetchAVAsset(asset: PHAsset, completion: @escaping ((_ avAsset: AVAsset?) -> Void)) {
        asset.fetchAVAsset().subscribe(onNext: completion).disposed(by: disposeBag)
    }

    func duration() -> String {
        return self.currentComposedAsset?.duration.toDurationString() ?? "00:00"
    }

    func numberOfAsset() -> Int {
        return self.listAssets.count
    }

    func asset(at index: Int) -> PHAsset {
        return listAssets[index]
    }

    func secondAt(_ localSecond: Int, index: Int) -> Int {
        guard index > 0 else {
            return localSecond
        }

        var currentSecond = 0
        for id in 0...index-1 {
            currentSecond += Int(ceil(self.listAssets[id].duration))
        }

        return currentSecond + localSecond
    }

    mutating func addMoreAssets(_ listAssets: [PHAsset]) {
        self.listAssets.append(contentsOf: listAssets)
    }

    mutating func saveImageToCaches(_ fileName: String, data: Data) -> URL? {
        let fileURL = self.editorDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving file: \(error.localizedDescription)")
        }

        return nil
    }

    mutating func resetEditorFolder() {
        if FileManager.default.fileExists(atPath: self.editorDirectory.path) {
            do {
                try FileManager.default.removeItem(at: self.editorDirectory)
            } catch {
                print("Error deleting folder: \(error.localizedDescription)")
            }

            createDirectoryIfNotExists(self.editorDirectory)
        }
    }

    private mutating func createDirectoryIfNotExists(_ directory: URL) {
          do {
              if !FileManager.default.fileExists(atPath: directory.path) {
                  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
              }
          } catch {
              print("Error creating directory: \(error.localizedDescription)")
          }
      }
}

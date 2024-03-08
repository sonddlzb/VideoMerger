//
//  ExportResultInteractor.swift
//  VideoMerger
//
//  Created by đào sơn on 05/03/2024.
//

import RIBs
import RxSwift
import AVFoundation

protocol ExportResultRouting: ViewableRouting {
}

protocol ExportResultPresentable: Presentable {
    var listener: ExportResultPresentableListener? { get set }

    func bind(viewModel: ExportResultViewModel, outputURL: URL?, progress: Float)
}

protocol ExportResultListener: AnyObject {
    func exportResultWantToDismiss()
    func exportResultWantToBackToHome()
}

final class ExportResultInteractor: PresentableInteractor<ExportResultPresentable>, ExportResultInteractable {

    weak var router: ExportResultRouting?
    weak var listener: ExportResultListener?
    var viewModel: ExportResultViewModel
    let disposeBag = DisposeBag()

    init(presenter: ExportResultPresentable, exportSession: AVAssetExportSession?, name: String) {
        self.viewModel = ExportResultViewModel(exportSession: exportSession, name: name)
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
    }

    override func willResignActive() {
        super.willResignActive()
    }

    func exportAsset(exportSession: AVAssetExportSession?, name: String, completion: @escaping (_ outputURL: URL?) -> Void) -> Observable<Float>? {
        guard let exportSession = exportSession else {
            completion(nil)
            return nil
        }

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("exported")
        try? documentsDirectory.createDirectoryIfNeeded()

        let outputURL = documentsDirectory.appendingPathComponent("\(name).mp4")
        try? FileManager.default.removeItem(at: outputURL)

        exportSession.outputURL = outputURL

        return Observable<Float>.create { observer in
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                let progress = exportSession.progress
                observer.onNext(progress)
                if progress == 1 {
                    observer.onCompleted()
                }
            }

            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed:
                    print("Export completed. Video file saved at \(outputURL) with file size \(self.getFileSize(atURL: outputURL)!.formatStorage()))")
                    completion(outputURL)
                case .failed:
                    print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                case .cancelled:
                    print("Export cancelled")
                default:
                    break
                }
            })

            return Disposables.create()
        }
    }

    func getFileSize(atURL fileURL: URL) -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? Int64 {
                return fileSize
            } else {
                print("Failed to retrieve file size.")
                return nil
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - ExportResultPresentableListener
extension ExportResultInteractor: ExportResultPresentableListener {
    func exportVideo() {
        let name = self.viewModel.name
        let defaultName = "Project 1"
        self.exportAsset(exportSession: self.viewModel.exportSession, name: !name.isEmpty ? name : defaultName, completion: { [weak self] outputURL in
            if let self = self {
                self.presenter.bind(viewModel: self.viewModel, outputURL: outputURL, progress: 1.0)
            }
        })?.subscribe(onNext: { [weak self] progress in
            if let self = self {
                self.presenter.bind(viewModel: self.viewModel, outputURL: nil, progress: progress)
            }
        }).disposed(by: disposeBag)
    }

    func didTapBack() {
        self.listener?.exportResultWantToDismiss()
    }

    func didTapHome() {
        self.listener?.exportResultWantToBackToHome()
    }
}

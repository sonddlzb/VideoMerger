//
//  AddAudioViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 20/02/2024.
//

import RIBs
import RxSwift
import UIKit

protocol AddAudioPresentableListener: AnyObject {
    func didTapCancel()
    func didSelectAudio(_ url: URL)
    func didTapGetAudioFromVideo()
}

final class AddAudioViewController: UIViewController, AddAudioPresentable, AddAudioViewControllable {
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!

    // MARK: - Variables
    weak var listener: AddAudioPresentableListener?
    private lazy var documentPickerVC: UIDocumentPickerViewController = {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        return documentPicker
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.layer.shadowColor = UIColor.gray.cgColor
        self.containerView.layer.shadowOpacity = 0.25
        self.containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        self.containerView.layer.shadowRadius = 4
    }

    // MARK: - Actions
    @IBAction func didTapGetAudioFromVideos(_ sender: Any) {
        self.listener?.didTapGetAudioFromVideo()
    }

    @IBAction func didTapGetAudioFromDevices(_ sender: Any) {
        self.present(self.documentPickerVC, animated: true, completion: nil)
    }

    @IBAction func didTapCancel(_ sender: Any) {
        self.listener?.didTapCancel()
    }
}

// MARK: - UIDocumentPickerDelegate
extension AddAudioViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedAudioURL = urls.first {
            print("Selected audio file: \(selectedAudioURL)")
            self.listener?.didSelectAudio(selectedAudioURL)
        }
    }
}

//
//  EditorViewController.swift
//  VideoMerger
//
//  Created by đào sơn on 04/01/2024.
//

import RIBs
import RxSwift
import UIKit
import Photos

protocol EditorPresentableListener: AnyObject {
    func didTapBack()
    func updateCurrentVideoTime(currentTime: Double)
}

final class EditorViewController: UIViewController, EditorViewControllable {
    // MARK: - Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var playView: PlayerView!
    @IBOutlet weak var playBarView: PlayBarView!
    @IBOutlet weak var frameScrollView: UIScrollView!

    @IBOutlet weak var borderView: UIView!
    // MARK: - Variables
    @IBOutlet weak var frameStackView: UIStackView!
    weak var listener: EditorPresentableListener?
    var viewModel = EditorViewModel.makeEmpty()
    private var timeObserverToken: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    deinit {
        self.removePeriodicTimeObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.layer.shadowOpacity = 0.1
        self.headerView.layer.shadowOffset = CGSize(width: -4, height: 4)
        self.headerView.layer.shadowRadius = 4
        self.headerView.layer.masksToBounds = false

        self.addGradientLayer()
    }

    private func config() {
        playBarView.delegate = self
        frameScrollView.delegate = self
        frameScrollView.showsHorizontalScrollIndicator = false
    }

    func loadAssets() {
        self.viewModel.fetchAVAsset(completion: { [weak self] avAsset in
            guard let self = self else {
                return
            }

            if let asset = avAsset {
                DispatchQueue.main.async {
                    self.playView.replacePlayerItem(AVPlayerItem(asset: asset))
                    self.frameStackView.arrangedSubviews.forEach {$0.removeFromSuperview()}
                    let leftPaddingView = UIView()
                    leftPaddingView.translatesAutoresizingMaskIntoConstraints = false
                    self.frameStackView.addArrangedSubview(leftPaddingView)
                    leftPaddingView.widthAnchor.constraint(equalTo: self.frameScrollView.widthAnchor, multiplier: 0.5).isActive = true
                    asset.extractFrames(fps: 1) { image, error, isFinish in
                        guard error == nil else {
                            print("Error when extracting frames: \(error!.localizedDescription)")
                            return
                        }

                        DispatchQueue.main.async {
                            if let image = image {
                                let imageView = UIImageView()
                                imageView.translatesAutoresizingMaskIntoConstraints = false
                                imageView.image = image
                                self.frameStackView.addArrangedSubview(imageView)
                                imageView.widthAnchor.constraint(equalToConstant: self.frameScrollView.frame.height*image.scale).isActive = true
                                if isFinish {
                                    let rightPaddingView = UIView()
                                    rightPaddingView.translatesAutoresizingMaskIntoConstraints = false
                                    self.frameStackView.addArrangedSubview(rightPaddingView)
                                    rightPaddingView.widthAnchor.constraint(equalTo: self.frameScrollView.widthAnchor, multiplier: 0.5).isActive = true
                                }
                            }
                        }
                    }
                }
            }
        })

        addPeriodicTimeObserverForVideo()
        self.playView.setLayerVideoGravity(.resizeAspect)
        self.playView.loopEnable = true
        self.playView.delegate = self

        self.playBarView.bind(duration: self.viewModel.duration())
        if self.playBarView.isPlaying {
            self.playView.play()
        } else {
            self.playView.pause()
        }
    }

    func addPeriodicTimeObserverForVideo() {
        removePeriodicTimeObserver()
        let time = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.timeObserverToken = self.playView.addTimeObserver(forInterval: time, queue: .main, using: {[weak self] time in
            self?.listener?.updateCurrentVideoTime(currentTime: time.seconds)
        })
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.playView.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    private func addGradientLayer() {
        self.gradientView.layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }

        self.view.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.gradientView.bounds
        let startColor = UIColor(rgb: 0xF2F2F2)
        let endColor = UIColor.white.withAlphaComponent(0)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        self.gradientView.layer.addSublayer(gradientLayer)
    }
    // MARK: - Actions
    @IBAction func didTapBackButton(_ sender: Any) {
        self.listener?.didTapBack()
    }
}

// MARK: - PlayBarViewDelegate
extension EditorViewController: PlayBarViewDelegate {
    func playBarViewDidTapPlay(_ playBarView: PlayBarView, isPlaying: Bool) {
        self.playView.isPlaying() ? self.playView.pause() : self.playView.play()
    }

    func playBarViewDidTapFullScreen(_ playBarView: PlayBarView) {

    }

    func playBarViewDidTapUndo(_ playBarView: PlayBarView) {

    }

    func playBarViewDidTapRedo(_ playBarView: PlayBarView) {

    }
}

// MARK: - EditorPresentable
extension EditorViewController: EditorPresentable {
    func bind(viewModel: EditorViewModel) {
        self.loadViewIfNeeded()
        self.viewModel = viewModel
        self.loadAssets()
    }

    func bind(currentTime: Double) {
        self.playBarView.bind(currentTime: String(Int(viewModel.currentTime)).formatVideoDuration())
        if self.playView.isPlaying(), let duration = self.playView.duration() {
            self.frameScrollView.contentOffset.x = currentTime/CMTimeGetSeconds(duration)*Double(frameScrollView.contentSize.width - frameScrollView.frame.width)
        }
    }
}

// MARK: PlayerViewDelegate
extension EditorViewController: PlayerViewDelegate {
    func playerViewBeganInterruptAudioSession(_ view: PlayerView) {
        
    }

    func playerViewUpdatePlayingState(_ view: PlayerView, isPlaying: Bool) {
    }
}

// MARK: - UIScrollViewDelegate
extension EditorViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let duration = self.playView.duration(), !self.playView.isPlaying() {
            print(scrollView.contentOffset)
            let progress = Double(scrollView.contentOffset.x)/Double(scrollView.contentSize.width - scrollView.frame.width)
            let currentTime = CMTimeGetSeconds(duration) * progress
            self.playView.seekTo(currentTime)
        }
    }
}

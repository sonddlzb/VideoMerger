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
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var timeScrollView: UIScrollView!
    @IBOutlet weak var frameStackView: UIStackView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var imgMute: UIImageView!
    @IBOutlet weak var editMainTabBarView: EditMainTabBarView!

    // MARK: - Variables
    weak var listener: EditorPresentableListener?
    var viewModel = EditorViewModel.makeEmpty()
    private var timeObserverToken: Any?
    var isPlayingBefore = false
    var isPlayingAtTheEnd = false
    var isSoundMuted = false {
        didSet {
            self.playView.isMuted = isSoundMuted
            self.imgMute.image = UIImage(named: isSoundMuted ? "ic_mute_disable" : "ic_mute_enable")
        }
    }

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
        editMainTabBarView.delegate = self
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
                    self.timeStackView.arrangedSubviews.forEach {$0.removeFromSuperview()}

                    let leftPaddingView = UIView()
                    leftPaddingView.translatesAutoresizingMaskIntoConstraints = false
                    self.frameStackView.addArrangedSubview(leftPaddingView)
                    leftPaddingView.widthAnchor.constraint(equalTo: self.frameScrollView.widthAnchor, multiplier: 0.5).isActive = true

                    let leftTimePaddingView = UIView()
                    leftTimePaddingView.translatesAutoresizingMaskIntoConstraints = false
                    self.timeStackView.addArrangedSubview(leftTimePaddingView)
                    leftTimePaddingView.widthAnchor.constraint(equalTo: self.frameScrollView.widthAnchor, multiplier: 0.5).isActive = true

                    asset.extractFrames(fps: 1) { image, error, second, isFinish, scale in
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
                                imageView.widthAnchor.constraint(equalToConstant: self.frameScrollView.frame.height*scale).isActive = true

                                let timeLabel = UILabel()
                                timeLabel.textAlignment = .left
                                timeLabel.textColor = UIColor(rgb: 0x9E9E9E)
                                timeLabel.font = .systemFont(ofSize: 10, weight: .regular)
                                timeLabel.text = String(second).formatVideoDuration()
                                timeLabel.translatesAutoresizingMaskIntoConstraints = false
                                self.timeStackView.addArrangedSubview(timeLabel)
                                timeLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true

                                if isFinish {
                                    let rightPaddingView = UIView()
                                    rightPaddingView.translatesAutoresizingMaskIntoConstraints = false
                                    self.frameStackView.addArrangedSubview(rightPaddingView)
                                    rightPaddingView.widthAnchor.constraint(equalTo: self.frameScrollView.widthAnchor, multiplier: 0.5).isActive = true

                                    let rightTimePaddingView = UIView()
                                    rightTimePaddingView.translatesAutoresizingMaskIntoConstraints = false
                                    self.timeStackView.addArrangedSubview(rightTimePaddingView)
                                    rightTimePaddingView.widthAnchor.constraint(equalTo: self.timeStackView.widthAnchor, multiplier: 0.5).isActive = true
                                }
                            }
                        }
                    }
                }
            }
        })

        addPeriodicTimeObserverForVideo()
        self.playView.setLayerVideoGravity(.resizeAspect)
        self.playView.loopEnable = false
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
    @IBAction func didTapMuteButton(_ sender: Any) {
        self.isSoundMuted = !self.isSoundMuted
    }
}

// MARK: - PlayBarViewDelegate
extension EditorViewController: PlayBarViewDelegate {
    func playBarViewDidTapPlay(_ playBarView: PlayBarView, isPlaying: Bool) {
        if !self.isPlayingAtTheEnd {
            if self.playView.isPlaying() {
                self.playView.pause()
            } else {
                self.playView.play()
            }
        } else {
            self.playView.seekTo(0)
            self.playView.play()
        }
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
            self.timeScrollView.contentOffset.x = self.frameScrollView.contentOffset.x
        }
    }
}

// MARK: PlayerViewDelegate
extension EditorViewController: PlayerViewDelegate {
    func playerViewBeganInterruptAudioSession(_ view: PlayerView) {
        
    }

    func playerViewUpdatePlayingState(_ view: PlayerView, isPlaying: Bool) {
        if isPlaying {
            self.isPlayingAtTheEnd = false
        }
    }

    func playerViewDidPlayToEnd(_ view: PlayerView) {
        self.playBarView.isPlaying = false
        self.isPlayingAtTheEnd = true
    }
}

// MARK: - UIScrollViewDelegate
extension EditorViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let duration = self.playView.duration(), !self.playView.isPlaying() {
            print(scrollView.contentOffset)
            let offset = scrollView.contentOffset.x
            let contentWidth = Double(scrollView.contentSize.width - scrollView.frame.width)
            let progress = offset/contentWidth
            let currentTime = CMTimeGetSeconds(duration) * progress
            self.playView.seekTo(currentTime)
            self.timeScrollView.contentOffset.x = scrollView.contentOffset.x
            self.isPlayingAtTheEnd = offset >= contentWidth
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.playView.isPlaying() {
            self.playView.pause()
            self.playBarView.isPlaying = false
            self.isPlayingBefore = true
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if isPlayingBefore {
            isPlayingBefore = false
            self.playView.play()
            self.playBarView.isPlaying = true
        }
    }
}

// MARK: EditMainTabBarDelegate
extension EditorViewController: EditMainTabBarDelegate {
    func onTapEdit() {
        print("---onTapEdit")
    }

    func onTapMusic() {
        print("---onTapMusic")
    }

    func onTapText() {
        print("---onTapText")
    }

    func onTapSticker() {
        print("---onTapSticker")
    }

    func onTapExport() {
        print("---onTapExport")
    }
}

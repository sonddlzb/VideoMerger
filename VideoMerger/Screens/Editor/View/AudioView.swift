//
//  AudioView.swift
//  VideoMerger
//
//  Created by đào sơn on 27/02/2024.
//

import UIKit
import AVFoundation
import DSWaveformImage

class AudioView: UIView {
    // MARK: - Outlets
    private var containerView: UIView!
    private var gradientView: UIView!
    private var waveView: UIView!

    // MARK: - Variables
    var audioURL: URL? {
        didSet {
            if let audioURL = audioURL, let audioWidth = audioWidth {
                generateWaveform(from: audioURL, audioWidth: audioWidth)
            }
        }
    }

    var audioWidth: Double? {
        didSet {
            if let audioWidth = audioWidth, let audioURL = audioURL {
                generateWaveform(from: audioURL, audioWidth: audioWidth)
            }
        }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        config()
        addContentViews()
        addLayoutConstraints()
        addGradientLayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.addGradientLayer()
    }

    // MARK: - Config
    private func config() {
        self.containerView = UIView()
        self.containerView.translatesAutoresizingMaskIntoConstraints = false

        self.gradientView = UIView()
        self.gradientView.translatesAutoresizingMaskIntoConstraints = false

        self.waveView = UIView()
        self.waveView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func addGradientLayer() {
        self.layoutIfNeeded()
        self.gradientView.layer.sublayers?.forEach {$0.removeFromSuperlayer()}
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(rgb: 0xEE9AE5).cgColor, UIColor(rgb: 0x5961F9).cgColor]
        gradientLayer.frame = self.gradientView.bounds
        self.gradientView.layer.addSublayer(gradientLayer)
    }

    // MARK: - Add content views
    private func addContentViews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.gradientView)
        self.containerView.addSubview(self.waveView)
    }

    // MARK: - Add layout constraints
    private func addLayoutConstraints() {
        self.containerView.fitSuperviewConstraint()
        self.gradientView.fitSuperviewConstraint()
        self.waveView.fitSuperviewConstraint()
    }

    private func generateWaveform(from audioURL: URL, audioWidth: Double) {
        self.waveView.subviews.forEach { $0.removeFromSuperview()}
        self.layoutIfNeeded()
        let waveformView = WaveformImageView(frame: CGRect(x: self.waveView.frame.minX, y: self.waveView.frame.minY, width: self.waveView.frame.width*2, height: self.waveView.frame.height))
        waveformView.waveformStyle = .striped
        waveformView.waveformColor = .white
        waveformView.waveformAudioURL = audioURL
        self.waveView.addSubview(waveformView)
    }
}

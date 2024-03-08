//
//  BorderProgressView.swift
//  VideoMerger
//
//  Created by Hưng Hà Quang on 05/03/2024.
//

import Foundation

import UIKit

class BorderProgressView: UIView {
    private var progressLayer = CAShapeLayer()
    private lazy var progressLabel: UILabel = {
        let progressLabel = UILabel()
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.systemFont(ofSize: 40.0, weight: .bold)
        return progressLabel
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.width > 0.0 && bounds.height > 0.0 {
            setupProgressLayer()
            setupView()
        }
    }

    private func setupView() {
        self.subviews.forEach {
            if $0 is UILabel {
                $0.removeFromSuperview()
            }
        }

        self.addSubview(progressLabel)
        progressLabel.fixInView(self)
    }

    private func setupProgressLayer() {
        let path = UIBezierPath(rect: bounds)
        progressLayer.sublayers?.forEach({ sublayer in
            sublayer.removeFromSuperlayer()
        })
        progressLayer.removeFromSuperlayer()
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = UIColor.blue.withAlphaComponent(0.6).cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 5.0
        progressLayer.strokeEnd = 0.0
        progressLayer.lineCap = .round
        let secondLayer = CAShapeLayer()
        secondLayer.path = UIBezierPath(rect: CGRect(x: 5, y: 5, width: bounds.width - 10, height: bounds.height - 10)).cgPath
        secondLayer.fillColor = UIColor.black.withAlphaComponent(0.2).cgColor
        progressLayer.addSublayer(secondLayer)
        layer.addSublayer(progressLayer)
    }

    func setProgress(_ progress: CGFloat, animated: Bool) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = progress

        if animated {
            progressLayer.add(animation, forKey: "progressAnimation")
        }

        progressLabel.text = "\(Int(progress * 100))%"
        progressLayer.strokeEnd = progress
        self.layoutIfNeeded()
    }
}

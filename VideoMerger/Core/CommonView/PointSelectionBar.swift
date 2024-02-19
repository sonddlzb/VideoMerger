//
//  PointSelectionBar.swift
//  VideoMerger
//
//  Created by đào sơn on 23/01/2024.
//

import UIKit

private struct Const {
    static let iconSize = 14.0
    static let lineWidth = 6.0
}

class PointSelectionBar: UIView {

    // MARK: - Outlets
    private var containerView: UIView!
    private var lineView: UIView!
    private var containerPointView: UIView!
    private var containerLabels: UIView!
    private var listPointViews: [UIView] = []
    private var listLabels: [UILabel] = []

    // MARK: - Variables
    public var pointsData: [String] = [] {
        didSet {
            self.addPointsView()
        }
    }

    public var selectedIndex = 2 {
        didSet {
            self.updateSelectedState()
        }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    private func commonInit() {
        self.createContentViews()
        self.config()
        self.addContentViews()
        self.layoutConstraints()
        self.addPointsView()
        self.updateSelectedState()
    }

    private func createContentViews() {
        self.containerView = UIView()
        self.containerView.translatesAutoresizingMaskIntoConstraints = false

        self.lineView = UIView()
        self.lineView.translatesAutoresizingMaskIntoConstraints = false

        self.containerPointView = UIView()
        self.containerPointView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func config() {
        self.lineView.backgroundColor = UIColor(rgb: 0xE0E0E0)
        self.containerPointView.backgroundColor = .clear
    }

    private func addContentViews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.lineView)
        self.containerView.addSubview(self.containerPointView)
    }

    private func layoutConstraints() {
        self.containerView.fitSuperviewConstraint()
        NSLayoutConstraint.activate([
            self.lineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 4.0),
            self.lineView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: (Const.iconSize - Const.lineWidth)/2),
            self.lineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -4.0),
            self.lineView.heightAnchor.constraint(equalToConstant: Const.lineWidth),

            self.containerPointView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.containerPointView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.containerPointView.heightAnchor.constraint(equalToConstant: Const.iconSize),
            self.containerPointView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
        ])
    }

    private func addPointsView() {
        guard self.pointsData.count > 1 else {
            return
        }

        self.containerPointView.subviews.forEach {
            $0.removeFromSuperview()
        }

        self.layoutIfNeeded()
        let numberOfPoints = self.pointsData.count
        let spacing = (self.containerPointView.frame.width - Double(numberOfPoints)*Const.iconSize)/Double(numberOfPoints-1)
        (0..<numberOfPoints).forEach { index in
            let pointView = UIView()
            pointView.translatesAutoresizingMaskIntoConstraints = false
            pointView.layer.cornerRadius = Const.iconSize/2
            pointView.backgroundColor = UIColor(rgb: 0xE0E0E0)

            let pointLabel = UILabel()
            pointLabel.translatesAutoresizingMaskIntoConstraints = false
            pointLabel.textColor = UIColor(rgb: 0x9E9E9E)
            pointLabel.textAlignment = .center
            pointLabel.font = UIFont.systemFont(ofSize: 10.0)
            pointLabel.text = pointsData[index]

            let pointButton = UIButton()
            pointButton.tag = index
            pointButton.translatesAutoresizingMaskIntoConstraints = false
            pointButton.addTarget(self, action: #selector(didSelectedState(_:)), for: .touchUpInside)

            self.containerPointView.addSubview(pointView)
            self.containerView.addSubview(pointLabel)
            self.containerView.addSubview(pointButton)

            NSLayoutConstraint.activate([
                pointView.centerYAnchor.constraint(equalTo: self.containerPointView.centerYAnchor),
                pointView.heightAnchor.constraint(equalToConstant: Const.iconSize),
                pointView.heightAnchor.constraint(equalTo: pointView.widthAnchor, multiplier: 1),
                pointView.leadingAnchor.constraint(equalTo: self.containerPointView.leadingAnchor, constant: Double(index)*(spacing+Const.iconSize)),

                pointLabel.centerXAnchor.constraint(equalTo: pointView.centerXAnchor),
                pointLabel.topAnchor.constraint(equalTo: pointView.bottomAnchor, constant: 12.0),

                pointButton.leadingAnchor.constraint(equalTo: pointView.leadingAnchor, constant: -4.0),
                pointButton.trailingAnchor.constraint(equalTo: pointView.trailingAnchor, constant: 4.0),
                pointButton.topAnchor.constraint(equalTo: pointView.topAnchor, constant: -4.0),
                pointButton.bottomAnchor.constraint(equalTo: pointView.bottomAnchor, constant: 4.0)
            ])
        }
    }

    private func updateSelectedState() {
        for (index, subview) in self.containerPointView.subviews.enumerated() {
            subview.backgroundColor = index == selectedIndex ? UIColor(rgb: 0x536DFE) : UIColor(rgb: 0xE0E0E0)
        }
    }

    // MARK: - Action
    @objc func didSelectedState(_ sender: UIButton) {
        guard sender.tag != self.selectedIndex else {
            return
        }

        self.selectedIndex = sender.tag
    }
}

//
//  ExpandableFrameView.swift
//  VideoMerger
//
//  Created by Hưng Hà Quang on 17/01/2024.
//

import UIKit

class ExpandableFrameViewConstant {
    static let edgeWidth = 40.0
}

protocol ExpandableFrameDelegate: AnyObject {
    func scroll(_ expandableFramView: ExpandableFrameView, translation: CGPoint, isContinueScroll: Bool, velocity: CGPoint)
    func toggleSize(_ expandableFramView: ExpandableFrameView, positionX: Double)
}

class ExpandableFrameView: UIView {
    // MARK: variable
    var contentView: ExpandableContentView!
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var isScroll = true
    private var leading = 0.0
    private var trailing = 0.0
    weak var delegate: ExpandableFrameDelegate?

    // MARK: function
    func initView() {
        contentView = ExpandableContentView()
        self.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubView()
        addConstraintLayout()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        contentView.addGestureRecognizer(panGesture)
    }

    func addSubView() {
        if let contentView = contentView {
            self.addSubview(contentView)
        }
    }

    func addConstraintLayout() {
        leadingConstraint = self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0)
        trailingConstraint = self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        NSLayoutConstraint.activate(
            [
                leadingConstraint,
                self.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
                self.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
                trailingConstraint
            ]
        )
    }

    func setLeadingConstrant(leading: Double) {
        leadingConstraint.constant = leading
        self.leading = leading
        self.layoutIfNeeded()
    }

    func setTrailingConstrant(trailing: Double) {
        trailingConstraint.constant = trailing
        self.trailing = trailing
        self.layoutIfNeeded()
    }

    // MARK: lifecycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    // MARK: action
    // MARK: - Pan Gesture Handler
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let location = gesture.location(in: contentView)
        let edgeWidth = ExpandableFrameViewConstant.edgeWidth
        let contentViewWidth = contentView.frame.width
        let isRightEdge = location.x > -edgeWidth && location.x <= edgeWidth
        let isLeftEdge = location.x > contentViewWidth - edgeWidth && location.x < contentViewWidth + edgeWidth
        let velocity = gesture.velocity(in: self)

        switch gesture.state {
        case .began, .changed:
            if isRightEdge {
                let leading = leadingConstraint.constant - translation.x
                if leading <= self.leading {
                    leadingConstraint.constant = leading
                    delegate?.toggleSize(self, positionX: -leading + self.leading)
                }
            } else if isLeftEdge {
                let trailing = trailingConstraint.constant - translation.x
                if trailing >= self.trailing {
                    trailingConstraint.constant = trailing
                    delegate?.toggleSize(self, positionX: self.frame.width - self.trailing - trailing)
                }
            } else if self.contentView.frame.width <= self.frame.width - trailing + leading {
                delegate?.scroll(self, translation: translation, isContinueScroll: false, velocity: velocity)
            }

            gesture.setTranslation(.zero, in: self)
            self.layoutIfNeeded()
        case .ended, .cancelled:
            if self.contentView.frame.width <= self.frame.width - trailing + leading {
                delegate?.scroll(self, translation: translation, isContinueScroll: true, velocity: velocity)
            } else {
                delegate?.scroll(self, translation: translation, isContinueScroll: false, velocity: velocity)
            }

        default:
            break
        }
    }
}

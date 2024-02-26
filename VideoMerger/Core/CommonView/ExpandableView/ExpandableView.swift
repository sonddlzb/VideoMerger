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

enum ExpandableEdges {
    case left
    case right
}

protocol ExpandableFrameDelegate: AnyObject {
    func expandableDidScroll(_ expandableView: ExpandableView, translation: CGPoint, isContinueScroll: Bool, velocity: CGPoint)
    func expandableViewDidChangeWidth(_ expandableView: ExpandableView, positionX: Double, edge: ExpandableEdges)
}

class ExpandableView: UIView {
    // MARK: variable
    var contentView: ExpandableContentView!
    var leadingConstraint: NSLayoutConstraint! {
        didSet {
            self.layoutIfNeeded()
        }
    }

    var trailingConstraint: NSLayoutConstraint! {
        didSet {
            self.layoutIfNeeded()
        }
    }

    private var isScroll = true
    private var limitLeading = 0.0 {
        didSet {
            leadingConstraint.constant = limitLeading
        }
    }

    private var limitTrailing = 0.0 {
        didSet {
            trailingConstraint.constant = limitTrailing
        }
    }

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

    func setLimitLeadingConstrant(leading: Double) {
        self.limitLeading = leading
    }

    func setLimitTrailingConstrant(trailing: Double) {
        self.limitTrailing = trailing
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
                if leading <= self.limitLeading {
                    leadingConstraint.constant = leading
                    delegate?.expandableViewDidChangeWidth(self, positionX: -leading + self.limitLeading, edge: .left)
                }
            } else if isLeftEdge {
                let trailing = trailingConstraint.constant - translation.x
                if trailing >= self.limitTrailing {
                    trailingConstraint.constant = trailing
                    delegate?.expandableViewDidChangeWidth(self, positionX: self.frame.width - self.limitTrailing - trailing, edge: .right)
                }
            } else if self.contentView.frame.width <= self.frame.width - limitTrailing + limitLeading {
                delegate?.expandableDidScroll(self, translation: translation, isContinueScroll: false, velocity: velocity)
            }

            gesture.setTranslation(.zero, in: self)
            self.layoutIfNeeded()
        case .ended, .cancelled:
            if self.contentView.frame.width <= self.frame.width - limitTrailing + limitLeading {
                delegate?.expandableDidScroll(self, translation: translation, isContinueScroll: true, velocity: velocity)
            } else {
                delegate?.expandableDidScroll(self, translation: translation, isContinueScroll: false, velocity: velocity)
            }

        default:
            break
        }
    }
}

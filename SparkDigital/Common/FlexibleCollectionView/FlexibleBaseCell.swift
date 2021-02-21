//
//  FlexibleBaseCell.swift
//  Example
//
//  Created by Carlos Duclos on 10/17/18.
//  Copyright © 2018 Carlos Duclos. All rights reserved.
//

import Foundation
import UIKit

open class FlexibleBaseCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    open override var isSelected: Bool {
        didSet { updateSelection() }
    }
    open override var isHighlighted: Bool {
        didSet { updateSelection() }
    }
    
    public var corners: UIRectCorner = .none {
        didSet { refreshCorners() }
    }
    
    public var cornerRadius: CGFloat = 0 {
        didSet { refreshCorners() }
    }
    
    public var lineWidth: CGFloat = 0 {
        didSet {
            borderLayer.lineWidth = lineWidth
        }
    }
    
    public var lineColor: UIColor = .black {
        didSet {
            borderLayer.strokeColor = lineColor.cgColor
        }
    }
    
    public var shadowColor: UIColor = .clear
    public var shadowRadius: CGFloat = 0
    public var shadowOffset: CGSize = .zero
    
    public var color: UIColor = .clear {
        didSet {
            backgroundLayer.fillColor = color.cgColor
        }
    }
    
    public var selectedBackgroundColor: UIColor = .clear
    
    private var backgroundLayer: CAShapeLayer!
    private var borderLayer: CAShapeLayer!
    private var maskLayer: CAShapeLayer!
    private var bottomSeparatorLayer: CAShapeLayer!
    
    // MARK: Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayers()
        initializeView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLayers()
        initializeView()
    }
    
    // MARK: View configuration
    
    open func initializeView() {
        contentView.backgroundColor = .clear
    }
    
    internal func initializeLayers() {
        if backgroundLayer == nil {
            
            // Set background
            backgroundLayer = CAShapeLayer()
            backgroundLayer.fillColor = color.cgColor
            contentView.layer.insertSublayer(backgroundLayer, at: 0)
            
            // Set border
            borderLayer = CAShapeLayer()
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.lineWidth = lineWidth
            borderLayer.strokeColor = lineColor.cgColor
            contentView.layer.insertSublayer(borderLayer, at: 1)
            
            // Set separator
            bottomSeparatorLayer = CAShapeLayer()
            bottomSeparatorLayer.fillColor = UIColor.clear.cgColor
            bottomSeparatorLayer.lineWidth = 0.5
            bottomSeparatorLayer.strokeColor = UIColor.black.cgColor
            contentView.layer.insertSublayer(bottomSeparatorLayer, at: 2)
            
            // Set shadows
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowOffset = shadowOffset
            self.layer.shadowOpacity = 0
            
            // Set mask
            maskLayer = CAShapeLayer()
            self.layer.mask = maskLayer
        }
    }
    
    private func updateSelection(animated: Bool = false) {
        let isSelected = (self.isSelected || self.isHighlighted)
        
        if !animated {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        }
        
        if isSelected {
            backgroundLayer.fillColor = selectedBackgroundColor.cgColor
        } else {
            backgroundLayer.fillColor = color.cgColor
        }
        
        if !animated {
            CATransaction.commit()
        }
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let canvasLayoutAttributes = layoutAttributes as? FlexibleCollectionViewLayoutAttributes else { return }
        
        let backgroundPath = UIBezierPath(roundedRect: bounds,
                                          byRoundingCorners: corners,
                                          cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        backgroundLayer.path = backgroundPath.cgPath
        
        let borderBounds = CGRect(x: lineWidth / 2,
                                  y: lineWidth / 2,
                                  width: bounds.width - lineWidth,
                                  height: bounds.height - lineWidth)
        let borderPath = UIBezierPath(roundedRect: borderBounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        borderLayer.path = borderPath.cgPath
        
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: .all,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        maskLayer.path = maskPath.cgPath
        
        let bottomSeparatorPath = UIBezierPath()
        bottomSeparatorPath.move(to: CGPoint(x: bounds.minX, y: bounds.maxY-lineWidth/2))
        bottomSeparatorPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY-lineWidth/2))
        bottomSeparatorPath.close()
        bottomSeparatorLayer.path = bottomSeparatorPath.cgPath
        bottomSeparatorLayer.isHidden = !canvasLayoutAttributes.showsBottomSeparator
    }
    
    private func refreshCorners() {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: .all,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        maskLayer.path = maskPath.cgPath
    }
}

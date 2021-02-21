//
//  FlexibleCollectionViewLayoutAttributes.swift
//  FlexibleCollectionView-iOS
//
//  Created by Carlos Duclos on 10/13/18.
//  Copyright © 2018 FlexibleCollectionView. All rights reserved.
//

import UIKit

final public class FlexibleCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    // MARK: - Properties
    
    var corners: UIRectCorner = .none
    var showsBottomSeparator: Bool = false
    var showsShadow: Bool = false
    
    // MARK: - Override
    
    override public func copy(with zone: NSZone?) -> Any {
        guard let copiedAttributes = super.copy(with: zone) as? FlexibleCollectionViewLayoutAttributes else {
            return super.copy(with: zone)
        }
        
        copiedAttributes.corners = corners
        copiedAttributes.showsBottomSeparator = showsBottomSeparator
        copiedAttributes.showsShadow = showsShadow
        return copiedAttributes
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let otherAttributes = object as? FlexibleCollectionViewLayoutAttributes else {
            return false
        }
        
        if otherAttributes.showsBottomSeparator != showsBottomSeparator ||
            otherAttributes.corners != corners ||
            otherAttributes.showsShadow != showsShadow {
            return false
        }
        
        return super.isEqual(object)
    }
    
}

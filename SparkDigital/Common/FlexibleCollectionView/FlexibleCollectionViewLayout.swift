//
//  FlexibleCollectionViewLayout.swift
//  FlexibleCollectionView-iOS
//
//  Created by Carlos Duclos on 10/13/18.
//  Copyright © 2018 FlexibleCollectionView. All rights reserved.
//

import Foundation
import UIKit

public protocol FlexibleCollectionViewLayoutDelegate: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemWithWidth width: CGFloat,
                        atIndexPath indexPath: IndexPath) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView, insetsForSection section: Int) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForHeaderWithWidth width: CGFloat,
                        forSection section: Int) -> CGFloat
}

public extension FlexibleCollectionViewLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemWithWidth width: CGFloat,
                        atIndexPath indexPath: IndexPath) -> CGFloat {
        return .automatic
    }
    
    func collectionView(_ collectionView: UICollectionView, insetsForSection section: Int) -> CGFloat {
        return .automatic
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForHeaderWithWidth width: CGFloat,
                        forSection section: Int) -> CGFloat {
        return .automatic
    }
}

final public class FlexibleCollectionViewLayout: UICollectionViewLayout {
    
    private var cache = [Element: [IndexPath: FlexibleCollectionViewLayoutAttributes]]()
    private var visibleLayoutAttributes = [FlexibleCollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    
    public weak var delegate: FlexibleCollectionViewLayoutDelegate! {
        get {
            return self.collectionView!.delegate as? FlexibleCollectionViewLayoutDelegate
        }
    }
    
    public var settings = Settings()
    
    public init(style: Style) {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func invalidateLayout() {
        cache.removeAll(keepingCapacity: true)
        super.invalidateLayout()
    }
    
    override public class var layoutAttributesClass: AnyClass {
        return FlexibleCollectionViewLayoutAttributes.self
    }
    
    public override var collectionViewContentSize: CGSize {
        let width = collectionView?.frame.width ?? 0
        return CGSize(width: width, height: contentHeight)
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return newBounds.size != collectionView.bounds.size
    }
    
    public override func prepare() {
        guard let collectionView = collectionView, cache.isEmpty else { return }
        
        prepareCache()
        contentHeight = settings.insets.top
        
        let sectionsCount = collectionView.numberOfSections
        for section in 0..<sectionsCount {
            
            if settings.showSectionHeaders {
                let calculatedHeaderSize = sectionHeaderSize(section: section)
                let sectionHeaderIndexPath = IndexPath(item: 0, section: section)
                let sectionHeaderAttributes = FlexibleCollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: Element.sectionHeader.kind,
                    with: sectionHeaderIndexPath
                )
                
                sectionHeaderAttributes.frame = CGRect(x: settings.insets.left,
                                                       y: contentHeight,
                                                       width: calculatedHeaderSize.width,
                                                       height: calculatedHeaderSize.height)
                
                if calculatedHeaderSize.height != 0 {
                    contentHeight += sectionHeaderAttributes.frame.height + settings.itemSpacing
                }
                
                cache[.sectionHeader]?[sectionHeaderIndexPath] = sectionHeaderAttributes
            }
            
            var offsets = [CGFloat](repeating: 0, count: settings.numberOfColumns)
            let itemsCount = collectionView.numberOfItems(inSection: section)
            for item in 0..<itemsCount {
                
                var indexMinValue = 0
                var minOffset: CGFloat = .greatestFiniteMagnitude
                for (index, offset) in offsets.enumerated() {
                    if minOffset > offset  {
                        indexMinValue = index
                        minOffset = offset
                    }
                }
                
                let indexPath = IndexPath(item: item, section: section)
                let itemAttributesT = FlexibleCollectionViewLayoutAttributes(forCellWith: indexPath)
                itemAttributesT.showsShadow = true
                
                let calculatedSize = itemSize(indexPath: indexPath, tentativeAttributes: itemAttributesT)
                let attributes = FlexibleCollectionViewLayoutAttributes(forCellWith: indexPath)
                let currentRow = Int(Double(item) / Double(settings.numberOfColumns))
//                let currentColumn = Int(item % settings.numberOfColumns)
                let spacing = (currentRow == 0) ? 0 : settings.itemSpacing
                let x = settings.insets.left + (calculatedSize.width * CGFloat(indexMinValue)) + (settings.itemSpacing * CGFloat(indexMinValue))
                let y = max(offsets[indexMinValue], contentHeight) + spacing
                attributes.frame = CGRect(x: x, y: y,
                                          width: calculatedSize.width, height: calculatedSize.height)
                
                cache[.cell]?[indexPath] = attributes
                offsets[indexMinValue] = attributes.frame.maxY
            }
            
            contentHeight = (offsets.max() ?? 0) + settings.insets.bottom
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        visibleLayoutAttributes.removeAll(keepingCapacity: true)
        
        for (_, info) in cache {
            for (_, attributes) in info {
                if attributes.frame.intersects(rect) {
                    visibleLayoutAttributes.append(attributes)
                }
            }
        }
        return visibleLayoutAttributes
    }
    
    private func itemSize(indexPath: IndexPath, tentativeAttributes: UICollectionViewLayoutAttributes) -> CGSize {
        guard let collectionView = collectionView else { return CGSize.zero }
        let calculatedInsets = sectionInsets(section: indexPath.section)
        let space = CGFloat(settings.numberOfColumns - 1) * settings.itemSpacing
        let width = (collectionView.frame.width - (calculatedInsets * 2) - space) / CGFloat(settings.numberOfColumns)
        let height: CGFloat
        let cellHeight = delegate.collectionView(collectionView, heightForItemWithWidth: width, atIndexPath: indexPath)
        
        if cellHeight == .automatic {
            let fittingSize = CGSize(width: width, height: 10)
            let cell = delegate.collectionView(collectionView, cellForItemAt: indexPath)
//            cell.apply(tentativeAttributes)
            
            let size = cell.contentView.systemLayoutSizeFitting(fittingSize,
                                                                withHorizontalFittingPriority: .init(912),
                                                                verticalFittingPriority: .fittingSizeLevel)
            cell.removeFromSuperview()
            height = size.height
        } else {
            height = cellHeight
        }
        
        return CGSize(width: width, height: ceil(height))
    }
    
    private func sectionHeaderSize(section: Int) -> CGSize {
        guard let collectionView = collectionView else { return CGSize.zero }
        let calculatedInsets = sectionInsets(section: section)
        let width = collectionView.frame.width-calculatedInsets*2
        let height: CGFloat
        let delegatedHeight = delegate.collectionView(collectionView, heightForHeaderWithWidth: width, forSection: section)
        if delegatedHeight == .automatic {
            let kind = UICollectionView.elementKindSectionHeader
            let indexPath = IndexPath(item: 0, section: section)
            if let view = delegate.collectionView?(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) {
                let fittingSize = CGSize(width: width, height: 10)
                //                view.apply(tentativeAttributes)
                let size = view.systemLayoutSizeFitting(fittingSize,
                                                        withHorizontalFittingPriority: .init(912),
                                                        verticalFittingPriority: .fittingSizeLevel)
                view.removeFromSuperview()
                height = size.height
                
            } else {
                height = 0
            }
            
        } else {
            height = delegatedHeight
        }
        return CGSize(width: width, height: ceil(height))
    }
    
    private func prepareCache() {
        contentHeight = 0
        cache.removeAll(keepingCapacity: true)
        cache[.header] = [IndexPath: FlexibleCollectionViewLayoutAttributes]()
        cache[.sectionHeader] = [IndexPath: FlexibleCollectionViewLayoutAttributes]()
        cache[.sectionFooter] = [IndexPath: FlexibleCollectionViewLayoutAttributes]()
        cache[.cell] = [IndexPath: FlexibleCollectionViewLayoutAttributes]()
    }
}

extension FlexibleCollectionViewLayout {
    
    public enum Style {
        case normal
        case collage
    }
    
    public struct Settings {
        public var itemSpacing: CGFloat = 0
        public var insets: UIEdgeInsets = .zero
        public var showSectionHeaders: Bool = false
        public var cellCornerRadius: CGFloat = 0
        public var numberOfColumns: Int = 1
    }
    
    enum Element: String {
        case header
        case menu
        case cell
        case sectionHeader
        case sectionFooter
        
        var kind: String {
            switch self {
            case .sectionHeader:
                return UICollectionView.elementKindSectionHeader
            case .sectionFooter:
                return UICollectionView.elementKindSectionFooter
            default:
                return "Kind\(self.rawValue.capitalized)"
            }
        }
    }
}

extension FlexibleCollectionViewLayout {
    
    func sectionInsets(section: Int) -> CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let sectionInsets: CGFloat
        let delegatedSectionInsets = delegate.collectionView(collectionView, insetsForSection: section)
        if delegatedSectionInsets == .automatic {
            sectionInsets = settings.insets.left
        } else {
            sectionInsets = delegatedSectionInsets
        }
        return sectionInsets
    }
}

public extension CGFloat {

    static let automatic: CGFloat = .greatestFiniteMagnitude
}

public enum CellHeight {
    case automatic
    case custom(CGFloat)
    
    var height: CGFloat {
        switch self {
        case .automatic: return 0
        case .custom(let height): return height
        }
    }
}

//
//  ItemViewModel.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 24/02/21.
//

import Foundation
import UIKit

protocol ItemViewModel {
    
    var reuseIdentifier: String { get }
    
    func setup(_ cell: UICollectionReusableView, in collectionView: UICollectionView, at indexPath: IndexPath)
}

//
//  ItemViewModel.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 24/02/21.
//

import Foundation
import UIKit

/// Protocol to be implemented in child cells
protocol ItemViewModel {
    
    /// Defines the identifier to be used for a cell
    var reuseIdentifier: String { get }
    
    /// Method to initialize the cell
    /// - Parameters
    ///     - cell: instance of the cell
    func setup(_ cell: UICollectionReusableView)
}

//
//  PhotoItemViewModel.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 24/02/21.
//

import Foundation
import UIKit
import Rswift

/// Represents each item on the collection view
struct PhotoItemViewModel: ItemViewModel {
    
    // MARK: - Properties
    
    var photo: PhotoVM
    var reuseIdentifier: String {
        return R.reuseIdentifier.photoCell.identifier
    }
    
    // MARK: - Functions
    
    init(photo: PhotoVM) {
        self.photo = photo
    }
    
    /// Sets up a cell to change the image according to the state of each one
    ///     - Idle: no image is presented
    ///     - loading: no image is presented
    ///     - success: animates the image transition
    ///     - error: no image is presented
    func setup(_ cell: UICollectionReusableView) {
        guard let cell = cell as? PhotoCell else { return }
        
        switch photo.thumbnailState {
        case .idle:
            cell.imageView.image = nil
            
        case .loading:
            break
            
        case .success(let data):
            UIView.transition(
                with: cell.imageView,
                duration: 0.15,
                options: .transitionCrossDissolve,
                animations: {
                    cell.imageView.image = UIImage(data: data)
                }, completion: nil)
            
        case .error:
            cell.imageView.image = nil
        }
    }
}

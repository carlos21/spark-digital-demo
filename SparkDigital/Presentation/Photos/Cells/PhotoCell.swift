//
//  PhotoCell.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit

/// Represents a cell for a photo in the list
class PhotoCell: FlexibleBaseCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Functions
    
    override func awakeFromNib() {
        cornerRadius = 5.0
        corners = .all
        imageView.contentMode = .scaleAspectFit
    }
}

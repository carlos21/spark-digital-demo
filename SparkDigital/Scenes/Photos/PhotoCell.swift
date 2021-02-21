//
//  PhotoCell.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit
import PresentationLogic

class PhotoCell: FlexibleBaseCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
//        imageView.image = nil
    }
    
    override func awakeFromNib() {
        cornerRadius = 5.0
        corners = .all
        imageView.contentMode = .scaleAspectFit
    }
    
    func setup(photo: PhotosViewModel.PhotoVM) {
        switch photo.thumbnailState {
        case .idle:
            imageView.image = nil
            
        case .loading:
            break
            
        case .success(let data):
            imageView.image = UIImage(data: data)
            
        case .error:
            imageView.image = nil // TO DO
        }
    }
}

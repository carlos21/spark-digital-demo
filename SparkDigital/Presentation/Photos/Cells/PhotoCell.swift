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
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Functions
    
    override func awakeFromNib() {
        cornerRadius = 5.0
        corners = .all
        imageView.contentMode = .scaleAspectFit
    }
    
    func setup(photo: PhotoVM) {
        switch photo.thumbnailState {
        case .idle:
            imageView.image = nil
            
        case .loading:
            break
            
        case .success(let data):
            animate(photo: data)
            
        case .error:
            imageView.image = nil
        }
    }
    
    private func animate(photo: Data) {
        UIView.transition(
            with: imageView,
            duration: 0.15,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.imageView.image = UIImage(data: photo)
            }, completion: nil)
    }
}

//
//  PhotoDetailViewModel.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation
import Core

/// Contains the logic to show the bigger image on a separate screen
public class PhotoDetailViewModel {
    
    // MARK: - Properties
    
    private var photosRepository: PhotosRepositoryProtocol
    public var photoUpdated = DelegatedCall<PhotoVM>()
    public var photo: PhotoVM?
    
    // MARK: - Init
    
    public init(photosRepository: PhotosRepositoryProtocol) {
        self.photosRepository = photosRepository
    }
    
    /// Downloads the bigger version of the photo
    /// Validates if the photo was already downloaded or not
    public func download() {
        if let photo = self.photo, case PhotoState.success = photo.bigImageState {
            photoUpdated.callback?(photo)
            return
        }
        
        guard let photo = self.photo, photo.bigImageState.shouldDownload else {
            return
        }
        
        photo.bigImageState = .loading
        photoUpdated.callback?(photo)
        photosRepository.downloadPhoto(path: photo.url) { [weak self] result in
            switch result {
            case .success(let data):
                photo.bigImageState = .success(data)
                
            case .failure:
                photo.bigImageState = .error
            }
            
            guard let self = self else { return }
            self.photoUpdated.callback?(photo)
        }
    }
}

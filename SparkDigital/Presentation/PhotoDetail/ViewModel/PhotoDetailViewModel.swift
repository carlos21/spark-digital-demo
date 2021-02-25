//
//  PhotoDetailViewModel.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation
import Core

/// Contains the logic to show the bigger image on a separate screen
class PhotoDetailViewModel {
    
    // MARK: - Properties
    
    /// Hold the object to call the list of photos web service
    private var photosRepository: PhotosRepositoryProtocol
    
    /// Notifies when the download status of the big version of the photo was changed
    var photoUpdated = DelegatedCall<PhotoVM>()
    
    /// Holds the current selected photo
    var photo: PhotoVM?
    
    // MARK: - Init
    
    
    /// Initializes the view model
    /// - Parameters:
    ///     - photosRepository: repository implementation to call the list of photos web service
    init(photosRepository: PhotosRepositoryProtocol) {
        self.photosRepository = photosRepository
    }
    
    /// Downloads the bigger version of the photo
    /// If only starts downloading the bigger version of the photo, if it wasn't downloaded yet
    /// When the photo downloads, it changes the state according to the server's response
    func download() {
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

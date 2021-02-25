//
//  PhotosViewModel.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation
import Core

/// Contains the logic to list the photos
/// Transforms the data received by the server handling the states for each photo. The photos are download as the user scrolls down to improve performance
class PhotosViewModel {
    
    // MARK: - Properties
    
    private var photosRepository: PhotosRepositoryProtocol
    private var state: ListState = .idle
    
    var photoUpdated = DelegatedCall<(photo: PhotoVM, indexPath: IndexPath)>()
    var showListLoading = DelegatedCall<Void>()
    var showListSuccess = DelegatedCall<Void>()
    var showListError = DelegatedCall<String>()
    var photos = [PhotoItemViewModel]()
    
    // MARK: - Init
    
    init(photosRepository: PhotosRepositoryProtocol) {
        self.photosRepository = photosRepository
    }
    
    // MARK: - Functions
    
    /// Retrieves the list of photos from the server
    /// Changes the state according to the server's response
    /// This method is called when the users access the app for first time or when they pull the list to refresh
    /// - Parameters:
    ///     - type: Type of loading
    func loadData(type: LoadingType) {
        if type == .firstTimeLoad {
            state = .loading
        }
        
        self.showListLoading.callback?(())
        photosRepository.getPhotos { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let photos):
                self.photos = photos.map {
                    let photo = PhotoVM(title: $0.title,
                                        url: $0.url,
                                        thumbnailUrl: $0.thumbnailUrl,
                                        thumbnailState: .idle,
                                        bigImageState: .idle)
                    return PhotoItemViewModel(photo: photo)
                }
                self.state = .success
                self.showListSuccess.callback?(())
                
            case .failure:
                self.state = .error
                self.showListError.callback?((R.string.localizable.loadingError()))
            }
        }
    }
    
    /// Downloads the photo from the server and changes its state
    /// Validates if the photo was already downloaded or not
    /// - Parameters:
    ///     - photo: reference to the photo
    ///     - indexPath: position of the photo in the array
    func download(photo: PhotoVM, indexPath: IndexPath) {
        guard photo.thumbnailState.shouldDownload else { return }
        
        photo.thumbnailState = .loading
        photoUpdated.callback?((photo, indexPath))
        photosRepository.downloadPhoto(path: photo.thumbnailUrl) { [weak self] result in
            switch result {
            case .success(let data):
                photo.thumbnailState = .success(data)
                
            case .failure:
                photo.thumbnailState = .error
            }
            
            guard let self = self else { return }
            self.photoUpdated.callback?((photo, indexPath))
        }
    }
}

extension PhotosViewModel {
    
    enum LoadingType {
        
        /// Type to indicate that the user manually pulls the list to refresh
        case pullToRefresh
        
        /// Type to indicate that the user enters the screen for the first time
        case firstTimeLoad
    }
}

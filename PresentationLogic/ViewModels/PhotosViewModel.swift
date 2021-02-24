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
public class PhotosViewModel {
    
    // MARK: - Properties
    
    private var photosRepository: PhotosRepositoryProtocol
    private var state: ListState = .idle
    
    public var photoUpdated = DelegatedCall<(photo: PhotoVM, indexPath: IndexPath)>()
    public var showListLoading = DelegatedCall<Void>()
    public var showListSuccess = DelegatedCall<Void>()
    public var showListError = DelegatedCall<String>()
    public var photos = [PhotoVM]()
    
    // MARK: - Init
    
    public init(photosRepository: PhotosRepositoryProtocol) {
        self.photosRepository = photosRepository
    }
    
    // MARK: - Functions
    
    /// Retrieves the list of photos from the server
    /// Changes the state according to the server's response
    /// This method is called when the users access the app for first time or when they pull the list to refresh
    /// - Parameters:
    ///     - type: Type of loading
    public func loadData(type: LoadingType) {
        if type == .firstTimeLoad {
            state = .loading
        }
        photosRepository.getPhotos { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let photos):
                self.photos = photos.map {
                    PhotoVM(title: $0.title,
                            url: $0.url,
                            thumbnailUrl: $0.thumbnailUrl,
                            thumbnailState: .idle,
                            bigImageState: .idle)
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
    public func download(photo: PhotoVM, indexPath: IndexPath) {
        guard photo.thumbnailState.shouldDownload else { return }
        
        photo.thumbnailState = .loading
        photoUpdated.callback?((photo, indexPath))
        showListLoading.callback?(())
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
    
    public enum LoadingType {
        
        /// The user manually pulls the list to refresh
        case pullToRefresh
        
        /// The user enters the screen for the first time
        case firstTimeLoad
    }
}

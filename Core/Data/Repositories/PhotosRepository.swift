//
//  PhotosRepository.swift
//  Core
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation

/// PhotosRepository is a concrete implementation to retrieve a list of photos and download an specific image
final public class PhotosRepository: PhotosRepositoryProtocol {
    
    // MARK: - Properties
    
    private let transferService: DataTransferServiceProtocol
    
    // MARK: - Init
    
    public init(transferService: DataTransferServiceProtocol) {
        self.transferService = transferService
    }
    
    // MARK: - Functions
    
    /// Gets a json of photos from the server
    @discardableResult
    public func getPhotos(completion: @escaping GetPhotosCompletionHandler) -> NetworkCancellable? {
        let endpoint = API.Photos.getList()
        return transferService.request(with: endpoint, completion: completion)
    }
    
    /// Downloads a specific photo using a path
    @discardableResult
    public func downloadPhoto(path: String, completion: @escaping DownloadPhotoCompletionHandler) -> NetworkCancellable? {
        let endpoint = API.Image.getImage(path: path)
        return transferService.request(with: endpoint, completion: completion)
    }
}

//
//  PhotosRepository.swift
//  Core
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation

final public class PhotosRepository: PhotosRepositoryProtocol {
    
    // MARK: - Properties
    
    private let transferService: DataTransferServiceProtocol
    
    // MARK: - Init
    
    public init(transferService: DataTransferServiceProtocol) {
        self.transferService = transferService
    }
    
    // MARK: - Functions
    
    @discardableResult
    public func getPhotos(completion: @escaping GetPhotosCompletionHandler) -> NetworkCancellable? {
        let endpoint = API.Photo.getList()
        return transferService.request(with: endpoint, completion: completion)
    }
    
    @discardableResult
    public func downloadPhoto(path: String, completion: @escaping DownloadPhotoCompletionHandler) -> NetworkCancellable? {
        let endpoint = API.Image.getImage(path: path)
        return transferService.request(with: endpoint, completion: completion)
    }
}

//
//  PhotosRepositoryProtocol.swift
//  Core
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation

public typealias GetPhotosCompletionHandler = (Result<[PhotoResponse], DataTransferError>) -> Void
public typealias DownloadPhotoCompletionHandler = (Result<Data, DataTransferError>) -> Void

public protocol PhotosRepositoryProtocol {
    
    @discardableResult
    func getPhotos(completion: @escaping GetPhotosCompletionHandler) -> NetworkCancellable?
    
    @discardableResult
    func downloadPhoto(path: String, completion: @escaping DownloadPhotoCompletionHandler) -> NetworkCancellable?
}

//
//  PhotosRepositoryProtocol.swift
//  Core
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation

public typealias GetPhotosCompletionHandler = (Result<[Photo], DataTransferError>) -> Void
public typealias DownloadPhotoCompletionHandler = (Result<Data, DataTransferError>) -> Void

/// Interface that defines the necessary methods to retrieving photos
public protocol PhotosRepositoryProtocol {
    
    /// Returns the task of the web service call so It can be cancelled at any time
    /// - Parameters:
    ///     - completion: Callback to get the photos from the server
    @discardableResult
    func getPhotos(completion: @escaping GetPhotosCompletionHandler) -> NetworkCancellable?
    
    /// Returns the task of the web service call so It can be cancelled at any time
    /// - Parameters:
    ///     - path: URL of the photo
    ///     - completion: Callback to get the photo bytes
    @discardableResult
    func downloadPhoto(path: String, completion: @escaping DownloadPhotoCompletionHandler) -> NetworkCancellable?
}

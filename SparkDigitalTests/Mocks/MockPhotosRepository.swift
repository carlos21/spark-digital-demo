//
//  MockPhotosRepository.swift
//  SparkDigitalTests
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation
import Core

class MockPhotosRepository: PhotosRepositoryProtocol {
    
    private let shouldFail: Bool
    
    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }
    
    @discardableResult
    func getPhotos(completion: @escaping GetPhotosCompletionHandler) -> NetworkCancellable? {
        guard !shouldFail else {
            completion(.failure(DataTransferError.noResponse))
            return nil
        }
        
        do {
            let data = try LocalFileReader.shared.getData(from: "photos.json")
            let photos = try JSONDecoder().decode([Photo].self, from: data)
            completion(.success(photos))
        } catch {
            assertionFailure("File not found")
        }
        return nil
    }
    
    @discardableResult
    func downloadPhoto(path: String, completion: @escaping DownloadPhotoCompletionHandler) -> NetworkCancellable? {
        guard !shouldFail else {
            completion(.failure(DataTransferError.noResponse))
            return nil
        }
        
        do {
            let data = try LocalFileReader.shared.getData(from: "photo.png")
            completion(.success(data))
        } catch {
            assertionFailure("File not found")
        }
        return nil
    }
}

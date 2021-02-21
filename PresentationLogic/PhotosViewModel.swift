//
//  PhotosViewModel.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation
import Core

public class PhotosViewModel {
    
    // MARK: - Properties
    
    public var getListUseCase: GetPhotosUseCase
    public var state = DelegatedCall<ListState>()
    public var photoUpdated = DelegatedCall<(photo: PhotoVM, indexPath: IndexPath)>()
    public var photos = [PhotosViewModel.PhotoVM]()
    
    // MARK: - Init
    
    public init(getListUseCase: GetPhotosUseCase) {
        self.getListUseCase = getListUseCase
    }
    
    // MARK: - Functions
    
    public func loadData(type: LoadingType) {
        if type == .firstTimeLoad {
            state.callback?(.loading)
        }
        getListUseCase.getPhotos { [weak self] result in
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
                self.state.callback?(.success)
                
            case .failure(let error):
                self.state.callback?(.error(error.localizedDescription))
            }
        }
    }
    
    public func download(photo: PhotoVM, indexPath: IndexPath) {
        guard photo.thumbnailState.shouldDownload else { return }
        
        photo.thumbnailState = .loading
        getListUseCase.downloadPhoto(path: photo.thumbnailUrl) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                photo.thumbnailState = .success(data)
                
            case .failure:
                photo.thumbnailState = .error
            }
            self.photoUpdated.callback?((photo, indexPath))
        }
    }
}

extension PhotosViewModel {
 
    public class PhotoVM {
        
        public let title: String
        public let url: String
        public let thumbnailUrl: String
        public var thumbnailState: PhotoState
        public var bigImageState: PhotoState
        
        public var thumbnailData: Data? {
            switch thumbnailState {
            case .success(let data):
                return data
                
            default:
                return nil
            }
        }
        
        init(title: String, url: String, thumbnailUrl: String, thumbnailState: PhotoState, bigImageState: PhotoState) {
            self.title = title
            self.url = url
            self.thumbnailUrl = thumbnailUrl
            self.thumbnailState = thumbnailState
            self.bigImageState = bigImageState
        }
    }
}

extension PhotosViewModel {
    
    public enum ListState {
        
        case idle
        case loading
        case success
        case error(String)
    }
    
    public enum PhotoState {
        
        case idle
        case loading
        case success(Data)
        case error
        
        var shouldDownload: Bool {
            switch self {
            case .idle, .error:
                return true
                
            default:
                return false
            }
        }
    }
    
    public enum LoadingType {
        
        case pullToRefresh
        case firstTimeLoad
    }
}

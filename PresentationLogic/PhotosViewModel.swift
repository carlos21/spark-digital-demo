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
    public var downloadImageUseCase: DownloadImageUseCase
    public var state = DelegatedCall<ListState>()
    public var photoUpdated = DelegatedCall<(photo: PhotoVM, indexPath: IndexPath)>()
    public var photos = [PhotoVM]()
    
    // MARK: - Init
    
    public init(getListUseCase: GetPhotosUseCase,
                downloadImageUseCase: DownloadImageUseCase) {
        self.getListUseCase = getListUseCase
        self.downloadImageUseCase = downloadImageUseCase
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
        downloadImageUseCase.downloadPhoto(path: photo.thumbnailUrl) { [weak self] result in
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
        
        case pullToRefresh
        case firstTimeLoad
    }
}

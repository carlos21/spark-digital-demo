//
//  PhotoZoomViewModel.swift
//  PresentationLogic
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation
import Core

public class PhotoZoomViewModel {
    
    // MARK: - Properties
    
    public var downloadImageUseCase: DownloadImageUseCase
    public var photoUpdated = DelegatedCall<PhotoVM>()
    public var photo: PhotoVM?
    
    // MARK: - Init
    
    public init(downloadImageUseCase: DownloadImageUseCase) {
        self.downloadImageUseCase = downloadImageUseCase
    }
    
    public func download() {
        guard let photo = self.photo, photo.bigImageState.shouldDownload else { return }
        
        photo.bigImageState = .loading
        downloadImageUseCase.downloadPhoto(path: photo.url) { [weak self] result in
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

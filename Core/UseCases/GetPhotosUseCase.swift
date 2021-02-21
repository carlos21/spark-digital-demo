//
//  GetPhotosUseCase.swift
//  Core
//
//  Created by Carlos Duclos on 19/02/21.
//

import Foundation

final public class GetPhotosUseCase {
    
    public typealias GetPhotosCompletionHandler = (Result<[PhotoResponse], DataTransferError>) -> Void
    
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
        let cancellable = transferService.request(with: endpoint) { result in
            switch result {
            case .success(let photos):
                completion(.success(photos))

            case .failure(let error):
                completion(.failure(error))
            }
        }
        return cancellable
    }
}

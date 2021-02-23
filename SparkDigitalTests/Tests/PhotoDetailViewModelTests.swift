//
//  PhotoDetailViewModelTests.swift
//  SparkDigitalTests
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation
import XCTest
@testable import PresentationLogic
@testable import Core

class PhotoDetailViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testDownloadPhotoShouldSuccess() {
        let photo = PhotoVM(title: "", url: "", thumbnailUrl: "", thumbnailState: .idle, bigImageState: .idle)
        let photoData = try! LocalFileReader.shared.getData(from: "photo.png")
        let mockRepository = MockPhotosRepository()
        let viewModel = PhotoDetailViewModel(photosRepository: mockRepository)
        viewModel.photo = photo
        var timesToEnter = 0
        
        viewModel.photoUpdated.delegate(to: self) { (self, photo) in
            timesToEnter += 1
            
            if timesToEnter == 1 {
                XCTAssert(photo.bigImageState == .loading, "State should be loading first")
                return
            }
            
            if timesToEnter == 2 {
                XCTAssert(photo.bigImageState == .success(Data()), "State should be success")
                XCTAssert(photo.bigImageData == photoData, "Photo data should be the same")
            }
        }
        
        viewModel.download()
    }
    
    func testPhotoShouldNotDownloadIfAlreadyDid() {
        let photo = PhotoVM(title: "", url: "", thumbnailUrl: "", thumbnailState: .idle, bigImageState: .success(Data()))
        let mockRepository = MockPhotosRepository()
        let viewModel = PhotoDetailViewModel(photosRepository: mockRepository)
        viewModel.photo = photo
        
        viewModel.photoUpdated.delegate(to: self) { (self, photo) in
            XCTAssert(photo.bigImageState == .success(Data()), "State should be success")
        }
        
        viewModel.download()
    }
    
    func testPhotoShouldNotDownloadIfLoading() {
        let photo = PhotoVM(title: "", url: "", thumbnailUrl: "", thumbnailState: .idle, bigImageState: .loading)
        let mockRepository = MockPhotosRepository()
        let viewModel = PhotoDetailViewModel(photosRepository: mockRepository)
        viewModel.photo = photo
        
        viewModel.photoUpdated.delegate(to: self) { (self, photo) in
            XCTAssert(photo.bigImageState == .loading, "State should be loading")
        }
        
        viewModel.download()
    }
}

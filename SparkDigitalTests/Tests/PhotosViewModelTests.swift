//
//  PhotosViewModelTests.swift
//  PhotosViewModelTests
//
//  Created by Carlos Duclos on 19/02/21.
//

import XCTest
@testable import SparkDigital
@testable import PresentationLogic
@testable import Core

class PhotosViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testFirstTimePhotosShouldSetSuccessState() throws {
        let mockRepository = MockPhotosRepository()
        let viewModel = PhotosViewModel(photosRepository: mockRepository)
        var timesToEnter = 0
        
        viewModel.state.delegate(to: self) { (self, state) in
            timesToEnter += 1
            
            if timesToEnter == 1 {
                XCTAssert(state == .loading, "State should be loading first")
                return
            }
            
            if timesToEnter == 2 {
                XCTAssert(state == .success, "State should be success")
                XCTAssert(viewModel.photos.count == 17, "Not all photos were loaded")
                return
            }
        }
        
        viewModel.loadData(type: .firstTimeLoad)
    }
    
    func testPullToRefreshPhotosShouldSetSuccessState() {
        let mockRepository = MockPhotosRepository()
        let viewModel = PhotosViewModel(photosRepository: mockRepository)
        viewModel.state.delegate(to: self) { (self, state) in
            XCTAssert(state == .success, "State should be success")
        }
        
        viewModel.loadData(type: .pullToRefresh)
    }
    
    func testWhenFailedStateShouldSetToError() {
        let mockRepository = MockPhotosRepository(shouldFail: true)
        let viewModel = PhotosViewModel(photosRepository: mockRepository)
        var timesToEnter = 0
        
        viewModel.state.delegate(to: self) { (self, state) in
            timesToEnter += 1
            
            if timesToEnter == 1 {
                XCTAssert(state == .loading, "State should be loading first")
                return
            }
            
            if timesToEnter == 2 {
                XCTAssert(state == .error(""), "State should be error")
            }
        }
        viewModel.loadData(type: .firstTimeLoad)
    }
    
    func testDownloadPhotoShouldSuccess() {
        let photo = PhotoVM(title: "", url: "", thumbnailUrl: "", thumbnailState: .idle, bigImageState: .idle)
        let photoData = try! LocalFileReader.shared.getData(from: "photo.png")
        let mockRepository = MockPhotosRepository()
        let viewModel = PhotosViewModel(photosRepository: mockRepository)
        var timesToEnter = 0
        
        viewModel.photoUpdated.delegate(to: self) { (self, data) in
            timesToEnter += 1
            
            if timesToEnter == 1 {
                XCTAssert(data.photo.thumbnailState == .loading, "State should be loading first")
                return
            }
            
            if timesToEnter == 2 {
                XCTAssert(data.photo.thumbnailState == .success(Data()), "State should be error")
                XCTAssert(data.photo.thumbnailData == photoData, "Photo data should be the same")
            }
        }
        
        viewModel.download(photo: photo, indexPath: IndexPath(row: 0, section: 0))
    }
    
    func testDownloadPhotoShouldFail() {
        let photo = PhotoVM(title: "", url: "", thumbnailUrl: "", thumbnailState: .idle, bigImageState: .idle)
        let mockRepository = MockPhotosRepository(shouldFail: true)
        let viewModel = PhotosViewModel(photosRepository: mockRepository)
        var timesToEnter = 0
        
        viewModel.photoUpdated.delegate(to: self) { (self, data) in
            timesToEnter += 1
            
            if timesToEnter == 1 {
                XCTAssert(data.photo.thumbnailState == .loading, "State should be loading first")
                return
            }
            
            if timesToEnter == 2 {
                XCTAssert(data.photo.thumbnailState == .error, "State should be error")
            }
        }
        
        viewModel.download(photo: photo, indexPath: IndexPath(row: 0, section: 0))
    }
}

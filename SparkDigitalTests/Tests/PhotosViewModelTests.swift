//
//  PhotosViewModelTests.swift
//  PhotosViewModelTests
//
//  Created by Carlos Duclos on 19/02/21.
//

import XCTest
@testable import SparkDigital
@testable import Core

class PhotosViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testFirstTimePhotosShouldSetSuccessState() throws {
        let mockRepository = MockPhotosRepository()
        let viewModel = PhotosViewModel(photosRepository: mockRepository)
        var states: [ListState] = []
        let expectation = self.expectation(description: "Should load the photos")
        
        viewModel.showListLoading.delegate(to: self) { (self, _) in
            states.append(.loading)
        }
        
        viewModel.showListSuccess.delegate(to: self) { (self, _) in
            states.append(.success)
            XCTAssert(states == [.loading, .success], "States are wrong")
            expectation.fulfill()
        }
        
        viewModel.showListError.delegate(to: self) { (self, _) in
            XCTFail("It should load successfully")
        }
        
        viewModel.loadData(type: .firstTimeLoad)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testPullToRefreshPhotosShouldSetSuccessState() {
        let mockRepository = MockPhotosRepository()
        let viewModel = PhotosViewModel(photosRepository: mockRepository)
        let expectation = self.expectation(description: "Should load the photos")
        
        viewModel.showListSuccess.delegate(to: self) { (self, _) in
            expectation.fulfill()
        }
        
        viewModel.showListError.delegate(to: self) { (self, _) in
            XCTFail("It should load successfully")
        }

        viewModel.loadData(type: .pullToRefresh)
        wait(for: [expectation], timeout: 0.1)
    }

    func testWhenFailedStateShouldSetToError() {
        let mockRepository = MockPhotosRepository(shouldFail: true)
        let viewModel = PhotosViewModel(photosRepository: mockRepository)
        var states: [ListState] = []
        let expectation = self.expectation(description: "Should NOT load the photos")

        viewModel.showListLoading.delegate(to: self) { (self, _) in
            states.append(.loading)
        }
        
        viewModel.showListSuccess.delegate(to: self) { (self, _) in
            XCTFail("It should not load")
        }
        
        viewModel.showListError.delegate(to: self) { (self, _) in
            states.append(.error)
            XCTAssert(states == [.loading, .error], "States are wrong")
            expectation.fulfill()
        }
        
        viewModel.loadData(type: .firstTimeLoad)
        wait(for: [expectation], timeout: 0.1)
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

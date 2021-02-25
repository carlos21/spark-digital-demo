//
//  CoreTests.swift
//  SparkDigitalTests
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation

import XCTest
@testable import SparkDigital
@testable import Core

class CoreTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }
    
    func testValidJsonResponseShouldBeDecoded() {
        let config = NetworkConfigurableMock()
        let responseData = try! LocalFileReader.shared.getData(from: "photos.json")
        let expectation = self.expectation(description: "Should decode mock object")
        
        let networkService = NetworkService(config: config,
                                            sessionManager: MockNetworkSessionManager(response: nil,
                                                                                      data: responseData,
                                                                                      error: nil))
        let service = DataTransferService(with: networkService)
        
        _ = service.request(with: Endpoint<[Photo]>(path: "", method: .get)) { result in
            switch result {
            case .success(let photos):
                XCTAssert(photos[0].id == 4984, "Id is not correct")
                XCTAssert(photos[0].title == "sint enim ea similique officiis necessitatibus fugiat et", "title is not correct")
                XCTAssert(photos[0].url == "https://via.placeholder.com/600/1fa7b9", "url is not correct")
                XCTAssert(photos[0].thumbnailUrl == "https://via.placeholder.com/150/1fa7b9", "thumbnailUrl is not correct")
                expectation.fulfill()
                
            case .failure:
                XCTFail("Should have decoded")
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testInvalidJsonResponseShouldFail() {
        let config = NetworkConfigurableMock()
        let responseData = try! LocalFileReader.shared.getData(from: "invalid.json")
        let expectation = self.expectation(description: "Should not decode invalid json")
        
        let networkService = NetworkService(config: config,
                                            sessionManager: MockNetworkSessionManager(response: nil,
                                                                                      data: responseData,
                                                                                      error: nil))
        let service = DataTransferService(with: networkService)
        
        _ = service.request(with: Endpoint<[Photo]>(path: "", method: .get)) { result in
            switch result {
            case .success:
                XCTFail("Shouldn't have decoded")
                
            case .failure(let error):
                XCTAssert(error == .parsing(error), "Should indicate parsing error")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}

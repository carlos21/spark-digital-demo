//
//  LocalFileReader.swift
//  SparkDigitalTests
//
//  Created by Carlos Duclos on 21/02/21.
//

import Foundation
import XCTest

class LocalFileReader {
    
    static let shared = LocalFileReader()
    
    func getData(from fileName: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: fileName, withExtension: "") else {
            XCTFail("Missing File: \(fileName)")
            throw TestError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            throw error
        }
      }
}

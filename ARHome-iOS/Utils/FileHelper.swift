//
//  FileHelper.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation

enum FileHelper {
  
  static func loadBundledJSON<T: Decodable>(file: String) -> T {
    guard let url = Bundle.main.url(forResource: file, withExtension: "json") else {
      fatalError("Resource not found: \(file)")
    }
    return try! loadJSON(from: url)
  }
  
  static func loadJSON<T: Decodable>(from url: URL) throws -> T {
    let data = try Data(contentsOf: url)
    return try appDecoder.decode(T.self, from: data)
  }
  
}

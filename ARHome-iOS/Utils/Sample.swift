//
//  Sample.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation

extension ObjectType {
  
  static func sample(id: Int) -> ObjectType {
    return Self.all[id - 1]
  }
  
  static var all: [ObjectType] {
    FileHelper.loadBundledJSON(file: "types")
  }
  
}

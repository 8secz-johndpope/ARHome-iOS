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
    Self.all[id - 1]
  }
  
  static var all: [ObjectType] {
    FileHelper.loadBundledJSON(file: "types")
  }
}

extension Object {
  static var all: [Object] {
    FileHelper.loadBundledJSON(file: "objects")
  }
  
  static func objects(typeID: Int) -> [Object] {
    all.filter { $0.typeID == typeID }
  }
  
  static func sample(id: Int) -> Object {
    Self.all[id - 1]
  }
}

extension AppState.ObjectList {
  static var sample: Self {
    var sample = Self()
    sample.objects = .init(grouping: Object.all) { $0.typeID }
    return sample
  }
}

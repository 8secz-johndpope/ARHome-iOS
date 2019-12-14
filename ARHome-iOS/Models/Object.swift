//
//  Object.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation

struct Object: Identifiable, Codable {
  let id: Int
  let name: String
  let typeID: Int
  let imageName: String
  let modelName: String
}

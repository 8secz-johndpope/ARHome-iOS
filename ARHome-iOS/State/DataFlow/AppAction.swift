//
//  AppAction.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation

enum AppAction {
  case openList
  
  case loadTypes
  case loadTypesDone(result: Result<[ObjectType], AppError>)
  
  case loadObjects(typeID: Int)
  case loadObjectsDone(typeID: Int, result: Result<[Object], AppError>)
}

//
//  APPState.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation

struct AppState {
  
  var typeList = TypeList()
  
}

extension AppState {
  struct TypeList {
    var types: [ObjectType]?
    
    var typesRequesting = false
    var typesError: AppError?
  }
}
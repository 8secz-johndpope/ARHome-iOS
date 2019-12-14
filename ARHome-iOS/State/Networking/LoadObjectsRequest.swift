//
//  LoadObjectsRequest.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import Combine

struct LoadObjectsRequest {
  let typeID: Int
  
  var publisher: AnyPublisher<[Object], AppError> {
    Future<[Object], AppError> { promise in
      DispatchQueue.global()
        .asyncAfter(deadline: .now() + 2) {
          promise(.success(Object.objects(typeID: self.typeID)))
        }
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }
}

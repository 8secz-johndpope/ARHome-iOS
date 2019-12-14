//
//  LoadTypesRequest.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import Combine

struct LoadTypesRequest {
  var publisher: AnyPublisher<[ObjectType], AppError> {
    Future<[ObjectType], AppError> { promise in
      DispatchQueue.global()
        .asyncAfter(deadline: .now() + 1) {
          promise(.success(ObjectType.all))
        }
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }
}

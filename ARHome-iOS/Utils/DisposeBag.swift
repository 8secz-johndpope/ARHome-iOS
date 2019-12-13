//
//  DisposeBag.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import Combine

class DisposeBag {
  private var values: [Cancellable] = []
  
  func add(_ value: Cancellable) {
    values.append(value)
  }
}

extension Cancellable {
  func disposed(by bag: DisposeBag) {
    bag.add(self)
  }
}

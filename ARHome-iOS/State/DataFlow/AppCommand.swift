//
//  AppCommand.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import Combine

var disposeBag = DisposeBag()

protocol AppCommand {
  func execute(in store: Store)
}

struct LoadTypesCommand: AppCommand {
  func execute(in store: Store) {
    LoadTypesRequest().publisher
      .sink(receiveCompletion: { complete in
        if case .failure(let error) = complete {
          store.dispatch(.loadTypesDone(result: .failure(error)))
        }
      }, receiveValue: { types in
        store.dispatch(.loadTypesDone(result: .success(types)))
      })
      .disposed(by: disposeBag)
  }
}

//
//  AppCommand.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import Combine
import RealityKit
import ARKit

var disposeBag = DisposeBag()

protocol AppCommand {
  func execute(in store: Store)
}

struct LoadModelCommand: AppCommand {
  let model: Object.Model
  
  func execute(in store: Store) {
    store.dispatch(.showMessage("正在加载模型，请稍候...", duration: nil))
    LoadModelRequest(model: model).publisher
      .sink(receiveCompletion: { complete in
        if case .failure(let error) = complete {
          store.dispatch(.loadModelDone(result: .failure(error)))
        }
      }, receiveValue: { entity in
        store.dispatch(.loadModelDone(result: .success(entity)))
      })
      .disposed(by: disposeBag)
  }
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

struct LoadObjectsCommand: AppCommand {
  let typeID: Int
  
  func execute(in store: Store) {
    LoadObjectsRequest(typeID: typeID).publisher
      .sink(receiveCompletion: { complete in
        if case .failure(let error) = complete {
          store.dispatch(.loadObjectsDone(typeID: self.typeID, result: .failure(error)))
        }
      }, receiveValue: { objects in
        store.dispatch(.loadObjectsDone(typeID: self.typeID, result: .success(objects)))
      })
    .disposed(by: disposeBag)
  }
}

struct ShowMessageCommand: AppCommand {
  let message: String
  let duration: TimeInterval?
  
  init(message: String, duration: TimeInterval? = nil) {
    self.message = message
    self.duration = duration
  }
  
  init(error: Error) {
    self.init(message: error.localizedDescription, duration: 2)
  }
    
  func execute(in store: Store) {
    store.dispatch(.showMessage(message, duration: duration))
  }
}

struct HideMessageCommand: AppCommand {
  let duration: TimeInterval?
  
  init(duration: TimeInterval? = nil) {
    self.duration = duration
  }
  
  func execute(in store: Store) {
    guard let duration = duration else {
      store.dispatch(.hideMessage)
      return
    }
    
    let hideDelay = Future<Void, Never> { promise in
      DispatchQueue.global()
        .asyncAfter(deadline: .now() + duration) {
          promise(.success(()))
        }
    }
    .receive(on: DispatchQueue.main)
    .sink {
      store.dispatch(.hideMessage)
    }
    
    store.dispatch(.hideDelay(hideDelay))
  }
}

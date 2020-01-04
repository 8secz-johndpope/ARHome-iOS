//
//  LoadModelRequest.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/16.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import Combine
import RealityKit

struct LoadModelRequest {
  let model: Object.Model
  let willGenerateCollisionShapes: Bool
  
  init(model: Object.Model, willGenerateCollisionShapes: Bool = true) {
    self.model = model
    self.willGenerateCollisionShapes = willGenerateCollisionShapes
  }
  
  var publisher: AnyPublisher<Entity, AppError> {
    guard !model.supportedPlane.isEmpty else {
      return Fail(outputType: Entity.self, failure: AppError.loadModelFailed(.cannotPlace(model)))
        .eraseToAnyPublisher()
    }
    
    if let savedModel = modelTemplates[model.modelName] {
      return Just(savedModel.clone(recursive: true))
        .mapError { _ -> AppError in }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    let modelPublisher: AnyPublisher<Entity, AppError>
    
    switch model.type {
    case .usdz:
      modelPublisher = Entity.loadModelAsync(named: model.file)
        .handleEvents(receiveOutput: {
          if self.willGenerateCollisionShapes {
            $0.generateCollisionShapes(recursive: true)
          }
        })
        .mapError { AppError.loadModelFailed(.internalError($0)) }
        .map { entity -> Entity in entity }
        .eraseToAnyPublisher()
    case let .reality(sceneName, modelName):
      modelPublisher = Entity.loadAsync(named: sceneName)
        .mapError(AppError.ModelError.internalError)
        .tryMap { anchor -> Entity in
          guard let entity = anchor.findEntity(named: modelName) else {
            throw AppError.ModelError.noModelInScene(sceneName, modelName: modelName)
          }
          return entity
        }
        .mapError { AppError.loadModelFailed($0 as! AppError.ModelError) }
        .eraseToAnyPublisher()
    }
    
    return modelPublisher
      .handleEvents(receiveOutput: {
        $0.name = self.model.modelName
        $0.components[ObjectModelComponent.self] = ObjectModelComponent(model: self.model)
      })
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

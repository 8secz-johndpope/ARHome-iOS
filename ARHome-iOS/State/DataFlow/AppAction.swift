//
//  AppAction.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import Combine
import RealityKit
import ARKit

enum AppAction {
  case openList
  case closeList
  
  case activeCoaching
  case deactiveCoaching
  
  case loadModel(Object.Model)
  case loadModelDone(result: Result<Entity, AppError>)
  
  case placeEntityFailure
  case placeEntityDone(anchor: (AnchorEntity, ARAnchor)?)
  case placeEntityCancel
  
  case beginDragging
  case endDragging
  
  case deleteEntity(id: Entity.ID)
  case clear
  
  case loadTypes
  case loadTypesDone(result: Result<[ObjectType], AppError>)
  
  case loadObjects(typeID: Int)
  case loadObjectsDone(typeID: Int, result: Result<[Object], AppError>)
  
  case showMessage(String, duration: TimeInterval?)
  case showError(AppError)
  case hideMessage
  case hideDelay(Cancellable)
}

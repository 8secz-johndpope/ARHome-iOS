//
//  APPState.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import Combine
import ARKit
import RealityKit

struct AppState {
  
  var arState = ARState()
  
  var typeList = TypeList()
  var objectList = ObjectList()
  
  var message = Message()
  
}

extension AppState {
  struct ARState {
    var isListActive = false
    var isCoachingActive = false
    
    var modelLoading = false
    
    var unanchoredEntity: Entity?
    
    var entities: [Entity.ID: Entity] = [:]
    var anchors: [Entity.ID: (AnchorEntity, ARAnchor)] = [:]
    
    var willRemoveAnchors: [(AnchorEntity, ARAnchor)] = []
    
    mutating func entityHasAnchoredTo(_ anchor: (AnchorEntity, ARAnchor)?) {
      guard let unanchoredEntity = unanchoredEntity else {
        return
      }
      
      entities[unanchoredEntity.id] = unanchoredEntity
      self.unanchoredEntity = nil
      
      guard let anchor = anchor else {
        return
      }
      
      anchors[anchor.0.id] = anchor
    }
    
    mutating func clear() {
      entities.removeAll()
      
      willRemoveAnchors = Array(anchors.values)
      anchors.removeAll()
    }
  }
}

extension AppState {
  struct TypeList {
    var types: [ObjectType]?
    
    var typesRequesting = false
    var typesError: AppError?
  }
}

extension AppState {
  struct ObjectList {
    var objects: [Int: [Object]] = [:]
    
    var objectsRequesting = false
    var objectsError: AppError?
    
    func objects(typeID: Int) -> [Object]? {
      objects[typeID]
    }
  }
}

extension AppState {
  struct Message {
    var content = ""
    var isPresented = false
    var hideDelay: Cancellable?
  }
}

//
//  ObjectModelComponent.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/20.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import RealityKit

struct ObjectModelComponent: Component, Codable {
  let model: Object.Model
  var isInTrashZone = false
  
  var supportedPlane: Object.Model.Plane {
    model.supportedPlane
  }
  
  var providedPlane: Object.Model.Plane {
    model.providedPlane
  }
}

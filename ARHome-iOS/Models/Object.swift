//
//  Object.swift
//  JSONGenarator
//
//  Created by 高健 on 2019/12/15.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import RealityKit

struct Object: Codable, Identifiable {
  struct Model: Codable {
    struct Plane: OptionSet, Codable {
      let rawValue: Int
      
      static let horizontal = Plane(rawValue: 1 << 0)
      static let vertical = Plane(rawValue: 1 << 1)
      
      static let any: Plane = [.horizontal, .vertical]
    }
    
    enum EntityType: Codable {
      case usdz
      case reality(sceneName: String, modelName: String)
      
      var typeNumber: Int {
        switch self {
        case .usdz: return 1
        case .reality: return 2
        }
      }
      
      var realityInfo: (sceneName: String, modelName: String)? {
        if case .reality(let sceneName, let modelName) = self {
          return (sceneName, modelName)
        } else {
          return nil
        }
      }
      
      enum CodingKeys: String, CodingKey {
        case typeNumber
        case scene
        case model
      }
      
      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeNumber, forKey: .typeNumber)
        try container.encodeIfPresent(realityInfo?.sceneName, forKey: .scene)
        try container.encodeIfPresent(realityInfo?.modelName, forKey: .model)
      }
      
      init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Int.self, forKey: .typeNumber)
        switch type {
        case 1:
          self = .usdz
        case 2:
          let sceneName = try container.decode(String.self, forKey: .scene)
          let modelName = try container.decode(String.self, forKey: .model)
          self = .reality(sceneName: sceneName, modelName: modelName)
        default:
          fatalError("Can't handle this type - \(type)")
        }
      }
    }
    
    let file: String
    let supportedPlane: Plane
    let providedPlane: Plane
    
    let type: EntityType
    
    var modelName: String {
      switch type {
      case .usdz: return file
      case .reality(let sceneName, let modelName): return "\(sceneName).\(modelName)"
      }
    }
    
    init(file: String, supportedPlane: Plane, providedPlane: Plane, type: EntityType = .usdz) {
      self.file = file
      self.supportedPlane = supportedPlane
      self.providedPlane = providedPlane
      self.type = type
    }
  }
  
  let id: Int
  let name: String
  let typeID: Int
  let thumbnail: String
  let model: Model?
  
}

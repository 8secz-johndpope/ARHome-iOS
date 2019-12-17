//
//  AppError.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation
import RealityKit

enum AppError: Error, Identifiable {
  enum ModelError: Error {
    case internalError(Error)
    case noModelInScene(String, modelName: String)
    case cannotPlace(Object.Model)
  }
  
  var id: String { localizedDescription }
  
  case networkingFailed(Error)
  case loadModelFailed(ModelError)
  case invalidModel(Entity)
  case unknown
}

extension AppError: LocalizedError {
  var localizedDescription: String {
    switch self {
    case .networkingFailed(let error):
      return "网络错误: \(error.localizedDescription)"
    case .loadModelFailed(let error):
      return "模型加载失败: \(error.localizedDescription)"
    case .invalidModel(let model):
      return "无效的模型 - \(model.name)"
    case .unknown:
      return "未知错误"
    }
  }
}

extension AppError.ModelError: LocalizedError {
  var localizedDescription: String{
    switch self {
    case .internalError(let error):
      return error.localizedDescription
    case let .noModelInScene(sceneName, modelName):
      return "\(sceneName)不包含名为\(modelName)的Entity"
    case .cannotPlace(let model):
      return "无法放置的模型：\(model.modelName)"
    }
  }
}

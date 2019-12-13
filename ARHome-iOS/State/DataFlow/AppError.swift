//
//  AppError.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import Foundation

enum AppError: Error, Identifiable {
  var id: String { localizedDescription }
  
  case networkingFailed(Error)
}

extension AppError: LocalizedError {
  var localizedDescription: String {
    switch self {
    case .networkingFailed(let error):
      return "网络错误: \(error.localizedDescription)"
    }
  }
}

//
//  Store.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import SwiftUI

class Store: ObservableObject {
  
  static func reduce(state: AppState, action: AppAction) -> (AppState, AppCommand?) {
    var appState = state
    var appCommand: AppCommand?
    
    switch action {
    case .loadTypes:
      appState.typeList.typesRequesting = true
      appCommand = LoadTypesCommand()
    case .loadTypesDone(let result):
      appState.typeList.typesRequesting = false
      switch result {
      case .success(let types):
        appState.typeList.types = types
      case .failure(let error):
        appState.typeList.typesError = error
      }
    }
    
    return (appState, appCommand)
  }
  
  @Published var appState = AppState()
  
  func dispatch(_ action: AppAction) {
    #if DEBUG
    print("[ACTION]: \(action)")
    #endif
    let result = Store.reduce(state: appState, action: action)
    appState = result.0
    
    if let command = result.1 {
      #if DEBUG
      print("[COMMAND]: \(command)")
      #endif
      command.execute(in: self)
    }
  }
  
}

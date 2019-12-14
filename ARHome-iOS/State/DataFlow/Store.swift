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
    case .openList:
      appState.arState.isListActive = true
    case .closeList:
      appState.arState.isListActive = false
      
    case .loadTypes:
      guard !appState.typeList.typesRequesting else {
        break
      }
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
      
    case .loadObjects(let typeID):
      guard !appState.objectList.objectsRequesting else {
        break
      }
      appState.objectList.objectsRequesting = true
      appCommand = LoadObjectsCommand(typeID: typeID)
    case .loadObjectsDone(let typeID, let result):
      appState.objectList.objectsRequesting = false
      switch result {
      case .success(let objects):
        appState.objectList.objects[typeID] = objects
      case .failure(let error):
        appState.objectList.objectsError = error
      }
      
    case .showMessage(let message, let duration):
      appState.message.content = message
      appState.message.isPresented = true
      appState.message.hideDelay = nil
      appCommand = duration.map(HideMessageCommand.init)
    case .hideMessage:
      appState.message.isPresented = false
    case .hideDelay(let cancellable):
      appState.message.hideDelay = cancellable
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

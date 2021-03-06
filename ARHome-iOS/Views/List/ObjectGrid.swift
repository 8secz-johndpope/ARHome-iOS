//
//  ObjectGrid.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import SwiftUI
import SwiftUIExtensions

struct ObjectGrid: View {
  let typeID: Int
  
  @EnvironmentObject var store: Store
  
  var objectList: AppState.ObjectList {
    store.appState.objectList
  }
  
  var objects: [Object] {
    objectList.objects[typeID] ?? []
  }
  
  var body: some View {
    Group {
      if objectList.objects[typeID] == nil || objectList.objectsRequesting {
        Text("加载中...")
          .foregroundColor(.gray)
          .onAppear {
            self.store.dispatch(.loadObjects(typeID: self.typeID))
        }
      } else {
        Grid(objects) { object in
          ObjectGridItem(object: object)
            .onTapGesture {
              guard let model = object.model else {
                return
              }
              self.store
                .dispatch(.loadModel(model))
              self.store.dispatch(.closeList)
            }
        }
        .gridStyle(
          ModularGridStyle(columns: .count(2), rows: .min(180))
        )
      }
    }
  }
}

struct ObjectGrid_Previews: PreviewProvider {
  
  static var store: Store {
    let store = Store()
    store.appState.objectList = .sample
    return store
  }
  
  static var typeID: Int { 4 }
  
  static var previews: some View {
    NavigationView {
      ObjectGrid(typeID: typeID).environmentObject(store)
        .navigationBarTitle(ObjectType.sample(id: typeID).name)
    }
  }
}

//
//  TypeList.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import SwiftUI

struct TypeList: View {
  @EnvironmentObject var store: Store
  
  var body: some View {
    List(store.appState.typeList.types ?? []) { type in
      NavigationLink(
        destination: ObjectGrid(typeID: type.id)
          .navigationBarTitle(type.name)
      ) {
        TypeListRow(type: type)
      }
    }
  }
}

struct TypeList_Previews: PreviewProvider {
  static var store: Store {
    let store = Store()
    store.appState.typeList.types = ObjectType.all
    return store
  }
  
  static var previews: some View {
    NavigationView {
      TypeList().environmentObject(store)
        .navigationBarTitle("类别")
    }
  }
}

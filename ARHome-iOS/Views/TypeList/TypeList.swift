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
      NavigationLink(destination: EmptyView()) {
        TypeListRow(type: type)
      }
    }
  }
}

struct TypeList_Previews: PreviewProvider {
  static var previews: some View {
    TypeList().environmentObject(Store())
  }
}

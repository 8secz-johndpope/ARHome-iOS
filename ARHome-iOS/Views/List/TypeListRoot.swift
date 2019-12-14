//
//  TypeListRoot.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import SwiftUI

struct TypeListRoot: View {
  @EnvironmentObject var store: Store
  
  var body: some View {
    NavigationView {
      if store.appState.typeList.types == nil {
        Text("加载中...")
          .foregroundColor(.gray)
          .onAppear {
            self.store.dispatch(.loadTypes)
          }
      } else {
        TypeList()
          .navigationBarTitle("类别")
      }
    }
  }
}

struct TypeListRoot_Previews: PreviewProvider {
  static var previews: some View {
    TypeListRoot().environmentObject(Store())
  }
}

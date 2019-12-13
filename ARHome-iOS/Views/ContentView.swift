//
//  ContentView.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/11/9.
//  Copyright © 2019 高健. All rights reserved.
//

import SwiftUI
import RealityKit

struct ContentView : View {
  
  @State var isCoachingActived = false
  
  var body: some View {
    ARViewContainer(isCoachingActived: $isCoachingActived)
      .edgesIgnoringSafeArea(.all)
      .onAppear {
        UIApplication.shared.isIdleTimerDisabled = true
      }
      .onDisappear {
        UIApplication.shared.isIdleTimerDisabled = false
      }
      .statusBar(hidden: true)
  }
  
}

struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

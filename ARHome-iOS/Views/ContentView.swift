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
  
  @EnvironmentObject var store: Store
  
  var arState: AppState.ARState {
    store.appState.arState
  }
  
  var arStateBinding: Binding<AppState.ARState> {
    $store.appState.arState
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      #if arch(arm64)
      ARViewContainer(isCoachingActived: arStateBinding.isCoachingActived)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
          UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
          UIApplication.shared.isIdleTimerDisabled = false
        }
        .statusBar(hidden: true)
      #else
      Rectangle()
        .fill(Color.gray)
        .edgesIgnoringSafeArea(.all)
      #endif
      
      if !arState.isCoachingActived {
        Button(action: {
          self.store.dispatch(.openList)
        }) {
          Image(systemName: "plus.circle")
            .font(.system(size: 44))
            .foregroundColor(.white)
            .padding()
        }
      }
    }
    .sheet(isPresented: arStateBinding.isListActive) {
      TypeListRoot()
        .environmentObject(self.store)
    }
    .messageHUD(isPresented: self.$store.appState.message.isPresented) {
      HStack {
        Text(self.store.appState.message.content)
          .fixedSize(horizontal: true, vertical: false)
          .padding()
        Spacer()
      }
      .blurBackground(style: .systemUltraThinMaterial, ignoringSafeAreaEdges: .top)
      .fixedSize(horizontal: false, vertical: true)
    }
  }
  
}

struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView().environmentObject(Store())
  }
}

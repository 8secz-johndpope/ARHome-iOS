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
  
  @State var trashZoneFrame: CGRect = .zero
  
  var body: some View {
    ZStack(alignment: .bottom) {
      arView
      if !arState.isCoachingActive && !arState.modelLoading && arState.unanchoredEntity == nil && !arState.isDragging {
        toolView
      }
      trashZone
        .opacity(arState.isDragging ? 1 : 0)
        .animation(.easeInOut(duration: 0.4))
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
      .blurBackground(style: .systemUltraThinMaterial, ignoringSafeAreaEdges: .all)
      .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  #if arch(arm64)
  var arView: some View {
    ARViewContainer(
      unanchoredModel: arStateBinding.unanchoredEntity,
      willRemoveAnchors: arStateBinding.willRemoveAnchors,
      trashZoneFrame: $trashZoneFrame
    )
    .edgesIgnoringSafeArea(.all)
    .onAppear {
      UIApplication.shared.isIdleTimerDisabled = true
    }
    .onDisappear {
      UIApplication.shared.isIdleTimerDisabled = false
    }
    .statusBar(hidden: true)
  }
  #else
  var arView: some View {
    Rectangle()
      .fill(Color.gray)
      .edgesIgnoringSafeArea(.all)
  }
  #endif
  
  var toolView: some View {
    ZStack(alignment: .bottom) {
      Button(action: {
        self.store.dispatch(.openList)
      }) {
        Image(systemName: "plus.circle")
          .font(.system(size: 44, weight: .thin))
          .foregroundColor(.white)
          .padding()
      }
      .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
      if !arState.entities.isEmpty {
        Button(action: {
          self.store.dispatch(.clear)
        }) {
          Image(systemName: "arrow.2.circlepath")
            .font(.system(size: 22, weight: .light))
            .foregroundColor(.white)
            .padding()
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
      }
    }
  }
  
  var trashZone: some View {
    GeometryReader { geometry in
      ZStack(alignment: .top) {
        Rectangle()
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [Color.red.opacity(0.7), Color.red.opacity(0)]),
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .edgesIgnoringSafeArea(.all)
          .frame(height: geometry.size.height / 4, alignment: .top)
          .onAppear {
            self.trashZoneFrame = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height / 4)
          }
        Text("移到此处删除")
          .font(.headline)
          .foregroundColor(Color.white)
          .padding()
      }
      .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
    }
  }
  
}

struct ContentView_Previews : PreviewProvider {
  static var store: Store {
    let store = Store()
    store.appState.arState.isDragging = true
    return store
  }
  
  static var previews: some View {
    ContentView().environmentObject(store)
  }
}

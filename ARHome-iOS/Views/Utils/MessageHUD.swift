//
//  MessageHUD.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/14.
//  Copyright © 2019 高健. All rights reserved.
//

import SwiftUI

struct MessageHUD<Content: View>: View {
  
  private let isPresented: Binding<Bool>
  private let makeContent: () -> Content
  
  init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
    self.isPresented = isPresented
    self.makeContent = content
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      makeContent()
      Spacer()
    }
    .offset(y: isPresented.wrappedValue ? 0 : -UIScreen.main.bounds.height)
    .animation(.interpolatingSpring(stiffness: 70, damping: 12))
  }
}

extension View {
  func messageHUD<Content: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View
  {
    overlay(
      MessageHUD(isPresented: isPresented, content: content)
    )
  }
}

struct MessageHUD_Previews: PreviewProvider {
  private static let isPresented = Binding(get: { true }, set: { _ in })
  
  static var previews: some View {
    Rectangle()
      .fill(Color.red)
      .edgesIgnoringSafeArea(.all)
      .messageHUD(isPresented: isPresented) {
        HStack {
          Text("Hello Wrold")
            .padding()
          Spacer()
        }
        .blurBackground(style: .systemMaterial, ignoringSafeAreaEdges: .all)
        .fixedSize(horizontal: false, vertical: true)
      }
  }
}

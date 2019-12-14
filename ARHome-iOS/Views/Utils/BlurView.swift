//
//  BlurView.swift
//  PokeMaster
//
//  Created by 王 巍 on 2019/08/09.
//  Copyright © 2019 OneV's Den. All rights reserved.
//

import SwiftUI
import UIKit

struct BlurView : UIViewRepresentable {
  let style: UIBlurEffect.Style
  
  func makeUIView(context: Context) -> UIVisualEffectView {
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
    blurView.translatesAutoresizingMaskIntoConstraints = false
    return blurView
  }
  
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: style)
  }
}

extension View {
  func blurBackground(style: UIBlurEffect.Style, ignoringSafeAreaEdges: Edge.Set = []) -> some View {
    ZStack {
      BlurView(style: style).edgesIgnoringSafeArea(ignoringSafeAreaEdges)
      self
    }
  }
}

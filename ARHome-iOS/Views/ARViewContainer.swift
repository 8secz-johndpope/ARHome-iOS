//
//  ARViewContainer.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/9.
//  Copyright © 2019 高健. All rights reserved.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

struct ARViewContainer: UIViewRepresentable {
  
  @Binding var isCoachingActived: Bool
  let resetSubject = PassthroughSubject<Void, Never>()
  
  func makeUIView(context: Context) -> ARView {
    let arView = ARView(frame: .zero)
    
    let coachingOverlay = ARCoachingOverlayView()
    coachingOverlay.goal = .horizontalPlane
    coachingOverlay.delegate = context.coordinator
    coachingOverlay.session = arView.session
    
    arView.addSubview(coachingOverlay)
    coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      coachingOverlay.topAnchor.constraint(equalTo: arView.topAnchor),
      coachingOverlay.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
      coachingOverlay.trailingAnchor.constraint(equalTo: arView.trailingAnchor),
      coachingOverlay.bottomAnchor.constraint(equalTo: arView.bottomAnchor)
    ])
    
    return arView
  }
  
  func updateUIView(_ uiView: ARView, context: Context) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  class Coordinator: NSObject {
    var parent: ARViewContainer
    
    init(_ parent: ARViewContainer) {
      self.parent = parent
    }
  }
  
}

extension ARViewContainer.Coordinator: ARCoachingOverlayViewDelegate {
  func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    parent.isCoachingActived = true
  }
  
  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    parent.isCoachingActived = false
  }
  
  func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
    parent.resetSubject.send()
  }
}

extension ARViewContainer.Coordinator {
  
  @objc func handleGesture(_ sender: Any) {
    switch sender {
    case let rotation as EntityRotationGestureRecognizer:
      rotateEntity(rotation)
    case let translation as EntityTranslationGestureRecognizer:
      translateEntity(translation)
    default:
      break
    }
  }
  
  private func rotateEntity(_ sender: EntityRotationGestureRecognizer) {
    
  }
  
  private func translateEntity(_ sender: EntityTranslationGestureRecognizer) {
    
  }
  
}

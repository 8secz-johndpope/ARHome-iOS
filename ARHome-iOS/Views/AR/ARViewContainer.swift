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

#if arch(arm64)

struct ARViewContainer: UIViewRepresentable {
  
  @EnvironmentObject var store: Store
  
  @Binding var unanchoredModel: Entity?
  @Binding var willRemoveAnchors: [(AnchorEntity, ARAnchor)]
  
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
    
    arView.automaticallyConfigureSession = false
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    configuration.environmentTexturing = .automatic
    configuration.isLightEstimationEnabled = true
    if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
      configuration.frameSemantics.insert(.personSegmentationWithDepth)
    }
    arView.session.run(configuration)
    
    let tapARViewGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapARView))
    arView.addGestureRecognizer(tapARViewGestureRecognizer)
    context.coordinator.tapARViewGestureRecognizer = tapARViewGestureRecognizer
    
    return arView
  }
  
  func updateUIView(_ arView: ARView, context: Context) {
    context.coordinator.tapARViewGestureRecognizer.isEnabled = unanchoredModel != nil
    
    if !willRemoveAnchors.isEmpty {
      willRemoveAnchors.forEach { entity, anchor in
        arView.scene.removeAnchor(entity)
        arView.session.remove(anchor: anchor)
      }
      willRemoveAnchors.removeAll()
    }
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  class Coordinator: NSObject {
    var parent: ARViewContainer
    
    var tapARViewGestureRecognizer: UITapGestureRecognizer!
    
    init(_ parent: ARViewContainer) {
      self.parent = parent
    }
  }
  
}

extension ARViewContainer.Coordinator: ARCoachingOverlayViewDelegate {
  func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    parent.store.dispatch(.activeCoaching)
  }
  
  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    parent.store.dispatch(.deactiveCoaching)
  }
  
  func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
    
  }
}

extension ARViewContainer.Coordinator {
  
  @objc func tapARView(_ sender: UITapGestureRecognizer) {
    guard let arView = sender.view as? ARView else {
      return
    }
    
    guard let unanchoredModel = parent.unanchoredModel, let unanchoredModelComponent = unanchoredModel.components[Object.Model.self] as? Object.Model else {
      return
    }
    
    let location = sender.location(in: arView)
    
    var anchorInfo: (AnchorEntity, ARAnchor)?
    
    if let result = arView.hitTest(location, query: .any).first(where: { result in
      guard let modelComponent = result.entity.components[Object.Model.self] as? Object.Model else {
        return false
      }
      return !unanchoredModelComponent.supportedPlane.intersection(modelComponent.providedPlane).isEmpty
    }) {
      unanchoredModel.setPosition(result.position, relativeTo: nil)
      result.entity.addChild(unanchoredModel, preservingWorldTransform: true)
    } else {
      guard let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first else {
        parent.store.dispatch(.placeEntityFailure)
        return
      }
      
      let anchor = ARAnchor(transform: result.worldTransform)
      arView.session.add(anchor: anchor)
      
      let anchorEntity = AnchorEntity(anchor: anchor)
      anchorEntity.addChild(unanchoredModel)
      arView.scene.addAnchor(anchorEntity)
      
      anchorInfo = (anchorEntity, anchor)
    }
    
    if let hasCollition = unanchoredModel as? HasCollision {
      arView.installGestures([.translation, .rotation], for: hasCollition)
    }
    
    parent.store.dispatch(.placeEntityDone(anchor: anchorInfo))
  }
  
  @objc func handleModelGesture(_ sender: Any) {
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

extension Object.Model.Plane {
  var targetAlignment: ARRaycastQuery.TargetAlignment {
    switch self {
    case .any:
      return .any
    case .horizontal:
      return .horizontal
    case .vertical:
      return .vertical
    default:
      fatalError()
    }
  }
}

#endif

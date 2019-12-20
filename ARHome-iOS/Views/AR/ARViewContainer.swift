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
  @Binding var trashZoneFrame: CGRect
  
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
    configuration.planeDetection = [.horizontal, .vertical]
    configuration.environmentTexturing = .automatic
    configuration.isLightEstimationEnabled = true
    if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
      configuration.frameSemantics.insert(.personSegmentationWithDepth)
    }
    arView.session.run(configuration)
    
    let tapARViewGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapARView))
    arView.addGestureRecognizer(tapARViewGestureRecognizer)
    
    context.coordinator.tapARViewGestureRecognizer = tapARViewGestureRecognizer
    context.coordinator.arView = arView
    
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
    
    var arView: ARView!
    var tapARViewGestureRecognizer: UITapGestureRecognizer!
    
    private var feedbackGenerator : UIImpactFeedbackGenerator?
    
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
    
    guard let unanchoredModel = parent.unanchoredModel, let unanchoredModelComponent = unanchoredModel.components[ObjectModelComponent.self] as? ObjectModelComponent else {
      return
    }
    
    let location = sender.location(in: arView)
    
    var anchorInfo: (AnchorEntity, ARAnchor)?
    
    if let result = arView.hitTest(location, query: .any).first(where: { result in
      guard let modelComponent = result.entity.components[ObjectModelComponent.self] as? ObjectModelComponent else {
        return false
      }
      return !unanchoredModelComponent.supportedPlane.intersection(modelComponent.providedPlane).isEmpty
    }) {
      unanchoredModel.setPosition(result.position, relativeTo: nil)
      result.entity.addChild(unanchoredModel, preservingWorldTransform: true)
    } else {
      guard let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: unanchoredModelComponent.supportedPlane.targetAlignment).first else {
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
        .forEach {
          $0.addTarget(self, action: #selector(handleModelGesture))
        }
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
  
  private func translateEntity(_ sender: EntityTranslationGestureRecognizer) {
    guard let entity = sender.entity, var component = entity.components[ObjectModelComponent.self] as? ObjectModelComponent else {
      return
    }
    
    let location = sender.location(in: arView)
    
    switch sender.state {
    case .began:
      feedbackGenerator = UIImpactFeedbackGenerator()
      feedbackGenerator?.prepare()
      
      parent.store.dispatch(.beginDragging)
      
    case .changed:
      let isInTrashZone = parent.trashZoneFrame.contains(location)
      guard component.isInTrashZone != isInTrashZone else {
        break
      }
      component.isInTrashZone = isInTrashZone
      entity.components[ObjectModelComponent.self] = component
      
      feedbackGenerator?.impactOccurred()
      feedbackGenerator?.prepare()
      
    case .ended:
      feedbackGenerator = nil
      
      parent.store.dispatch(.endDragging)
      
      guard !component.isInTrashZone else {
        parent.store.dispatch(.deleteEntity(id: entity.id))
        break
      }
      
    case .cancelled, .failed:
      feedbackGenerator = nil
      
      parent.store.dispatch(.endDragging)
      
    default: break
    }
  }
  
  private func rotateEntity(_ sender: EntityRotationGestureRecognizer) {
    
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

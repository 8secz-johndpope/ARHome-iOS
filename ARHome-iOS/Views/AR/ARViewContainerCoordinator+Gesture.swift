//
//  ARViewContainerCoordinator+Gesture.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/30.
//  Copyright © 2019 高健. All rights reserved.
//

import SwiftUI
import ARKit
import RealityKit

#if arch(arm64)

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
  
  private func rotateEntity(_ sender: EntityRotationGestureRecognizer) {
    
  }
}

private extension ARViewContainer.Coordinator {
  private func translateEntity(_ sender: EntityTranslationGestureRecognizer) {
    guard let entity = sender.entity, var component = entity.components[ObjectModelComponent.self] as? ObjectModelComponent else {
      return
    }
    
    switch sender.state {
    case .began:
      feedbackGenerator = UIImpactFeedbackGenerator()
      feedbackGenerator?.prepare()
      
      transform = entity.transform
      
      parent.store.dispatch(.beginDragging)
      
    case .changed:
      let isInTrashZone = parent.trashZoneFrame.contains(sender.location(in: arView))
      guard component.isInTrashZone != isInTrashZone else {
        break
      }
      component.isInTrashZone = isInTrashZone
      entity.components[ObjectModelComponent.self] = component
      
      feedbackGenerator?.impactOccurred()
      feedbackGenerator?.prepare()
      
    case .ended:
      defer {
        feedbackGenerator = nil
        transform = nil
      }
      
      guard !component.isInTrashZone else {
        parent.store.dispatch(.deleteEntity(id: entity.id))
        break
      }
      
      parent.store.dispatch(.endDragging)
      
      guard !canPlaceEntity(entity) else {
        break
      }
      
      entity.move(to: transform!, relativeTo: entity.parent!, duration: 0.3, timingFunction: .easeInOut)
      
      parent.store.dispatch(.showMessage("无法将该物品放置于此处", duration: 3))
      
    case .cancelled, .failed:
      defer {
        feedbackGenerator = nil
        transform = nil
      }
      
      entity.move(to: transform!, relativeTo: entity.parent!, duration: 0.3, timingFunction: .easeInOut)
      
      parent.store.dispatch(.endDragging)
      
    default: break
    }
  }
  
  private func canPlaceEntity(_ entity: Entity) -> Bool {
    guard let component = entity.components[ObjectModelComponent.self] as? ObjectModelComponent else {
      return false
    }
    
    let location = arView.project(entity.position(relativeTo: nil))!
    switch entity.parent {
    case _ as AnchorEntity:
      return !arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: component.supportedPlane.targetAlignment).isEmpty
    case let model:
      return arView.hitTest(location, query: .all).map({ $0.entity }).contains(model)
    }
  }
}

#endif

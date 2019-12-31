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
import MultipeerConnectivity

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
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = [.horizontal, .vertical]
    configuration.environmentTexturing = .automatic
    configuration.isLightEstimationEnabled = true
    if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
      configuration.frameSemantics.insert(.personSegmentationWithDepth)
    }
    configuration.isCollaborationEnabled = true
    arView.session.run(configuration)
    
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    let mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
    mcSession.delegate = context.coordinator
    
    let serviceType = "ar-collab"
    
    let serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
    serviceAdvertiser.delegate = context.coordinator
    serviceAdvertiser.startAdvertisingPeer()
    
    let serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
    serviceBrowser.delegate = context.coordinator
    serviceBrowser.startBrowsingForPeers()
    
    arView.scene.synchronizationService = try? MultipeerConnectivityService(session: mcSession)
    
    let tapARViewGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapARView))
    arView.addGestureRecognizer(tapARViewGestureRecognizer)
    
    context.coordinator.arView = arView
    context.coordinator.tapARViewGestureRecognizer = tapARViewGestureRecognizer
    context.coordinator.session = mcSession
    context.coordinator.advertiser = serviceAdvertiser
    context.coordinator.browser = serviceBrowser
    
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
    
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    var feedbackGenerator : UIImpactFeedbackGenerator?
    var transform: Transform?
    
    init(_ parent: ARViewContainer) {
      self.parent = parent
      super.init()
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

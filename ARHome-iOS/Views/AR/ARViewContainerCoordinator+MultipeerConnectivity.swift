//
//  ARViewContainerCoordinator+MultipeerConnectivity.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/30.
//  Copyright © 2019 高健. All rights reserved.
//

import ARKit
import MultipeerConnectivity

#if arch(arm64)

extension ARViewContainer.Coordinator: MCSessionDelegate {
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    
  }
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    
  }
  
  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    
  }
  
  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    
  }
  
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    if state == .connected {
      parent.store.dispatch(.showMessage("\(peerID.displayName)加入连接", duration: 5))
    }
  }
}

extension ARViewContainer.Coordinator: MCNearbyServiceBrowserDelegate {
  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    
  }
}

extension ARViewContainer.Coordinator: MCNearbyServiceAdvertiserDelegate {
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    invitationHandler(true, session)
  }
}

#endif

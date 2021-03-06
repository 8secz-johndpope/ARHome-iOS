//
//  AppDelegate.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/11/9.
//  Copyright © 2019 高健. All rights reserved.
//

import UIKit
import SwiftUI
import ARKit
import RealityKit
import Combine

var modelTemplates: [String: Entity] = [:]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  var cacellables: [AnyCancellable] = []

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let contentView = ContentView().environmentObject(Store())
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = UIHostingController(rootView: contentView)
    self.window = window
    window.makeKeyAndVisible()
    
    ObjectModelComponent.registerComponent()
    
    Object.all
      .compactMap { $0.model }
      .map { LoadModelRequest(model: $0).publisher }
      .reduce(Empty<Entity, AppError>().eraseToAnyPublisher()) { res, current in
        res.append(current).eraseToAnyPublisher()
      }
      .collect()
      .eraseToAnyPublisher()
      .sink(receiveCompletion: { _ in
        print("加载完成")
      }, receiveValue: { models in
        modelTemplates = [String: Entity](uniqueKeysWithValues: models.map { ($0.name, $0) })
      })
      .store(in: &cacellables)
    
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }


}


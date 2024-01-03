//
//  BaldursModManagerApp.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/2/24.
//

import SwiftUI

struct Debug {
  static let isActive = true
  
  static func log<T>(_ value: T) {
    if isActive {
      print(value)
    }
  }
}

@main
struct BaldursModManagerApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

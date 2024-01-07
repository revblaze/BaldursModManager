//
//  BaldursModManagerApp.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/5/24.
//

import SwiftUI
import SwiftData

@main
struct BaldursModManagerApp: App {
  
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      ModItem.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
  }
}

struct Debug {
  static var isActive = true
  static var fileTransferUI = false
  static var permissionsView = false
  
  static func log<T>(_ value: T) {
    if isActive {
      print(value)
    }
  }
}

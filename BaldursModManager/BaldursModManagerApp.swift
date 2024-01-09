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
  var container: ModelContainer
  
  init() {
    do {
      let fileManager = FileManager.default
      guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
        fatalError("Application Support directory not found.")
      }
      let storeURL = appSupportURL
        .appendingPathComponent(Constants.ApplicationSupportFolderName)
        .appendingPathComponent(Constants.ApplicationSwiftDataFileName)
      
      // Create the subfolder if it doesn't exist
      let subfolderURL = storeURL.deletingLastPathComponent()
      if !fileManager.fileExists(atPath: subfolderURL.path) {
        try fileManager.createDirectory(at: subfolderURL, withIntermediateDirectories: true)
      }
      
      let config = ModelConfiguration(url: storeURL)
      container = try ModelContainer(for: ModItem.self, configurations: config)
    } catch {
      fatalError("Failed to configure SwiftData container: \(error)")
    }
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .frame(minWidth: 600, idealWidth: 800, minHeight: 400, idealHeight: 600)
    }
    .modelContainer(container)
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

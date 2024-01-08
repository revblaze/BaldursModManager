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
    // Ensure SwiftData store files are in the correct location before initializing the ModelContainer
    FileUtility.moveSwiftDataStoreFiles()
    
    let schema = Schema([
      ModItem.self,
    ])
    
    // Get the path for the SwiftData store file in the Application Support directory
    let fileManager = FileManager.default
    guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      fatalError("Application Support directory not found.")
    }
    let swiftDataStorePath = appSupportURL.appendingPathComponent(Constants.ApplicationSupportFolderName).appendingPathComponent(Constants.ApplicationSwiftDataFileName).path
    let swiftDataStoreURL = appSupportURL.appendingPathComponent(Constants.ApplicationSupportFolderName).appendingPathComponent(Constants.ApplicationSwiftDataFileName)
    
    // Initialize the ModelConfiguration with the new store file path
    let modelConfiguration = ModelConfiguration(schema: schema, url: swiftDataStoreURL)
    //let modelConfig = ModelConfiguration(schema: schema, url: swiftDataStoreURL)
    //let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, allowsSave: true, groupContainer: Constants.ApplicationSupportFolderName, cloudKitDatabase: nil)
    // Note: adjust the parameters for ModelConfiguration based on your specific requirements and the API documentation of SwiftData
    
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

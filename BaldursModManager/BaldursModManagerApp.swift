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
  @Environment(\.global) var global
  var container: ModelContainer
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .frame(minWidth: 600, idealWidth: 900, minHeight: 400, idealHeight: 650)
        .environment(global)
        .onAppear {
          NSWindow.allowsAutomaticWindowTabbing = false
        }
    }
    .modelContainer(container)
    .commands {
      CommandGroup(before: .appSettings) {
        Button("Settings...") {
          global.showSettingsView = true
        }
        .keyboardShortcut(",", modifiers: [.command])
        Divider()
        MenuButton(title: "What's New") {
          global.showWhatsNewView = true
        }
        MenuButton(title: "Check for Updates...") {
          global.showUpdateView = true
        }
        .keyboardShortcut("U", modifiers: [.command])
      }
      CommandGroup(replacing: .newItem) {}
      CommandGroup(before: .importExport) {
        Button("Import Mod...") {
          global.showImportModPanel = true
        }
        .keyboardShortcut("O", modifiers: [.command])
      }
      
      CommandMenu("Debug") {
        Button(Debug.shared.isActive ? "Disable Debug" : "Enable Debug") {
          Debug.shared.isActive.toggle()
        }
        Divider()
        MenuButton(title: "Log ModItems") {
          Debug.shared.logModItems = true
        }
        Divider()
        MenuButton(title: "Simulate Error Toast") {
          Debug.shared.simulateErrorToast.toggle()
        }
      }
      CommandGroup(after: .help) {
        Divider()
        MenuButton(title: "Nexus Page", symbol: .gyro) {
          Constants.NexusUrl.openAsURL()
        }
        MenuButton(title: "GitHub Page", symbol: .pull) {
          Constants.GitHubUrl.openAsURL()
        }
        Divider()
        MenuButton(title: "Report Issue", symbol: .newMessage) {
          Constants.ReportIssue.openAsURL()
        }
        MenuButton(title: "Save Session Log...", symbol: .downloadDoc) {
          global.exportSessionLog = true
        }
        Divider()
        MenuButton(title: "Experiencing Issues?", symbol: .help) {
          global.showExperiencingIssuesView = true
        }
      }
    }
  }
  
  init() {
    do {
      let fileManager = FileManager.default
      guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
        fatalError("Application Support directory not found.")
      }
      let storeURL = appSupportURL
        .appendingPathComponent(Constants.ApplicationSupportFolderName)
        .appendingPathComponent(Constants.ApplicationSwiftDataFileName)
      let subfolderURL = storeURL.deletingLastPathComponent()
      if !fileManager.fileExists(atPath: subfolderURL.path) {
        try fileManager.createDirectory(at: subfolderURL, withIntermediateDirectories: true)
      }
      
      let config = ModelConfiguration(url: storeURL)
      container = try ModelContainer(for: ModItem.self, configurations: config)
    } catch {
      fatalError("Failed to configure SwiftData container: \(error)")
    }
#if DEBUG
    Debug.shared.isActive = true
#endif
    UserSettings.setDefaultGameDirectoryPath()
  }
}

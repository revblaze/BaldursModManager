//
//  ContentView+UpdateManager.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/27/24.
//

import Foundation

extension ContentView {
  func checkForUpdatesIfAutomaticUpdatesAreEnabled() {
    Task {
      await updateManager.checkForUpdatesIfNeeded()
      if let currentBuildIsLatestVersion = updateManager.currentBuildIsLatestVersion,
      currentBuildIsLatestVersion == false {
        global.showUpdateView = true
      }
    }
  }
}

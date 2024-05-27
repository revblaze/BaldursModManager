//
//  FilePickerService.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

struct FilePickerService {
  /// Presents an open panel dialog allowing the user to select a directory.
  ///
  /// This function asynchronously displays a file picker dialog configured to allow the selection of directories only. It ensures that the user cannot choose files or multiple directories. If the user selects a directory and confirms, the function returns the path to the selected directory. If the user cancels the dialog or selects an incorrect type, the function returns `nil`.
  ///
  /// - Returns: A `String` representing the path to the selected directory, or `nil` if no directory is selected or the operation is cancelled.
  @MainActor
  static func browseForDirectory() async -> String? {
    return await withCheckedContinuation { continuation in
      let panel = NSOpenPanel()
      panel.allowsMultipleSelection = false
      panel.canChooseDirectories = true
      panel.canCreateDirectories = true
      panel.canChooseFiles = false
      
      panel.begin { response in
        if response == .OK, let url = panel.urls.first {
          continuation.resume(returning: url.path)
        } else {
          continuation.resume(returning: nil)
        }
      }
    }
  }
}

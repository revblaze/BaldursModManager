//
//  FileExtensions.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/27/24.
//

import Foundation

extension URL {
  /// Checks if a directory or file exists at the URL.
  /// - Returns: A Boolean value indicating whether a directory or file exists at the URL.
  func doesExist() -> Bool {
    let path = self.path
    return FileManager.default.fileExists(atPath: path)
  }
}

extension String {
  /// Checks if a directory or file exists at the path represented by the string.
  /// - Returns: A Boolean value indicating whether a directory or file exists at the path.
  func doesExist() -> Bool {
    return FileManager.default.fileExists(atPath: self)
  }
}

extension URL {
  /// Creates a tree-like structure of all the sub-folder names and file names, recursively.
  /// - Returns: A string representing the directory contents in a tree-like structure.
  func logDirectoryContents() -> String {
    return directoryContents(at: self, level: 0)
  }

  /// Helper function to create the directory tree structure.
  /// - Parameters:
  ///   - url: The URL of the directory.
  ///   - level: The current level of recursion, used for indentation.
  /// - Returns: A string representing the directory contents.
  private func directoryContents(at url: URL, level: Int) -> String {
    let fileManager = FileManager.default
    var result = ""
    let indent = String(repeating: "  ", count: level)

    do {
      let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
      for item in contents {
        let isDirectory = item.hasDirectoryPath
        result += "\(indent)\(item.lastPathComponent)\(isDirectory ? "/" : "")\n"
        if isDirectory {
          result += directoryContents(at: item, level: level + 1)
        }
      }
    } catch {
      result += "\(indent)[Error: \(error.localizedDescription)]\n"
    }

    return result
  }
}

extension String {
  /// Creates a tree-like structure of all the sub-folder names and file names, recursively.
  /// - Returns: A string representing the directory contents in a tree-like structure.
  func logDirectoryContents() -> String {
    let url = URL(fileURLWithPath: self)
    return url.logDirectoryContents()
  }
}

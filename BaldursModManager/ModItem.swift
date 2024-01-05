//
//  ModItem.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/5/24.
//

import Foundation
import SwiftData

@Model
class ModItem {
  var order: Int
  var directoryPath: String
  var directoryContents: [String]
  var isEnabled: Bool = false
  var isInstalledInModFolder: Bool = false
  // Mod Metadata Required: [Name, Folder, UUID, MD5]
  var modAuthor: String?
  var modCreatedDate: String?
  var modDescription: String?
  var modFolder: String
  var modGroup: String?
  var modName: String
  var modUuid: String
  var modVersion: String?
  var modMd5: String
  
  init(order: Int, directoryPath: String, directoryContents: [String], name: String, folder: String, uuid: String, md5: String) {
    self.order = order
    self.directoryPath = directoryPath
    self.directoryContents = directoryContents
    self.modName = name
    self.modFolder = folder
    self.modUuid = uuid
    self.modMd5 = md5
  }
}

extension ModItem {
  static var mockData: [ModItem] {
    [
      ModItem(order: 0, directoryPath: "/path/to/mod1", directoryContents: ["file1", "file2"], name: "Mod One", folder: "Folder1", uuid: "UUID1", md5: "MD51"),
      ModItem(order: 1, directoryPath: "/path/to/mod2", directoryContents: ["file3", "file4"], name: "Mod Two", folder: "Folder2", uuid: "UUID2", md5: "MD52"),
      ModItem(order: 2, directoryPath: "/path/to/mod3", directoryContents: ["file5", "file6"], name: "Mod Three", folder: "Folder3", uuid: "UUID3", md5: "MD53")
    ]
  }
}

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


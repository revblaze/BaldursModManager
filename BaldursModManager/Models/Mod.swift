//
//  Mod.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/3/24.
//

import Foundation

struct ModItem: Identifiable {
  let id = UUID()
  var directoryPath: String
  var directoryContents: [String]
  var mods: [Mod]
}

struct Mod: Identifiable, Decodable {
  let id = UUID()
  var author: String?
  var created: String?
  var description: String?
  var folder: String?
  var group: String?
  var name: String?
  var uuid: String?
  var version: String?
  var md5: String?

  enum CodingKeys: String, CodingKey {
    case author = "Author"
    case created = "Created"
    case description = "Description"
    case folder = "Folder"
    case group = "Group"
    case name = "Name"
    case uuid = "UUID"
    case version = "Version"
  }
}

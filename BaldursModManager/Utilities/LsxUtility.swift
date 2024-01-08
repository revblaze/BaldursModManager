//
//  LsxUtility.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import Foundation

class LsxParserDelegate: NSObject, XMLParserDelegate {
  var results = [String: [String: String]]()
  private var currentElementName: String?
  private var currentAttributeId: String?
  private var currentType: String?
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    print("Start Element: \(elementName), Attributes: \(attributeDict)")
    currentElementName = elementName
    if elementName == "attribute" {
      currentAttributeId = attributeDict["id"]
      currentType = attributeDict["type"]
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
    print("Found Characters: \(trimmedString)")
    if !trimmedString.isEmpty, let currentAttributeId = currentAttributeId, let currentType = currentType {
      results[currentAttributeId] = [currentType: trimmedString]
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == "attribute" {
      currentAttributeId = nil
      currentType = nil
    }
  }
  
  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("XML Parsing Error: \(parseError.localizedDescription)")
  }
}

class LsxUtility {
  static func parseFileContents(_ file: URL) -> [String: [String: String]] {
    guard let parser = XMLParser(contentsOf: file) else {
      print("Unable to initialize XMLParser")
      return [:]
    }
    let delegate = LsxParserDelegate()
    parser.delegate = delegate
    if !parser.parse() {
      print("Failed to parse XML")
    }
    return delegate.results
  }
}




struct LsxBuilder {
  
  struct XmlHeaderAttributes {
    
  }
  
  struct LsxDefault {
    static var major = "4"
    static var minor = "4"
    static var revision = "0"
    static var build = "300"
    static var gustavDev = GustavDev()
    
    struct GustavDev {
      
      static var folder = ["LSString": "GustavDev"]
      static var md5 = ""
      static var name = "GustavDev"
      static var uuid = "28ac9ce2-2aba-8cda-b3b5-6e922f71b6b8"
      static var version64 = "36028797018963968"
    }
  }
  
  
  struct LsxDefault {
    static var major = "4"
    static var minor = "4"
    static var revision = "0"
    static var build = "300"
    static var gustavDev = GustavDev(folder: "GustavDev", md5: "", name: "GustavDev", uuid: "28ac9ce2-2aba-8cda-b3b5-6e922f71b6b8", version64: "36028797018963968")
    
    init(major: String, minor: String, revision: String, build: String, gustavDev: GustavDev) {
      LsxBuilder.LsxDefault.major = major
      LsxBuilder.LsxDefault.minor = minor
      LsxBuilder.LsxDefault.revision = revision
      LsxBuilder.LsxDefault.build = build
      LsxBuilder.LsxDefault.gustavDev = gustavDev
    }
    
    struct GustavDev {
      static var folder = "GustavDev"
      static var md5 = ""
      static var name = "GustavDev"
      static var uuid = "28ac9ce2-2aba-8cda-b3b5-6e922f71b6b8"
      static var version64 = "36028797018963968"
      
      init(folder: String, md5: String, name: String, uuid: String, version64: String) {
        LsxBuilder.LsxDefault.GustavDev.folder = folder
        LsxBuilder.LsxDefault.GustavDev.md5 = md5
        LsxBuilder.LsxDefault.GustavDev.name = name
        LsxBuilder.LsxDefault.GustavDev.uuid = uuid
        LsxBuilder.LsxDefault.GustavDev.version64 = version64
      }
    }
  }
  
  
  /* ie.
   ["UUID": "FixedString", "MD5": "LSString", "Version64": "int64", "build": "300", "major": "4", "Folder": "LSString", "id": "Version64", "revision": "0", "minor": "4", "Name": "LSString"]
   */
  
  /*
   static func setLsxDefaultValues(_ dict: [String: String]) {
   var name, folder, uuid, md5: String?
   for (key, value) in dict {
   switch key.lowercased() {
   case "name": name = value
   case "folder": folder = value
   case "uuid": uuid = value
   case "md5": md5 = value
   default: break
   }
   }
   
   
   if let name = name, let folder = folder, let uuid = uuid, let md5 = md5 {
   let newOrderNumber = nextOrderValue()
   withAnimation {
   let newModItem = ModItem(order: newOrderNumber, directoryUrl: directoryURL, directoryPath: directoryURL.path, directoryContents: directoryContents, pakFileString: pakFileString, name: name, folder: folder, uuid: uuid, md5: md5)
   // Check for optional keys
   for (key, value) in infoDict {
   switch key.lowercased() {
   case "author": newModItem.modAuthor = value
   case "description": newModItem.modDescription = value
   case "created": newModItem.modCreatedDate = value
   case "group": newModItem.modGroup = value
   case "version": newModItem.modVersion = value
   default: break
   }
   }
   
   addNewModItem(newModItem, orderNumber: newOrderNumber, fromDirectoryUrl: directoryURL)
   }
   }
   }
   */
  
  static func generate() {
    
  }
  
}

extension FileUtility {
  
  static func backupModSettingsLsxFile() -> URL? {
    let fileManager = FileManager.default
    
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
          let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      Debug.log("Unable to find the Documents or Application Support directory.")
      return nil
    }
    
    let modSettingsLsxFileURL = documentsURL.appendingPathComponent(Constants.defaultModSettingsFileFromDocumentsRelativePath)
    let userBackupsURL = appSupportURL.appendingPathComponent(Constants.ApplicationSupportFolderName).appendingPathComponent(Constants.UserBackupsFolderName)
    
    // Ensure the backup folder exists
    if !fileManager.fileExists(atPath: userBackupsURL.path) {
      do {
        try fileManager.createDirectory(at: userBackupsURL, withIntermediateDirectories: true)
      } catch {
        Debug.log("Failed to create backup folder: \(error.localizedDescription)")
        return nil
      }
    }
    
    // Determine the backup file URL
    var backupFileURL = userBackupsURL.appendingPathComponent(modSettingsLsxFileURL.lastPathComponent)
    if fileManager.fileExists(atPath: backupFileURL.path) {
      let timestamp = formattedCurrentTimestamp()
      backupFileURL = userBackupsURL.appendingPathComponent("\(modSettingsLsxFileURL.deletingPathExtension().lastPathComponent).\(modSettingsLsxFileURL.pathExtension) \(timestamp)")
    }
    
    // Perform the backup
    do {
      try fileManager.copyItem(at: modSettingsLsxFileURL, to: backupFileURL)
      Debug.log("Backup created successfully at \(backupFileURL.path)")
      return backupFileURL
    } catch {
      Debug.log("Failed to backup file: \(error.localizedDescription)")
      return nil
    }
  }
  
  private static func formattedCurrentTimestamp() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let datePart = dateFormatter.string(from: Date())
    
    dateFormatter.dateFormat = "h.mm.ss a"
    let timePart = dateFormatter.string(from: Date())
    
    return "\(datePart) at \(timePart)"
  }
}

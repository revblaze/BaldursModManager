//
//  LsxParserDelegate.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/8/24.
//

import Foundation

class LsxParserDelegate: NSObject, XMLParserDelegate {
  var xmlAttributes: XMLAttributes?
  private var currentElementName: String?
  private var currentAttributeId: String?
  private var currentType: String?
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    currentElementName = elementName
    
    switch elementName {
    case "version":
      let version = XMLAttributes.Version(
        majorString: attributeDict["major"] ?? "",
        minorString: attributeDict["minor"] ?? "",
        revisionString: attributeDict["revision"] ?? "",
        buildString: attributeDict["build"] ?? ""
      )
      xmlAttributes = XMLAttributes(version: version, moduleShortDesc: XMLAttributes.ModuleShortDesc(folder: .init(typeString: "", valueString: ""), md5: .init(typeString: "", valueString: ""), name: .init(typeString: "", valueString: ""), uuid: .init(typeString: "", valueString: ""), version64: .init(typeString: "", valueString: "")))
    case "attribute":
      currentAttributeId = attributeDict["id"]
      currentType = attributeDict["type"]
      if let attributeId = currentAttributeId, let type = currentType, let value = attributeDict["value"] {
        let attribute = XMLAttributes.ModuleShortDesc.Attribute(typeString: type, valueString: value)
        switch attributeId {
        case "Folder":
          xmlAttributes?.moduleShortDesc.folder = attribute
        case "MD5":
          xmlAttributes?.moduleShortDesc.md5 = attribute
        case "Name":
          xmlAttributes?.moduleShortDesc.name = attribute
        case "UUID":
          xmlAttributes?.moduleShortDesc.uuid = attribute
        case "Version64":
          xmlAttributes?.moduleShortDesc.version64 = attribute
        default:
          break
        }
      }
    default:
      break
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == "attribute" {
      currentAttributeId = nil
      currentType = nil
    }
  }
  
  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    Debug.log("XML Parsing Error: \(parseError.localizedDescription)")
  }
}

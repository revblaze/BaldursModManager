//
//  LsxUtility.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import Foundation

class LsxUtility {
  static func parseFileContents(_ file: URL) -> XMLAttributes? {
    guard let parser = XMLParser(contentsOf: file) else {
      Debug.log("Unable to initialize XMLParser")
      return nil
    }
    let delegate = LsxParserDelegate()
    parser.delegate = delegate
    if !parser.parse() {
      Debug.log("Failed to parse XML")
      return nil
    }
    return delegate.xmlAttributes
  }
}


struct LsxUtilityTest {
  
  static func testXmlGenerationFromModSettingsLsxBackup() {
    if let modsettingsLsxFile = FileUtility.backupModSettingsLsxFile() {
      if let xmlAttrs = LsxUtility.parseFileContents(modsettingsLsxFile) {
        testTypeSafeModSettingsLsxFile(xmlAttributes: xmlAttrs)
        testTypeSafeGustavDevFromMultipleModuleShortDescsTest(xmlAttributes: xmlAttrs)
      }
    }
  }
  
  static func testTypeSafeModSettingsLsxFile(xmlAttributes xmlAttrs: XMLAttributes) {
    let majorVersion = xmlAttrs.version.majorString
    let minorVersion = xmlAttrs.version.minorString
    let revisionVersion = xmlAttrs.version.revisionString
    let buildVersion = xmlAttrs.version.buildString
    
    Debug.log("XML attributes assigned; testing XML version header:")
    
    let versionXmlString = """
            <version major="\(majorVersion)" minor="\(minorVersion)" revision="\(revisionVersion)" build="\(buildVersion)"/>
            """
    Debug.log(versionXmlString)
  }
  
  static func testTypeSafeGustavDevFromMultipleModuleShortDescsTest(xmlAttributes xmlAttrs: XMLAttributes) {
    Debug.log("Found GustavDev entry; test XML generation:")
    let gustavDevModule = xmlAttrs.moduleShortDesc
    let gustavDevGeneratedAttributes = """
          <attribute id="Folder" type="\(gustavDevModule.folder.typeString)" value="\(gustavDevModule.folder.valueString)"/>
          <attribute id="MD5" type="\(gustavDevModule.md5.typeString)" value="\(gustavDevModule.md5.valueString)"/>
          <attribute id="Name" type="\(gustavDevModule.name.typeString)" value="\(gustavDevModule.name.valueString)"/>
          <attribute id="UUID" type="\(gustavDevModule.uuid.typeString)" value="\(gustavDevModule.uuid.valueString)"/>
          <attribute id="Version64" type="\(gustavDevModule.version64.typeString)" value="\(gustavDevModule.version64.valueString)"/>
          """
    Debug.log(gustavDevGeneratedAttributes)
  }
}

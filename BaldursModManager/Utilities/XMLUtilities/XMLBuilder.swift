//
//  XMLBuilder.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/8/24.
//

import Foundation

class XMLBuilder {
  var xmlAttributes: XMLAttributes
  var modItems: [ModItem]
  
  init(xmlAttributes: XMLAttributes, modItems: [ModItem]) {
    self.xmlAttributes = xmlAttributes
    self.modItems = modItems
  }
  
  func buildXMLString() -> String {
    let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <save>
          \(buildVersionString())
          <region id="ModuleSettings">
            <node id="root">
              <children>
                <node id="ModOrder">
                  <children>
        \(buildGustavDevHeaderUUIDString(moduleShortDesc: xmlAttributes.moduleShortDesc))
        \(buildModOrderString())
                  </children>
                </node>
                <node id="Mods">
                  <children>
        \(buildModuleShortDescString(moduleShortDesc: xmlAttributes.moduleShortDesc))
        \(buildModItemsString())
                  </children>
                </node>
              </children>
            </node>
          </region>
        </save>
        """
    
    return xmlString
  }
  
  private func buildVersionString() -> String {
    let version = xmlAttributes.version
    return "<version major=\"\(version.majorString)\" minor=\"\(version.minorString)\" revision=\"\(version.revisionString)\" build=\"\(version.buildString)\" />"
  }
  
  private func buildModOrderString() -> String {
    modItems.map { modItem in
      "            <node id=\"Module\">\n              <attribute id=\"UUID\" type=\"FixedString\" value=\"\(modItem.modUuid)\" />\n            </node>"
    }.joined(separator: "\n")
  }
  
  private func buildGustavDevHeaderUUIDString(moduleShortDesc: XMLAttributes.ModuleShortDesc) -> String {
    "            <node id=\"Module\">\n              <attribute id=\"UUID\" type=\"FixedString\" value=\"\(moduleShortDesc.uuid.valueString)\" />\n            </node>"
  }
  
  private func buildModItemsString() -> String {
    modItems.map { modItem in
"""
            <node id="ModuleShortDesc">
              <attribute id="Folder" type="LSString" value="\(modItem.modFolder ?? "")" />
              <attribute id="Name" type="LSString" value="\(modItem.modName)" />
              <attribute id="UUID" type="FixedString" value="\(modItem.modUuid)" />
              <attribute id="Version64" type="int64" value="" />
            </node>
"""
    }.joined(separator: "\n")
  }
  
  private func buildModuleShortDescString(moduleShortDesc: XMLAttributes.ModuleShortDesc) -> String {
"""
            <node id="ModuleShortDesc">
              <attribute id="Folder" type="LSString" value="\(moduleShortDesc.folder.valueString)" />
              <attribute id="MD5" type="LSString" value="\(moduleShortDesc.md5.valueString)" />
              <attribute id="Name" type="LSString" value="\(moduleShortDesc.name.valueString)" />
              <attribute id="UUID" type="FixedString" value="\(moduleShortDesc.uuid.valueString)" />
              <attribute id="Version64" type="int64" value="\(moduleShortDesc.version64.valueString.forceStringValueAsInt)" />
            </node>
"""
  }
}

extension String {
  var forceStringValueAsInt: String {
    if let intValue = Int(self) {
      return String(intValue)
    } else if let floatValue = Float(self) {
      return String(Int(floatValue))
    } else {
      return ""
    }
  }
}

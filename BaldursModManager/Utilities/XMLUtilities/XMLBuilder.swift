//
//  XMLBuilder.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/8/24.
//

import Foundation

/// A class that builds an XML string from given XML attributes and a list of mod items.
class XMLBuilder {
  /// The parsed XML attributes used for building the XML string.
  var xmlAttributes: XMLAttributes
  /// The list of mod items to be included in the XML string.
  var modItems: [ModItem]
  /// Initializes a new XMLBuilder with given XML attributes and mod items.
  ///
  /// - Parameters:
  ///   - xmlAttributes: The XML attributes to be included in the XML string.
  ///   - modItems: The list of mod items to be included in the XML string.
  init(xmlAttributes: XMLAttributes, modItems: [ModItem]) {
    self.xmlAttributes = xmlAttributes
    self.modItems = modItems
  }
  /// Builds and returns an XML string.
  ///
  /// - Returns: A string representing the XML content.
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
  /// Builds the version string for the XML.
  ///
  /// - Returns: A string representing the version XML element.
  private func buildVersionString() -> String {
    let version = xmlAttributes.version
    return "<version major=\"\(version.majorString)\" minor=\"\(version.minorString)\" revision=\"\(version.revisionString)\" build=\"\(version.buildString)\" />"
  }
  /// Builds the mod order string for the XML.
  ///
  /// - Returns: A string representing the mod order XML elements.
  private func buildModOrderString() -> String {
    modItems.map { modItem in
      "            <node id=\"Module\">\n              <attribute id=\"UUID\" type=\"FixedString\" value=\"\(modItem.modUuid)\" />\n            </node>"
    }.joined(separator: "\n")
  }
  /// Builds the GustavDev header UUID string for the XML.
  ///
  /// - Parameter moduleShortDesc: The module short description to be used.
  /// - Returns: A string representing the GustavDev header UUID XML element.
  private func buildGustavDevHeaderUUIDString(moduleShortDesc: XMLAttributes.ModuleShortDesc) -> String {
    "            <node id=\"Module\">\n              <attribute id=\"UUID\" type=\"FixedString\" value=\"\(moduleShortDesc.uuid.valueString)\" />\n            </node>"
  }
  /// Builds the mod items string for the XML.
  ///
  /// - Returns: A string representing the mod items XML elements.
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
  /// Builds the module short description string for the XML.
  ///
  /// - Parameter moduleShortDesc: The `ModuleShortDesc` object containing module details.
  /// - Returns: A string representing a `ModuleShortDesc` node for the XML.
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
  /// A computed property that attempts to convert the string to an integer. If the string is a valid integer or floating-point number, it is converted to an integer and returned as a string. Otherwise, it returns an empty string.
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

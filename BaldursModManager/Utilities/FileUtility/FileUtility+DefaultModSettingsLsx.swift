//
//  FileUtility+DefaultModSettingsLsx.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/8/24.
//

import Foundation

extension FileUtility {
  
  /// Returns the default contents for the modsettings.lsx file.
  ///
  /// - Returns: A string containing the default XML contents for the mod settings.
  static func getDefaultModSettingsLsxContents() -> String {
"""
<?xml version="1.0" encoding="UTF-8"?>
<save>
    <version major="4" minor="4" revision="0" build="300"/>
    <region id="ModuleSettings">
        <node id="root">
            <children>
                <node id="ModOrder"/>
                <node id="Mods">
                    <children>
                        <node id="ModuleShortDesc">
                            <attribute id="Folder" type="LSString" value="GustavDev"/>
                            <attribute id="MD5" type="LSString" value=""/>
                            <attribute id="Name" type="LSString" value="GustavDev"/>
                            <attribute id="UUID" type="FixedString" value="28ac9ce2-2aba-8cda-b3b5-6e922f71b6b8"/>
                            <attribute id="Version64" type="int64" value="36028797018963968"/>
                        </node>
                    </children>
                </node>
            </children>
        </node>
    </region>
</save>
"""
  }
  
}

//
//  XMLAttributes.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/8/24.
//

import Foundation

struct XMLAttributes {
  var version: Version
  var moduleShortDesc: ModuleShortDesc
  
  struct Version {
    var majorString: String
    var minorString: String
    var revisionString: String
    var buildString: String
  }
  
  struct ModuleShortDesc {
    var folder: Attribute
    var md5: Attribute
    var name: Attribute
    var uuid: Attribute
    var version64: Attribute
    
    struct Attribute {
      var typeString: String
      var valueString: String
    }
  }
}

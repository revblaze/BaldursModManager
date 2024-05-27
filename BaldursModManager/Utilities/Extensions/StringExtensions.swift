//
//  StringExtensions.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import SwiftUI

extension String {
  func openAsURL() {
    if let url = URL(string: self) {
      NSWorkspace.shared.open(url)
    }
  }
  
  func cleanUserPaths() -> String {
    let pattern = "/Users/[^/]+/"
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: [])
      let range = NSRange(location: 0, length: self.utf16.count)
      let cleanString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "/Users/{USER}/")
      return cleanString
    } catch let error {
      Debug.log("Regex error: \(error.localizedDescription)")
      return self
    }
  }
  
  func appendingDateAndTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let datePart = dateFormatter.string(from: Date())
    
    dateFormatter.dateFormat = "h.mm.ss a"
    let timePart = dateFormatter.string(from: Date())
    
    return self + " \(datePart) at \(timePart)"
  }
  
}

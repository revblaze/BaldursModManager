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
}

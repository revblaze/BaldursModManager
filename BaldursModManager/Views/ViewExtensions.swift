//
//  ViewExtensions.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import SwiftUI

extension View {
  func monoStyle() -> some View {
    self.font(.system(.body, design: .monospaced))
  }
}

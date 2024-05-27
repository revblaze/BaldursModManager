//
//  GlobalEnvironment.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import SwiftUI
import Observation

@Observable
class Global {
  var showSettingsView: Bool = false
  var showWhatsNewView: Bool = false
  var showImportModPanel: Bool = false
}

struct GlobalKey: EnvironmentKey {
  static let defaultValue: Global = Global()
}

extension EnvironmentValues {
  var global: Global {
    get { self[GlobalKey.self] }
    set { self[GlobalKey.self] = newValue }
  }
}

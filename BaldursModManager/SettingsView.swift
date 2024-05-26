//
//  SettingsView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import SwiftUI

struct SettingsView: View {
  @Binding var isPresented: Bool
  @State private var enableMods = UserSettings.shared.enableMods
  @State private var saveModsAutomatically = UserSettings.shared.saveModsAutomatically
  @State private var enableModOnImport = UserSettings.shared.saveModsAutomatically
  @State private var makeCopyOfModFolderOnImport = UserSettings.shared.makeCopyOfModFolderOnImport
  
  var body: some View {
    VStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text("Settings")
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .padding()
          ToggleWithHeader(isToggled: $enableMods, header: "Enable Mods", description: "When disabled, the ModSettings.lsx file will be replaced with the no-mod setup. All mods will be deactived in Baldur's Gate 3.", showAllDescriptions: true)
          ToggleWithHeader(isToggled: $saveModsAutomatically, header: "Automatically Save Mods", description: "All mod management operations are handled for you. Disabling this option will revert to the legacy app setup where saving mod files must be done manually.", showAllDescriptions: true)
            .disabled(!enableMods)
          ToggleWithHeader(isToggled: $enableMods, header: "Enable Mods on Import", description: "When a mod is imported into BaldursModManager, automatically install it and add it to the ModSettings.lsx file for me.", showAllDescriptions: true)
            .disabled(!enableMods)
          ToggleWithHeader(isToggled: $makeCopyOfModFolderOnImport, header: "Copy Mod Folder on Import", description: "When a mod folder is imported, a copy will be made of the original folder. If this is disabled, BaldursModManager will import the original folder instead.", showAllDescriptions: true)
            .disabled(!enableMods)
        }
        .padding(20)
      }
      VStack {
        HStack {
          OutlineButton(title: "Restore Defaults") {
            UserSettings.shared.restoreDefaults()
          }
          Spacer()
          BlueButton(title: "Done") {
            saveSettings()
            isPresented = false
          }
        }
        .padding(10)
      }
      .background(Color(NSColor.windowBackgroundColor))
    }
    .navigationTitle("Settings")
  }
  
  func saveSettings() {
    UserSettings.shared.enableMods = enableMods
    UserSettings.shared.saveModsAutomatically = saveModsAutomatically
    UserSettings.shared.makeCopyOfModFolderOnImport = makeCopyOfModFolderOnImport
  }
}


#Preview {
  SettingsView(isPresented: .constant(true))
    .frame(width: 600)
}

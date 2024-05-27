//
//  SettingsView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import SwiftUI

struct SettingsView: View {
  @Binding var isPresented: Bool
  @State private var userSettings = UserSettings.shared
  
  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text("Settings")
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .padding()
          ToggleWithHeader(isToggled: $userSettings.enableMods, header: "Enable Mods", description: "When disabled, the ModSettings.lsx file will be replaced with the no-mod setup. All mods will be deactived in Baldur's Gate 3.", showAllDescriptions: true)
          ToggleWithHeader(isToggled: $userSettings.saveModsAutomatically, header: "Automatically Save Mods", description: "All mod management operations are handled for you. Disabling this option will revert to the legacy app setup where saving mod files must be done manually.", showAllDescriptions: true)
            .disabled(!userSettings.enableMods)
          ToggleWithHeader(isToggled: $userSettings.enableModOnImport, header: "Enable Mods on Import", description: "When a mod is imported into BaldursModManager, automatically install it and add it to the ModSettings.lsx file for me.", showAllDescriptions: true)
            .disabled(!userSettings.enableMods)
          ToggleWithHeader(isToggled: $userSettings.makeCopyOfModFolderOnImport, header: "Copy Mod Folder on Import", description: "When a mod folder is imported, a copy will be made of the original folder. If this is disabled, BaldursModManager will import the original folder instead.", showAllDescriptions: true)
            .disabled(!userSettings.enableMods)
          
          Divider()
            .padding(.horizontal, 20)
          
          BrowseBaseGameDirectoryRow()
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
            isPresented = false
          }
        }
        .padding(10)
      }
      .background(Color(NSColor.windowBackgroundColor))
    }
    .navigationTitle("Settings")
  }
}


#Preview {
  SettingsView(isPresented: .constant(true))
    .frame(width: 600, height: 700)
}

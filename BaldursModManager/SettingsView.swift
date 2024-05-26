//
//  SettingsView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import SwiftUI

struct SettingsView: View {
  @Binding var isPresented: Bool
  @State private var makeCopyOfModFolderOnImport = UserSettings.shared.makeCopyOfModFolderOnImport
  @State private var enableMods = UserSettings.shared.enableMods
  @State private var saveModsAutomatically = UserSettings.shared.saveModsAutomatically
  
  var body: some View {
    VStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text("Settings")
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .padding()
          ToggleWithHeader(isToggled: $enableMods, header: "Enable Mods", description: "Enable or disable mods. When enabled, mods will be activated within the game.", showAllDescriptions: true)
          ToggleWithHeader(isToggled: $saveModsAutomatically, header: "Automatically Save Mods", description: "Save your mods automatically to prevent data loss. Ensures that changes are not lost when the application closes unexpectedly.", showAllDescriptions: true)
          ToggleWithHeader(isToggled: $makeCopyOfModFolderOnImport, header: "Copy Mod Folder on Import", description: "Create a backup copy of the mod folder upon import to safeguard your original mod files.", showAllDescriptions: true)
        }
        .padding(20)
      }
      VStack {
        HStack {
          OutlineButton(title: "Restore Defaults") {
            userSettings.restoreDefaults()
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
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Dismiss") {
          UserSettings.shared.enableMods = enableMods
          UserSettings.shared.saveModsAutomatically = saveModsAutomatically
          UserSettings.shared.makeCopyOfModFolderOnImport = makeCopyOfModFolderOnImport
          isPresented = false
        }
      }
    }
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

struct ToggleWithHeader: View {
  @Binding var isToggled: Bool
  var header: String
  var description: String = ""
  var showAllDescriptions: Bool

  var body: some View {
    HStack(alignment: .top) {
      Toggle("", isOn: $isToggled)
        .toggleStyle(SwitchToggleStyle(tint: .blue))
        .frame(width: 60)
        .padding(.trailing, 6)

      VStack(alignment: .leading, spacing: 2) {
        Text(header)
          .font(.system(size: 14, weight: .semibold, design: .default))
          .underline()
          .padding(.bottom, 2) // Adjust padding to better align the header with the toggle

        if showAllDescriptions {
          Text(description)
            .font(.system(size: 12))
            .foregroundStyle(Color.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .layoutPriority(1) // Ensures that this VStack doesn't get squeezed unnecessarily

      Spacer()
    }
    .padding(.bottom, 8)
  }
}

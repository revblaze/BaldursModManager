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
    .frame(width: 600)
}

struct BrowseBaseGameDirectoryRow: View {
  @State private var userSettings = UserSettings.shared
  var body: some View {
    VStack(alignment: .leading) {
      BrowseRequiredFileRow(labelText: "Base Game Directory",
                            placeholderText: "/Users/me/Documents/Larian Studios/Baldur's Gate 3",
                            textValue: $userSettings.baldursGateDirectory,
                            requiresEntry: true
      ){
        await FilePickerService.browseForDirectory()
      }
      .onChange(of: userSettings.baldursGateDirectory) {
        //userSettings.setDefaultPathsForEmptySettings()
      }
      .padding(.horizontal, 20)
      Text("Make sure the base game directory is properly set. It should look something like this:")
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
      Text("/Users/me/Documents/Larian Studios/Baldur's Gate 3")
        .monoStyle()
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
    }
  }
}

struct BrowseRequiredFileRow: View {
  var labelText: String?
  var placeholderText: String
  @Binding var textValue: String
  var requiresEntry: Bool = false
  var browseAction: () async -> String?
  
  @State private var indicatorType: IndicatorType = .none
  
  private enum IndicatorType {
    case checkmark, xmark, none
    
    var imageName: String {
      switch self {
      case .checkmark:
        return "checkmark.circle.fill"
      case .xmark:
        return "xmark.circle.fill"
      case .none:
        return "square.dashed"
      }
    }
    
    var imageColor: Color {
      switch self {
      case .checkmark:
        return .green
      case .xmark:
        return .red
      case .none:
        return .clear
      }
    }
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        if requiresEntry {
          Image(systemName: indicatorType.imageName)
            .foregroundColor(indicatorType.imageColor)
            .padding(.bottom, 2)
        }
        
        if let label = labelText {
          Text(label)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .padding(.bottom, 5)
        }
      }
      
      HStack {
        TextField(placeholderText, text: $textValue)
          .truncationMode(.middle)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .font(.system(size: 11, design: .monospaced))
          .disabled(true)
        Button("Browse...") {
          Task {
            if let path = await browseAction() {
              textValue = path
            }
          }
        }
      }
      .padding(.bottom, 14)
    }
    .onChange(of: textValue) {
      updateIndicator(for: textValue)
    }
    .onAppear {
      updateIndicator(for: textValue)
    }
  }
  
  private func updateIndicator(for value: String) {
    if requiresEntry {
        if FileManager.default.fileExists(atPath: value) {
          indicatorType = .checkmark
        } else {
          indicatorType = .xmark
        }
      } else {
        indicatorType = .none
      }
  }
}

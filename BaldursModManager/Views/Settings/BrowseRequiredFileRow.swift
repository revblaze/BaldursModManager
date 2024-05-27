//
//  BrowseRequiredFileRow.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import SwiftUI

struct BrowseRequiredFileRow: View {
  var labelText: String?
  var placeholderText: String
  @Binding var textValue: String
  var requiresEntry: Bool = false
  var browseAction: () async -> String?
  
  @State private var indicatorType: IndicatorType = .none
  @State private var modsExists: Bool = false
  @State private var modSettingsExists: Bool = false
  
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
              updateIndicator(for: path)
            }
          }
        }
      }
      .padding(.bottom, 14)
      
      if requiresEntry {
        VStack(alignment: .leading, spacing: 6) {
          HStack {
            Image(systemName: modsExists ? "checkmark.circle.fill" : "xmark.circle.fill")
              .foregroundColor(modsExists ? .green : .red)
            Text(modsExists ? "Valid Mods directory found" : "Unable to locate Mods directory")
          }
          HStack {
            Image(systemName: modSettingsExists ? "checkmark.circle.fill" : "xmark.circle.fill")
              .foregroundColor(modSettingsExists ? .green : .red)
            Text(modSettingsExists ? "Valid modsettings.lsx file found" : "Unable to locate modsettings.lsx")
          }
        }
        .padding(.horizontal, 20)
        .fontDesign(.rounded)
        
        Divider().padding(.vertical)
      }
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
      let modsPath = "\(value)/\(Constants.relativeModsFolderPath)"
      let modSettingsPath = "\(value)/\(Constants.relativeModSettingsFilePath)"
      
      modsExists = FileManager.default.fileExists(atPath: modsPath)
      modSettingsExists = FileManager.default.fileExists(atPath: modSettingsPath)
      
      if modsExists && modSettingsExists {
        indicatorType = .checkmark
        textValue = value
        UserSettings.shared.baldursGateDirectory = value
      } else {
        indicatorType = .xmark
      }
    } else {
      indicatorType = .none
    }
  }
}

#Preview {
  BrowseBaseGameDirectoryRow()
    .padding()
}

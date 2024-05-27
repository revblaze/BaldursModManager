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
      let modsPath = "\(value)/\(Constants.relativeModsFolderPath)"
      let modSettingsPath = "\(value)/\(Constants.relativeModSettingsFilePath)"
      
      let modsExists = FileManager.default.fileExists(atPath: modsPath)
      let modSettingsExists = FileManager.default.fileExists(atPath: modSettingsPath)
      
      if modsExists && modSettingsExists {
        indicatorType = .checkmark
      } else {
        indicatorType = .xmark
      }
    } else {
      indicatorType = .none
    }
  }
  
}


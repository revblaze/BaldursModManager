//
//  PermissionsView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct PermissionsView: View {
  @State private var modSettingsPath: String = "Select file"
  @State private var modsFolderPath: String = "Select folder"
  @State private var showAlert = false
  var onDismiss: (() -> Void)?
  
  var body: some View {
    VStack {
      Text("Select Baldur's Gate 3 Paths")
        .font(.headline)
        .padding()
      Text("Browse to locate the following Baldur's Gate 3 files and folders. These are usually located in:")
        .lineLimit(4)
        .padding(.horizontal, 40)
      
      Text("~/Documents/Larian Studios/Baldur's Gate 3/").monoStyle()
        .padding(.top, 10)
      
      Divider()
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
      
      HStack {
        
        VStack {
          HStack {
            Text("modsettings.lsx").monoStyle().bold().underline()
            Spacer()
          }
          HStack {
            Text(modSettingsPath).monoStyle()
              .lineLimit(4)
              .truncationMode(.middle)
            Spacer()
            Button("Browse...") {
              browseForModSettingsFile()
            }
            Image(systemName: modSettingsPath != "Select file" ? "checkmark.circle.fill" : "circle")
          }
          
          HStack {
            Text("Mods/ folder").monoStyle().bold().underline()
            Spacer()
          }
          .padding(.top, 10)
          HStack {
            Text(modsFolderPath).monoStyle()
              .lineLimit(4)
              .truncationMode(.middle)
            Spacer()
            Button("Browse...") {
              browseForModsFolder()
            }
            Image(systemName: modsFolderPath != "Select folder" ? "checkmark.circle.fill" : "circle")
          }
        }
      }
      .padding(.horizontal, 40)
      
      Divider()
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
      
      HStack {
        
        Button("Cancel") {
          // Cancel
          onDismiss?()
        }
        
        Spacer()
        
        Button("Save Settings") {
          // Save settings
          onDismiss?()
        }
        .disabled(modSettingsPath == "Select file" || modsFolderPath == "Select folder") // Enable only if both paths are selected
        
      }
      .padding(.horizontal, 40)
      .padding(.bottom, 20)
    }
    .frame(width: 500)
    .cornerRadius(10)
    .shadow(radius: 5)
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Invalid File"),
        message: Text("Please select a file named 'modsettings.lsx'"),
        primaryButton: .default(Text("Try Again"), action: browseForModSettingsFile),
        secondaryButton: .cancel()
      )
    }
  }
  
  private func browseForModSettingsFile() {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    openPanel.allowsMultipleSelection = false
    openPanel.allowedContentTypes = [UTType(filenameExtension: "lsx") ?? .data]
    
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    openPanel.directoryURL = documentsURL
    
    if openPanel.runModal() == .OK {
      let selectedPath = openPanel.url?.path
      if let selectedPath = selectedPath, selectedPath.hasSuffix("modsettings.lsx") {
        modSettingsPath = selectedPath
      } else {
        showAlert = true
      }
    }
  }
  
  private func browseForModsFolder() {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    if openPanel.runModal() == .OK {
      let selectedPath = openPanel.url?.path
      if let selectedPath = selectedPath, selectedPath.hasSuffix("Mods") {
        modsFolderPath = selectedPath
      }
    }
  }
}

#Preview {
  PermissionsView()
}

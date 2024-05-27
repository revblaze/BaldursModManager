//
//  WelcomeDetailView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/8/24.
//

import SwiftUI

struct WelcomeDetailView: View {
  @Environment(\.global) var global
  var appVersion: String? {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  }
  
  var body: some View {
    VStack {
      Spacer()
      HStack {
        Image("red-tiefling")
          .resizable()
          .frame(width: 120, height: 120)
        
        VStack(alignment: .leading) {
          Text("BaldursModManager")
            .font(.title)
          Text("Aw, was that Gale's granddad?")
            .italic().font(.subheadline)
            .padding(.bottom, 2)
          if let appVersion = appVersion {
            Text("v\(appVersion)")
              .monoStyle()
          }
          OutlineButton(title: "􀆿 What's New?") {
            global.showWhatsNewView = true
          }
        }
      }
      
      Spacer()
      
      Text("For now, this app only accepts folders that contain an info.json and .pak file")
        .lineLimit(2)
        .font(.footnote)
      
      Divider()
        .padding()
        .padding(.horizontal, 40)
      
      if UserSettings.shared.saveModsAutomatically {
        AppInstructions()
      } else {
        LegacyInstructions()
      }
      
      Spacer()
      
      HStack {
        Text("Click the")
        Image(systemName: "ellipsis.circle")
        Text("toolbar button for more actions.")
      }
      .font(.subheadline)
    }
    .padding()
  }
}

#Preview {
  WelcomeDetailView()
    .frame(width: 500, height: 450)
}

struct AppInstructions: View {
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("1. Import mods using the")
        Image(systemName: "plus")
        Text("button or shortcut")
        Image(systemName: "command")
        Text(",")
      }
      .padding(.vertical, 2)
      HStack {
        Text("2. Enable")
        Image(systemName: "checkmark.circle.fill")
        Text("the mods you wish to use in your game")
      }
      .padding(.vertical, 4)
    }
    
    Divider()
      .padding()
      .padding(.horizontal, 40)
    
    HStack {
      Text("More options are available in")
      Image(systemName: "gear")
      Text("Settings")
    }
  }
}


struct LegacyInstructions: View {
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("1. Import mods using the")
        Image(systemName: "plus")
        Text("button or shortcut")
        Image(systemName: "command")
        Text(",")
      }
      .padding(.vertical, 2)
      HStack {
        Text("2. Enable")
        Image(systemName: "checkmark.circle.fill")
        Text("mods you wish to add to your load order")
      }
      .padding(.vertical, 4)
      HStack {
        Text("3. Click Sync")
        Image(systemName: "arrow.triangle.2.circlepath")
        Text("to add those mods to modsettings.lsx")
          .padding(.vertical, 4)
      }
    }
    
    Divider()
      .padding()
      .padding(.horizontal, 40)
    
    HStack {
      Text("Click Restore")
      Image(systemName: "gobackward")
      Text("to revert the changes made")
    }
  }
}

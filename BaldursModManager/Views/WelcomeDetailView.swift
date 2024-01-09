//
//  WelcomeDetailView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/8/24.
//

import SwiftUI

struct WelcomeDetailView: View {
  var appVersion: String? {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  }
  
  var body: some View {
    VStack {
      Spacer()
      
      if let appVersion = appVersion {
        Text("Welcome to BaldursModManager v\(appVersion)")
      } else {
        Text("Welcome to BaldursModManager")
      }
      
      Text("It's a working title!").italic().font(.subheadline)
        .padding(2)
      
      Spacer()
      
      Text("For now, this app only accepts folders that contain an info.json and .pak file")
        .lineLimit(2)
        .font(.footnote)
      
      Divider()
        .padding()
        .padding(.horizontal, 40)
      
      VStack(alignment: .leading) {
        HStack {
          Text("1. Select a mod folder to import using the add")
          Image(systemName: "plus")
          Text("button")
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
      
      Spacer()
      
      HStack {
        Text("Click the eye")
        Image(systemName: "eye")
        Text("to preview your modsettings.lsx file")
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

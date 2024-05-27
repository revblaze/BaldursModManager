//
//  ExperiencingIssuesView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/27/24.
//

import SwiftUI

struct ExperiencingIssuesView: View {
  @Binding var isPresented: Bool
  @State private var userSettings = UserSettings.shared
  
  var body: some View {
    ZStack {
      VStack {
        ScrollView {
          VStack(alignment: .leading) {
            HStack {
              Spacer()
              ReportingIssueSteps()
              Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal, 20)
          }
        }
        
        HStack {
          Spacer()
          
          BlueButton(title: "Dismiss") {
            isPresented = false
          }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
      }
      
      VStack {
        HStack {
          SymbolButton(symbol: .closeFullscreen) {
            isPresented = false
          }
          .frame(width: 20, height: 20)
          Spacer()
        }
        .padding()
        Spacer()
      }
    }
  }
}

#Preview {
  ExperiencingIssuesView(isPresented: .constant(true))
    .frame(width: 600, height: 550)
}

struct ReportingIssueSteps: View {
  @Environment(\.global) var global
  var body: some View {
    VStack(alignment: .center) {
      Text("Experiencing Issues?")
        .font(.system(size: 20, weight: .semibold, design: .rounded))
        .padding(.bottom, 8)
      
      Text("Let's try and get them resolved!")
        .padding(.bottom, 20)
      
      VStack(alignment: .leading) {
        StepListItem(step: "1", text: "Start by generating a session log and saving it some place you'll remember:")
        HStack {
          Spacer()
          MenuButton(title: "Save Session Log...") {
            global.exportSessionLog = true
          }
          Spacer()
        }
        StepListItem(step: "2", text: "Create a new bug report on Nexus or open an issue report on GitHub:")
          .padding(.top)
        HStack {
          Spacer()
          MenuButton(title: "Nexus Bugs Page") {
            "https://www.nexusmods.com/baldursgate3/mods/5848?tab=bugs".openAsURL()
          }
          MenuButton(title: "GitHub Issues Page") {
            "https://github.com/revblaze/BaldursModManager/issues".openAsURL()
          }
          Spacer()
        }
        HStack {
          Spacer()
          Text("GitHub is preffered since you can upload the session log file directly.")
            .font(.subheadline)
            .padding(.vertical, 4)
          Spacer()
        }
        StepListItem(step: "3", text: "Describe your issue in detail, as well as any additional information that you think might help (when did this start occuring, did you recently add any new mods or update older mods, ...)")
          .padding(.top)
        StepListItem(step: "4", text: "(Optional) If you're creating an issue on GitHub, include the session log file. If you're reporting a bug on Nexus, you can open the session log file in TextEdit and copy as much of the log as possible to the end of your report.")
          .padding(.top)
      }
    }
    .padding(.horizontal, 10)
  }
}

struct StepListItem: View {
  let step: String
  let text: String
  
  var body: some View {
    HStack {
      CircleStep(step: step)
      Text(text)
        .font(.system(size: 14, weight: .semibold, design: .rounded))
    }
    .padding(.vertical, 4)
  }
}

struct CircleStep: View {
  var step: String
  
  var body: some View {
    Text(step)
      .textCase(.lowercase)
      .foregroundColor(.white)
      .font(.system(size: 12, weight: .semibold, design: .monospaced))
      .padding(6)
      .background(
        Circle()
          .fill(Color.blue)
      )
  }
}

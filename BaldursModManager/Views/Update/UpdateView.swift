//
//  UpdateView.swift
//  SwiftDiffusion
//
//  Created by Justin Bush on 2/12/24.
//

import SwiftUI

struct AppInfo {
  static var version: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
  }
  static var buildString: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
  }
  static var buildInt: Int {
    Int(buildString) ?? 0
  }
  static var versionAndBuild: String {
    "v\(version) (\(buildString))"
  }
}

struct UpdateView: View {
  @Environment(\.updateManager) var updateManager
  @Binding var isPresented: Bool
  @State private var showUpdateFrequencySection: Bool = false
  private let updateFrequencySectionHeight: CGFloat = 28
  private let initialFrameHeight: CGFloat = 280
  var expandedFrameHeight: CGFloat {
    initialFrameHeight + updateFrequencySectionHeight
  }
  
  @State var updateViewState: UpdateViewState = .defaultState
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        VStack {
          Spacer().frame(height: 30) // Placeholder for top HStack

          ToggleWithLabel(isToggled: .constant(true), header: "Automatically check for new updates", description: "Checks if new releases are available", showAllDescriptions: true)
            .padding(.top, 10)
          
          if showUpdateFrequencySection {
            VStack {
              Menu {
                ForEach(UpdateFrequency.allCases, id: \.self) { frequency in
                  Button(frequency.rawValue) {
                    updateManager.updateCheckFrequency = frequency
                    updateManager.saveSettings()
                  }
                }
              } label: {
                Label("Check " + updateManager.updateCheckFrequency.rawValue, systemImage: "calendar")
              }
            }
            .frame(width: 250, height: updateFrequencySectionHeight)
            .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)))
          }
          
          Spacer()
          
          HStack(alignment: .center) {
            VStack {
              if updateViewState == .checkingForUpdate {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle())
                  .scaleEffect(0.5)
                  .opacity(updateViewState == .checkingForUpdate ? 1 : 0)
              } else {
                Image(systemName: updateViewState.symbol)
                  .foregroundStyle(updateViewState.symbolColor)
                  .font(.system(size: 18))
              }
            }
            .frame(width: 24, height: 24)
            .padding(.trailing, 2)
            

            VStack(alignment: .leading) {
              Text(updateViewState.statusText)
                .bold()
                .padding(.bottom, 1)
              Text("BaldursModManager \(AppInfo.versionAndBuild)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            }
          }
          
          Spacer()
          
          HStack {
            if updateViewState == .newVersionAvailable {
              OutlineButton(title: "Open Releases") {
                if let releasesUrl = URL(string: Constants.releasesUrl) {
                  NSWorkspace.shared.open(releasesUrl)
                }
              }
              BlueButton(title: "Download Now") {
                if let latestRelease = updateManager.latestRelease, let releaseUrl = latestRelease.releaseDownloadUrlString, let url = URL(string: releaseUrl) {
                  NSWorkspace.shared.open(url)
                }
              }
            } else {
              OutlineButton(title: updateViewState.mainButtonText) {
                if updateViewState == .newVersionAvailable {
                  if let latestRelease = updateManager.latestRelease, let releaseUrl = latestRelease.releaseDownloadUrlString, let url = URL(string: releaseUrl) {
                    NSWorkspace.shared.open(url)
                  }
                } else {
                  Task {
                    await updateManager.checkForUpdatesIfNeeded(force: true)
                  }
                }
              }
            }
            
          }
          .padding(.bottom, 10)
          .disabled(updateManager.isCheckingForUpdate)
          .onChange(of: updateManager.isCheckingForUpdate) {
            updateViewStateBasedOnManager()
          }
          .onChange(of: updateManager.currentBuildIsLatestVersion) {
            updateViewStateBasedOnManager()
          }
          
          HStack {
            if let lastChecked = updateManager.lastCheckedTimestamp {
              Text("Last checked: \(lastChecked, formatter: itemFormatter)")
                .font(.footnote)
                .foregroundStyle(Color.secondary)
            } else {
              Text("Last checked: Never")
                .font(.footnote)
                .foregroundStyle(Color.secondary)
            }
          }
          .padding(.bottom,  2)
          
          if let checkForUpdateError = updateManager.checkForUpdatesErrorMessage {
            Text(checkForUpdateError)
              .padding(.vertical, 4)
              .font(.footnote)
              .foregroundStyle(Color.red)
              .onAppear {
                Delay.by(7) { updateManager.checkForUpdatesErrorMessage = nil }
              }
          }
        }
        .padding()
        .frame(width: 400, height: showUpdateFrequencySection ? expandedFrameHeight : initialFrameHeight)
        .animation(.easeInOut, value: showUpdateFrequencySection)
        .onAppear {
          updateViewStateBasedOnManager()
        }
        
        HStack {
          SymbolButton(symbol: .closeFullscreen) {
            isPresented = false
          }
          .frame(width: 20, height: 20)
          Spacer()
          
          SymbolButton(symbol: .clock) {
            withAnimation {
              showUpdateFrequencySection.toggle()
            }
          }
          .frame(width: 20, height: 20)
          .foregroundStyle(showUpdateFrequencySection ? .blue : .secondary)
        }
        .padding()
        .padding(.top, 24)
        .frame(width: geometry.size.width)
        .position(x: geometry.size.width / 2, y: 15)
      }
    }
    .navigationTitle("Check for Updates")
  }
  
  func updateViewStateBasedOnManager() {
    withAnimation {
      if updateManager.isCheckingForUpdate {
        updateViewState = .checkingForUpdate
      } else if let currentBuildIsLatestVersion = updateManager.currentBuildIsLatestVersion {
        if currentBuildIsLatestVersion == false {
          updateViewState = .newVersionAvailable
        } else {
          updateViewState = .latestVersion
        }
      } else {
        updateViewState = .latestVersion // .defaultState
      }
    }
  }
  
  private var itemFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
  }
}

#Preview {
  let updateManager = UpdateManager()
  updateManager.loadSettings()
  
  return UpdateView(isPresented: .constant(true))
    .frame(width: 400, height: 300)
}

// MARK: ToggleWithLabel
struct ToggleWithLabel: View {
  @Binding var isToggled: Bool
  var header: String
  var description: String = ""
  @State private var isHovering = false
  var showAllDescriptions: Bool
  
  var body: some View {
    HStack(alignment: .top) {
      Toggle("", isOn: $isToggled)
        .padding(.trailing, 6)
        .padding(.top, 2)
      
      VStack(alignment: .leading) {
        HStack {
          Text(header)
            .font(.system(size: 14, weight: .regular, design: .default))
            .padding(.vertical, 2)
          if !showAllDescriptions {
            SFSymbol.help.image
              .onHover { isHovering in
                self.isHovering = isHovering
              }
          }
        }
        Text(description)
          .font(.system(size: 12))
          .foregroundStyle(Color.secondary)
          .opacity(showAllDescriptions || isHovering ? 1 : 0)
      }
      
    }
    .padding(.bottom, 8)
  }
}

//
//  OnboardingView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import SwiftUI

struct WhatsNewView: View {
  @Binding var isPresented: Bool
  @State private var userSettings = UserSettings.shared
  
  @State private var currentStep: Int = 1
  @State private var isMovingForward = true
  
  var body: some View {
    ZStack {
      VStack {
        ScrollView {
          VStack(alignment: .leading) {
            HStack {
              Spacer()
              Group {
                if currentStep == 1 {
                  FirstSection(title: "What's New?", subTitle: "Bug fixes, quality of life changes and more!")
                } else if currentStep == 2 {
                  SecondSection(title: "Coming Soon", subTitle: "What to expect in the coming months")
                } else if currentStep == 3 {
                  LogoStepView()
                }
              }
              .transition(.opacity)
              Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal, 20)
          }
        }
        
        HStack {
          BlueButton(title: "Back") {
            withAnimation {
              if currentStep > 1 { currentStep -= 1 }
            }
          }
          .disabled(currentStep == 1)
          
          Spacer()
          
          Circle()
            .frame(width: 10, height: 10)
            .foregroundColor(currentStep == 1 ? .primary : .secondary.opacity(0.6))
          Circle()
            .frame(width: 10, height: 10)
            .foregroundColor(currentStep == 2 ? .primary : .secondary.opacity(0.6))
          Circle()
            .frame(width: 10, height: 10)
            .foregroundColor(currentStep == 3 ? .primary : .secondary.opacity(0.6))
          
          Spacer()
          
          BlueButton(title: currentStep == 3 ? "Done" : "Next") {
            withAnimation {
              if currentStep < 4 { currentStep += 1 }
              if currentStep > 3 { isPresented = false }
            }
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

struct CheckmarkListItem: View {
  let text: String
  
  var body: some View {
    HStack {
      Image(systemName: "checkmark.circle.fill")
      Text(text)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  WhatsNewView(isPresented: .constant(true))
}

struct CapsuleTextView: View {
  var text: String
  
  var body: some View {
    Text(text)
      .textCase(.lowercase)
      .foregroundColor(.white)
      .font(.system(size: 10, weight: .regular, design: .monospaced))
      .padding(.horizontal, 8)
      .padding(.vertical, 2)
      .background(
        Capsule()
          .fill(Color.blue)
      )
  }
}

struct LogoStepView: View {
  var body: some View {
    VStack(alignment: .center) {
      HStack {
        Spacer()
        Image("Logo")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 300)
        Spacer()
      }
      Text("Welcome to the Preview Release!")
        .padding(.vertical, 8)
        .opacity(0.8)
    }
    .padding(.top, 10)
    .padding(.bottom, 40)
  }
}

struct FirstSection: View {
  let title: String
  let subTitle: String
  
  var body: some View {
    VStack(alignment: .center) {
      Text(title)
        .font(.system(size: 20, weight: .semibold, design: .rounded))
        .padding(.bottom, 8)
      
      Text(subTitle)
        .padding(.bottom, 20)
      
      VStack(alignment: .leading) {
        CheckmarkListItem(text: "User settings and preferences")
        CheckmarkListItem(text: "Automated mod management")
        CheckmarkListItem(text: "Automatically install mods on import")
        CheckmarkListItem(text: "Automatically apply mod updates")
        CheckmarkListItem(text: "Automatically generate modsettings.lsx")
        CheckmarkListItem(text: "File management improvements")
        CheckmarkListItem(text: "Countless bug fixes")
      }
    }
    .padding(.horizontal, 10)
  }
}

struct SecondSection: View {
  let title: String
  let subTitle: String
  
  var body: some View {
    VStack(alignment: .center) {
      Text(title)
        .font(.system(size: 20, weight: .semibold, design: .rounded))
        .padding(.bottom, 8)
      
      Text(subTitle)
        .padding(.bottom, 20)
      
      VStack(alignment: .leading) {
        CheckmarkListItem(text: "Check for Updates")
        CheckmarkListItem(text: "Mod compatibility (no Info.json, sole PAK)")
        CheckmarkListItem(text: "Profiles to enable selective mods")
        CheckmarkListItem(text: "Local mod version control")
        CheckmarkListItem(text: "Nexus API integration")
        CheckmarkListItem(text: "Notify user on new mod update available")
        CheckmarkListItem(text: "Much, much more (see the GitHub page)")
      }
    }
    .padding(.horizontal, 10)
  }
}

import SwiftUI
import AVKit

struct SetupTypeStepView: View {
  let title: String
  let subTitle: String
  let videoName: String
  
  var body: some View {
    VStack(alignment: .center) {
      Text(title)
        .font(.system(size: 20, weight: .semibold, design: .rounded))
        .padding(.bottom, 4)
      
      Text(subTitle)
        .padding(.bottom, 20)
      
      VideoPlayerView(videoName: videoName)
        .aspectRatio(1, contentMode: .fit)
        //.frame(height: 200)
        //.frame(width: 2196, height: 2260)
    }
    .padding(.horizontal, 10)
  }
}

struct VideoPlayerView: View {
  let videoName: String
  @State private var player: AVQueuePlayer?
  @State private var looper: AVPlayerLooper?

  var body: some View {
    VideoPlayer(player: player)
      .onAppear {
        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
          let playerItem = AVPlayerItem(url: url)
          let player = AVQueuePlayer(playerItem: playerItem)
          let looper = AVPlayerLooper(player: player, templateItem: playerItem)
          self.player = player
          self.looper = looper
          self.player?.play()
        }
      }
  }
}

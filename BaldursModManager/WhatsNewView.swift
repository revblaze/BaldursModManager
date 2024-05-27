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
          VStack {
            HStack {
              Spacer()
              Group {
                if currentStep == 1 {
                  LogoStepView()
                } else if currentStep == 2 {
                  SetupTypeStepView(title: "Setup Automatic", subTitle: "Would you like to use an existing Automatic setup,\nor start a new one?", videoName: "preview")
                } else if currentStep == 3 {
                  SetupTypeStepView(title: "Setup Automatic", subTitle: "Would you like to use an existing Automatic setup,\nor start a new one?", videoName: "preview")
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

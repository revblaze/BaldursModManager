//
//  SFSymbol.swift
//  ObservableWebView
//
//  Created by Justin Bush on 3/15/24.
//

import Foundation

enum SFSymbol: String {
  case coreMl = "rotate.3d"
  case python = "point.bottomleft.forward.to.point.topright.scurvepath"
  case network
  case arkit
  case gear
  
  case circleFill = "circle.fill"
  case circleDotted = "circle.dotted"
  case circleDashed = "circle.dashed"
  
  case play = "play.fill"
  case stop = "stop.fill"
  case menuPlay = "play"
  case menuStop = "stop"
  case bonjour
  case trash
  case lock
  case star
  
  case solidLock = "lock.fill"
  case solidLockSlash = "lock.slash.fill"
  case search = "magnifyingglass"
  
  case house
  case plus
  case folder
  case code = "chevron.left.forwardslash.chevron.right"
  case curlyBraces = "ellipsis.curlybraces"
  case starBubble = "star.bubble"
  case sparkles
  
  case link
  case pull = "arrow.triangle.pull"
  case gyro = "gyroscope"
  case newMessage = "plus.message"
  
  case tabBar = "character.textbox"
  case tabGallery = "square.on.square"
  
  case checkmark
  case pencil
  
  case safari
  case download = "arrow.down.circle"
  case addNewCircle = "plus.circle"
  case profile = "person.crop.circle"
  
  case newFolder = "folder.badge.plus"
  case newPrompt = "plus.bubble"
  
  case upDirectory = "arrow.turn.left.up"
  
  case copy = "clipboard"
  case paste = "arrow.up.doc.on.clipboard"
  
  case closeFullscreen = "xmark.circle.fill"
  case clock
  
  case close = "xmark"
  case save = "square.and.arrow.down"
  case copyToWorkspace = "tray.and.arrow.up"
  
  case shuffle
  case repeatLast = "repeat"
  
  // Detail
  case photo
  case back = "arrow.left"
  case forward = "arrow.right"
  case refresh = "arrow.clockwise"
  case mostRecent = "clock.arrow.circlepath"
  case fullscreen = "arrow.up.left.and.arrow.down.right"
  case share = "square.and.arrow.up"
  
  case help = "questionmark.circle"
  case warning = "exclamationmark.triangle"
  case forceStop = "xmark.octagon"
  
  case none
}

import SwiftUI

extension SFSymbol {
  var name: String {
    return self.rawValue
  }
  
  var image: some View {
    Image(systemName: self.name)
      .resizable()
  }
}

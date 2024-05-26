//
//  SymbolButtons.swift
//  ObservableWebView
//
//  Created by Justin Bush on 3/15/24.
//

import SwiftUI

struct MenuButton: View {
  let title: String
  var symbol: SFSymbol?
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        if let symbol = symbol {
          symbol.image
        }
        Text(title)
      }
    }
  }
}

struct ToggleMenuButton: View {
  let title: String
  var toggle: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        if toggle {
          SFSymbol.checkmark.image
        }
        Text(title)
      }
    }
  }
}

struct SymbolButton: View {
  let symbol: SFSymbol
  let action: () -> Void
  
  var body: some View {
    Button(action: {
      action()
    }) {
      symbol.image
    }
    .buttonStyle(BorderlessButtonStyle())
  }
}

struct AccessorySymbolButton: View {
  let symbol: SFSymbol
  let action: () -> Void
  
  var body: some View {
    Button(action: {
      action()
    }) {
      symbol.image
    }
    .buttonStyle(.accessoryBar)
  }
}

struct ToolbarSymbolButton: View {
  let title: String
  let symbol: SFSymbol
  let tint: Color
  let action: () -> Void
  
  init(title: String, symbol: SFSymbol, tint: Color = .secondary, action: @escaping () -> Void) {
    self.title = title
    self.symbol = symbol
    self.action = action
    self.tint = tint
  }
  
  var body: some View {
    Button(action: {
      action()
    }) {
      Label(title, systemImage: symbol.name)
        .foregroundColor(tint)
    }
  }
}



struct SymbolButtons: View {
  var body: some View {
    VStack(spacing: 10) {
      MenuButton(title: "Test", symbol: .python, action: {})
      SymbolButton(symbol: .python, action: {})
    }
    .padding()
  }
}

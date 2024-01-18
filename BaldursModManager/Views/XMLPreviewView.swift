//
//  XMLPreviewView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/18/24.
//

import SwiftUI

struct XMLPreviewView: View {
  @Binding var xmlContent: String
  @Environment(\.presentationMode) var presentationMode
  
  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      ScrollView {
        Text(xmlContent)
          .font(.system(.body, design: .monospaced))
          .padding(.bottom, 50)
          .padding()
          .textSelection(.enabled)
      }
      
      // Dismiss Button
      Button(action: {
        presentationMode.wrappedValue.dismiss()
      }) {
        Image(systemName: "xmark.circle.fill")
          .font(.title)
          .padding(.horizontal, 2)
          .padding(.vertical, 8)
      }
      .shadow(radius: 4)
      .padding()
    }
    .frame(width: 860, height: 600)
  }
}

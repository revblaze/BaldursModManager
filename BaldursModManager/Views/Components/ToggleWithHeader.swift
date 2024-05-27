//
//  ToggleWithHeader.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import SwiftUI

struct ToggleWithHeader: View {
  @Binding var isToggled: Bool
  var header: String
  var description: String = ""
  var showAllDescriptions: Bool

  var body: some View {
    HStack(alignment: .top) {
      Toggle("", isOn: $isToggled)
        .toggleStyle(SwitchToggleStyle(tint: .blue))
        .frame(width: 60)
        .padding(.trailing, 6)

      VStack(alignment: .leading, spacing: 2) {
        Text(header)
          .font(.system(size: 14, weight: .semibold, design: .default))
          .underline()
          .padding(.bottom, 2)

        if showAllDescriptions {
          Text(description)
            .font(.system(size: 12))
            .foregroundStyle(Color.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .layoutPriority(1)

      Spacer()
    }
    .padding(.bottom, 8)
  }
}

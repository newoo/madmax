//
//  BitmaxOpenbookView.swift
//  BitmaxTrading
//
//  Created by Min Min on 9/19/24.
//

import SwiftUI

struct BitmaxOpenBookView: View {
  @State private var viewModel = BitmaxOpenBookViewModel()

  var body: some View {
    NavigationStack {
      VStack {
        Text(viewModel.webSocketRunningDescription)
        Button {
          viewModel.openWebSocket()
        } label: {
          Text("Open WebSocket")
        }

        Button {
          viewModel.closeWebSocket()
        } label: {
          Text("Close WebSocket")
        }
      }
      .onAppear {

      }
      .onDisappear {
        WebsocketManager.shared.closeWebSocket()
      }
    }
  }
}

#Preview {
  BitmaxOpenBookView()
}

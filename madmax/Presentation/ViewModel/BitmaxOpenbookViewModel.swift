//
//  BitmaxOpenbookViewModel.swift
//  BitmaxTrading
//
//  Created by Min Min on 9/19/24.
//

import Foundation

@Observable
final class BitmaxOpenBookViewModel {
  private(set) var isWebSocketRunning = false
  var webSocketRunningDescription: String {
    isWebSocketRunning
    ? "WebSocket is running"
    : "WebSocket is not running"
  }

  func openWebSocket() {
    do {
      try WebsocketManager.shared.openWebSocket()
      isWebSocketRunning = true
    } catch {
      debugPrint("error : \(error)")
    }
  }

  func closeWebSocket() {
    WebsocketManager.shared.closeWebSocket()
    isWebSocketRunning = false
  }
}

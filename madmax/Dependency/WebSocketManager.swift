//
//  WebSocketManager.swift
//  BitmaxTrading
//
//  Created by Min Min on 9/18/24.
//

import Foundation

enum WebSocketError: Error {
  case invalidURL
}

final class WebsocketManager: NSObject {
  static let shared = WebsocketManager()

  private let url: URL? = .init(string: "wss://ws.bitmex.com/realtime")
  private var isWebSocketOpen = false
  weak var delegate: URLSessionWebSocketDelegate?

  // delegate 설정은 URLSession을 만들때 설정
  private lazy var urlSession = URLSession(
    configuration: .default,
    delegate: self,
    delegateQueue: OperationQueue()
  )
  private var webSocketTask: URLSessionWebSocketTask? {
    didSet { oldValue?.cancel(with: .goingAway, reason: nil) }
  }
  private var timer: Timer?

  private override init() {}

  func openWebSocket() throws {
    guard let url else { throw WebSocketError.invalidURL }

    isWebSocketOpen = true
    let webSocketTask = urlSession.webSocketTask(with: url)
    webSocketTask.resume()

    self.webSocketTask = webSocketTask

    startTimer()
    receiveData()
  }

  private func receiveData() {
    guard isWebSocketOpen else { return }

    webSocketTask?.receive(completionHandler: { [weak self] result in
      defer {
        self?.receiveData()
      }

      switch result {
      case .success(let message):
        switch message {
        case .data(let data):
          debugPrint("data : \(data)")

        case .string(let string):

          guard let responseData = string.data(using: .utf8),
                let response = try? JSONDecoder().decode(WebSocketResponse.self, from: responseData)
          else { return }

          let entities = response.datum.map(TradeItemEntity.init)

          print("[\(response.action)] entities : \(entities)")

        @unknown default:
          return
        }
      case .failure(let error):
        debugPrint("error : \(error)")
      }
    })
  }

  func closeWebSocket() {
    webSocketTask = nil
    timer?.invalidate()
    delegate = nil
    isWebSocketOpen = false
  }

  func startTimer() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(
      withTimeInterval: 3,
      repeats: true,
      block: { [weak self] _ in
        self?.timerTask()
      }
    )
  }

  private func timerTask() {
    let request = WebSocketRequest(op: "subscribe", args: ["orderBookL2_25:XBTUSD"])

    guard let requestData = try? JSONEncoder().encode(request),
          let requestString = String(data: requestData, encoding: .utf8)
    else { return }

    debugPrint("requestString : \(requestString)")

    webSocketTask?.send(.string(requestString)) { error in
      guard let error else { return }
      print("dataPing failed \(error)")
    }
  }
}

extension WebsocketManager: URLSessionWebSocketDelegate {
  func urlSession(
    _ session: URLSession,
    webSocketTask: URLSessionWebSocketTask,
    didOpenWithProtocol protocol: String?
  ) {
    delegate?.urlSession?(
      session,
      webSocketTask: webSocketTask,
      didOpenWithProtocol: `protocol`
    )
  }

  func urlSession(
    _ session: URLSession,
    webSocketTask: URLSessionWebSocketTask,
    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
    reason: Data?
  ) {
    delegate?.urlSession?(
      session,
      webSocketTask: webSocketTask,
      didCloseWith: closeCode,
      reason: reason
    )
  }
}

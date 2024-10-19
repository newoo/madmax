//
//  WebSocketManager.swift
//  madmax
//
//  Created by Minseong Kim on 10/4/24.
//

import Combine
import Foundation

enum WebSocketError: Error {
  case invalidURL
}

final class WebSocketManager: NSObject, ObservableObject {
    @Published var tradeItem: [TradeItemEntity] = .init()
    
    private var timer: Timer?
    private var webSocketTask: URLSessionWebSocketTask?
    private var isOpen: Bool = false
    
    override init() {
        super.init()
        do {
            try connect()
        } catch(_) {
            // TODO: - 에러 핸들링 구현 예정
        }
    }
    
    deinit {
        close()
    }
    
    private func connect() throws {
        guard let url = URL(string: "wss://ws.bitmex.com/realtime")
        else { throw WebSocketError.invalidURL }
        
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: nil
        )
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        ping()
        
        send(symbol: "XBTUSD", channel: "orderBookL2_25")
    }
    
    private func close() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        timer?.invalidate()
        timer = nil
        
        isOpen = false
    }
    
    private func receive() {
        guard isOpen else { return }
        
        webSocketTask?.receive(completionHandler: { [weak self] result in
            defer {
                self?.receive()
            }
            
            switch result {
            case .success(let success):
                
                switch success {
                case .data(let data):
                    print("data: \(data)")
                    
                case .string(let string):
                    guard let responseData = string.data(using: .utf8),
                          let response = try? JSONDecoder().decode(WebSocketResponse.self, from: responseData)
                    else { return }

                    let entities = response.datum.map(TradeItemEntity.init)
                    DispatchQueue.main.async {
                        self?.tradeItem = entities
                    }
                    
                @unknown default:
                    return
                }
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        })
    }
    
    func send(symbol: String, channel: String) {
        let request = WebSocketRequest(
            op: "subscribe",
            args: ["\(channel):\(symbol)"]
        )

        guard let requestData = try? JSONEncoder().encode(request),
              let requestString = String(data: requestData, encoding: .utf8)
        else { return }

        webSocketTask?.send(.string(requestString)) { error in
            if let error {
                print("Send Error: \(error.localizedDescription)")
            } else {
                print("Send Success")
            }
        }
    }
    
    private func ping() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 5,
            repeats: true,
            block: { [weak self] _ in
                self?.webSocketTask?.sendPing(pongReceiveHandler: { error in
                    if let error {
                        print("Ping Error: \(error.localizedDescription)")
                    } else {
                        print("Ping Success")
                    }
                })
            }
        )
    }
}

extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isOpen = true
        receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isOpen = false
    }
}


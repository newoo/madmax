//
//  WebSocket.swift
//  OrderBook
//
//  Created by Kang Minsu on 9/27/24.
//

import Foundation

enum WebSocketError: Error {
    case invalidURL
}

final class WebSocket: NSObject {
    static let shared = WebSocket()
    
    var url: URL?
    var onReceiveClosure: ((String?, Data?) -> ())?
    weak var delegate: URLSessionWebSocketDelegate?
    
    private var webSocketTask: URLSessionWebSocketTask? {
        didSet { oldValue?.cancel(with: .goingAway, reason: nil) }
    }
    private var timer: Timer?
    
    private override init() {}
    
    func openWebSocket() throws {
        guard let url else { throw WebSocketError.invalidURL }
        
        let urlSession = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        let webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask.resume()
        
        self.webSocketTask = webSocketTask
        
        startPing()
    }
    
    private func startPing() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 10,
            repeats: true,
            block: { [weak self] _ in self?.ping() }
        )
    }
    private func ping() {
        webSocketTask?.sendPing(pongReceiveHandler: { [weak self] error in
            guard let error else { return }
            print("Ping failed: ", error)
            self?.startPing()
        })
    }
    
    func send() {
        let request = WebSocketRequest(op: .subscribe, args: ["orderBookL2_25:XBTUSD"])
        
        guard let requestData = try? JSONEncoder().encode(request),
              let requestString = String(data: requestData, encoding: .utf8)
        else { return }
        
        webSocketTask?.send(.string(requestString)) { error in
            guard let error else { return }
            print("Send failed: ", error)
        }
    }
    
    func receive(onReceive: @escaping (String?, Data?) -> ()) {
        self.onReceiveClosure = onReceive
        self.webSocketTask?.receive(completionHandler: { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(message):
                switch message {
                case let .string(string):
                    onReceive(string, nil)
                case let .data(data):
                    onReceive(nil, data)
                @unknown default:
                    onReceive(nil, nil)
                }
            case let .failure(error):
                print("Received error \(error)")
            }
            
            if let onReceiveClosure {
                receive(onReceive: onReceiveClosure)
            }
        })
    }
    
    func closeWebSocket() {
      self.webSocketTask = nil
      self.onReceiveClosure = nil
      self.timer?.invalidate()
      self.delegate = nil
    }
}

extension WebSocket: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        self.delegate?.urlSession?(
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
        self.delegate?.urlSession?(
            session,
            webSocketTask: webSocketTask,
            didCloseWith: closeCode,
            reason: reason
        )
    }
}

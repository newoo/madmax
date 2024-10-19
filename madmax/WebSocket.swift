//
//  NWWebSocket.swift
//  madmax
//
//  Created by Taeheon Woo on 10/4/24.
//

import Foundation
import Combine

public enum WebSocketError: Swift.Error {
    case alreadyConnectedOrConnecting
    case notConnected
    case cannotParseMessage(String)
}

extension WebSocket {
    public enum State {
        case notConnected, connecting, connected, disconnected
    }
}

public class WebSocket {
    private(set) var state: State = .notConnected
    
    public let messages: AsyncThrowingStream<Data, Error>
    
    let socketTask: URLSessionWebSocketTask
    private var socketTaskDelegate: SocketTaskDelegate?
    
    private let messagesContinuation: AsyncThrowingStream<Data, Error>.Continuation
    private var pingTask: Task<Void, Error>?
    
    public init(request: URLRequest, urlSession: URLSession = URLSession.shared) {
        let (stream, continuation) = AsyncThrowingStream.makeStream(of: Data.self, throwing: Error.self)
        self.messages = stream
        self.messagesContinuation = continuation
        self.socketTask = urlSession.webSocketTask(with: request)
    }
    
    convenience init(url: URL, urlSession: URLSession = URLSession.shared) {
        self.init(request: URLRequest(url: url), urlSession: urlSession)
    }
    
    deinit {
        try? disconnect()
    }
    
    func connect() async throws {
        guard state == .notConnected else {
            throw WebSocketError.alreadyConnectedOrConnecting
        }
        
        state = .connecting
        
        try await withCheckedThrowingContinuation { continuation in
            let delegate = SocketTaskDelegate { _ in
                self.state = .connected
                continuation.resume()
                self.receive()
                
            } onWebSocketTaskDidClose: { _, _ in
                self.handleDisconnect(withError: nil)
                
            } onWebSocketTaskDidCompleteWithError: { error in
                if let error, self.state == .connecting {
                    continuation.resume(throwing: error)
                }
                
                self.handleDisconnect(withError: error)
            }
            
            self.socketTaskDelegate = delegate
            socketTask.delegate = delegate
            
            socketTask.resume()
        }
    }
    
    func disconnect() throws {
        guard state == .connected else {
            throw WebSocketError.notConnected
        }
        
        messagesContinuation.finish()
        
        socketTask.cancel(with: .normalClosure, reason: nil)
        socketTaskDelegate = nil
    }
    
    func startPing(data: Data, every interval: Duration) {
        pingTask?.cancel()
        
        pingTask = Task {
            if Task.isCancelled { return }
            
            try await send(data)
            
            try await Task.sleep(for: interval)
            
            startPing(data: data, every: interval)
        }
    }
    
    func stopPing() {
        pingTask?.cancel()
        pingTask = nil
    }
    
    func send<Encoder>(
        _ value: any Encodable,
        encoder: Encoder
    ) async throws where Encoder: TopLevelEncoder, Encoder.Output == Data {
        let data = try encoder.encode(value)
        try await send(.data(data))
    }
    
    func send(_ string: String) async throws {
        try await send(.string(string))
    }
    
    func send(_ data: Data) async throws {
        try await send(.data(data))
    }
    
    private func send(_ message: URLSessionWebSocketTask.Message) async throws {
        guard state == .connected else {
            throw WebSocketError.notConnected
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            socketTask.send(message) { error in
                if let error {
                    continuation.resume(with: .failure(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func receive() {
        socketTask.receive { [weak self] result in
            switch result {
            case .success(.data(let data)):
                self?.messagesContinuation.yield(data)
                self?.receive()
                
            case .success(.string(let string)):
                guard let data = string.data(using: .utf8) else {
                    self?.messagesContinuation.finish(throwing: WebSocketError.cannotParseMessage(string))
                    return
                }
                
                self?.messagesContinuation.yield(data)
                self?.receive()
                
            case .failure(let error):
                self?.messagesContinuation.finish(throwing: error)
                
            default:
                break
            }
        }
    }
    
    private func handleDisconnect(withError error: Error?) {
        state = .disconnected
        messagesContinuation.finish(throwing: error)
        socketTaskDelegate = nil
    }
}

private class SocketTaskDelegate: NSObject, URLSessionWebSocketDelegate {
    private let onWebSocketTaskDidOpen: (_ protocol: String?) -> Void
    private let onWebSocketTaskDidClose: (_ code: URLSessionWebSocketTask.CloseCode, _ reason: Data?) -> Void
    private let onWebSocketTaskDidCompleteWithError: (_ error: Error?) -> Void
    
    init(
        onWebSocketTaskDidOpen: @escaping (_: String?) -> Void,
        onWebSocketTaskDidClose: @escaping (_: URLSessionWebSocketTask.CloseCode, _: Data?) -> Void,
        onWebSocketTaskDidCompleteWithError: @escaping (_: Error?) -> Void
    ) {
        self.onWebSocketTaskDidOpen = onWebSocketTaskDidOpen
        self.onWebSocketTaskDidClose = onWebSocketTaskDidClose
        self.onWebSocketTaskDidCompleteWithError = onWebSocketTaskDidCompleteWithError
    }
    
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol proto: String?
    ) {
        onWebSocketTaskDidOpen(proto)
    }
    
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        onWebSocketTaskDidClose(closeCode, reason)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        onWebSocketTaskDidCompleteWithError(error)
    }
}

//
//  WSConnector.swift
//  madmax
//
//  Created by Taeheon Woo on 10/4/24.
//

import Foundation

final class WSConnector {
    struct Reqeust: Encodable {
        let op: String
        let args: [String]
    }
    
    let webSocket = WebSocket(url: URL(string: "wss://ws.bitmex.com/realtime")!)
    
    var onReceiveMessage: ((MadmaxOrderBook) -> Void)?
    
    func connect() async {
        do {
            try await webSocket.connect()
            await sendMessage()
            webSocket.startPing(data: Data(), every: .seconds(1))
            for try await message in webSocket.messages {
                self.handleMessage(message)
                print("Received message: \(String(data: message, encoding: .utf8))")
            }
        } catch {
            print("Error receiving messages:", error)
        }
    }

    func sendMessage() async {
        let request: Reqeust = .init(op: "subscribe", args: ["orderBookL2_25:XBTUSD"])
        
        guard let requestData = try? JSONEncoder().encode(request),
              let requestString = String(data: requestData, encoding: .utf8)
        else { return }
        
        do {
            try await webSocket.socketTask.send(.string(requestString))
        } catch {
            print("Error sending message:", error)
        }
    }
    
    func reconnect() async {
        disconnect()
        await connect()
    }
    
    func disconnect() {
        try? webSocket.disconnect()
    }
    
    private func handleMessage(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let orderBook = try decoder.decode(MadmaxOrderBook.self, from: data)
            DispatchQueue.main.async {
                self.onReceiveMessage?(orderBook)
            }
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
}

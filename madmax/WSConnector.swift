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
    private var pingTimer: Timer?
    
    func connect() async {
        do {
            try await webSocket.connect()
            await sendMessage()
//            startPingTimer()
            webSocket.startPing(data: Data(), every: .seconds(1))
            for try await message in webSocket.messages {
                print("Received message: \(String(data: message, encoding: .utf8))")
            }
        } catch {
            print("Error receiving messages:", error)
        }
    }
    
    func startPingTimer() {
        pingTimer?.invalidate()
        pingTimer = .scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            print("law 타이머 시작")
            guard let self else { return }
            
            self.ping()
        }
    }
    
    func ping() {
        webSocket.socketTask.sendPing(pongReceiveHandler: { error in
            if let error {
                print("ping error: ", error.localizedDescription)
            } else {
                print("ping 성공")
            }
        })
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
}

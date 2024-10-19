//
//  OrderBookViewModel.swift
//  OrderBook
//
//  Created by Kang Minsu on 10/4/24.
//

import Foundation

final class OrderBookViewModel {
    func openWebSocket() {
        WebSocket.shared.url = URL(string: "wss://ws.bitmex.com/realtime")
        try? WebSocket.shared.openWebSocket()
        WebSocket.shared.send()
        WebSocket.shared.receive { string, _ in
            guard let data = string?.data(using: .utf8)
            else {
                print("no data")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(OrderBookResponse.self, from: data)
                response.data.forEach { print($0) }
            } catch {
                print(error)
            }
        }
    }
    
    func closeWebSocket() {
        WebSocket.shared.closeWebSocket()
    }
}

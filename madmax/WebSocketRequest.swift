//
//  WebSocketRequest.swift
//  OrderBook
//
//  Created by Kang Minsu on 10/2/24.
//

import Foundation

struct WebSocketRequest: Encodable {
    let op: Op
    let args: [String]
    
    enum Op: String, Encodable {
        case subscribe
        case unsubscribe
    }
}

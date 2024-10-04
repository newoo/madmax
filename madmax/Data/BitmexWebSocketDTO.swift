//
//  BitmexWebSocketDTO.swift
//  madmax
//
//  Created by Minseong Kim on 10/4/24.
//

import Foundation

struct WebSocketRequest: Encodable {
    let op: String
    let args: [String]
}

struct WebSocketResponse: Decodable {
    let table: String
    let action: String
    let datum: [Self.Data]

    enum CodingKeys: String, CodingKey {
        case table, action
        case datum = "data"
    }

    struct Data: Decodable {
        let symbol: String
        let id: Int
        let side: String
        let size: Int
        let price: Double
        let timestamp: String
        let transactTime: String
    }
}

//
//  OrderBookItem.swift
//  OrderBook
//
//  Created by Kang Minsu on 10/4/24.
//

import Foundation

struct OrderBookResponse: Decodable {
    let data: [OrderBookItem]
}

struct OrderBookItem: Decodable, Hashable {
    let id: Int
    let side: Side
    let size: Decimal?
    let price: Decimal
    
    enum Side: String, Decodable {
        case Buy
        case Sell
    }
}

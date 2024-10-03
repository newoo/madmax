//
//  BitmexTradeEntity.swift
//  madmax
//
//  Created by Minseong Kim on 10/4/24.
//

import Foundation

struct TradeItemEntity: Identifiable {
    let id: Int
    let price: Double
    let side: String
}

extension TradeItemEntity {
    init(dto: WebSocketResponse.Data) {
        id = dto.id
        price = dto.price
        side = dto.side
    }
}

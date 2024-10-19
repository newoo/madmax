//
//  BitmaxTradeEntity+Convert.swift
//  BitmaxTrading
//
//  Created by Min Min on 9/19/24.
//

import Foundation

extension TradeItemEntity {
  init(dto: WebSocketResponse.Data) {
    id = dto.id
    price = dto.price
    side = dto.side
  }
}

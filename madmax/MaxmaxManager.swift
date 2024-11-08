//
//  MaxmaxManager.swift
//  madmax
//
//  Created by Taeheon Woo on 11/8/24.
//

import Foundation

// View에서 사용할 모델
struct OrderData: Identifiable {
    var id: Double { price } // price를 id로 사용
    let price: Double
    var buyVolume: Double
    var sellVolume: Double
}

class MadmaxManager: ObservableObject {
    @Published var orderData: [OrderData] = []
    @Published var currentPrice: Double = 0
    
    let wsConnector = WSConnector()
    
    init() {
        Task {
            await wsConnector.connect()
        }
        
        wsConnector.onReceiveMessage = { [weak self] madmaxOrderBook in
            self?.processOrderBookData(madmaxOrderBook)
        }
    }
    
    private func processOrderBookData(_ madmaxOrderBook: MadmaxOrderBook) {
           // 기존 데이터를 Dictionary 형태로 변환
           var aggregatedOrders: [Double: OrderData] = Dictionary(
               uniqueKeysWithValues: orderData.map { ($0.price, $0) }
           )
           
           // 새로운 데이터로 업데이트 또는 추가
           for order in madmaxOrderBook.data {
               let volume = Double(order.size)
               let price = order.price
               
               if var existingOrder = aggregatedOrders[price] {
                   // 기존 주문이 있으면 해당 side만 업데이트
                   if order.side == "Buy" {
                       existingOrder.buyVolume = volume
                   } else if order.side == "Sell" {
                       existingOrder.sellVolume = volume
                   }
                   aggregatedOrders[price] = existingOrder
               } else {
                   // 새로운 주문 추가
                   let newOrder = OrderData(
                       price: price,
                       buyVolume: order.side == "Buy" ? volume : 0,
                       sellVolume: order.side == "Sell" ? volume : 0
                   )
                   aggregatedOrders[price] = newOrder
               }
           }
           
           // Dictionary를 배열로 변환하여 orderData 업데이트
           orderData = aggregatedOrders.values.sorted(by: { $0.price > $1.price })
           
           // 현재가 업데이트
           if let lastOrder = madmaxOrderBook.data.last {
               currentPrice = lastOrder.price
           }
       }
    
    func startSimulation() {
        Task {
            await wsConnector.reconnect()
        }
    }
    
    func stopSimulation() {
        wsConnector.disconnect()
    }
}

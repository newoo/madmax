//
//  ContentView.swift
//  madmax
//
//  Created by Taeheon Woo on 9/13/24.
//

import SwiftUI

struct ContentView: View {
    let wsConnter = WSConnector()
    
    @StateObject private var manager = MadmaxManager()
    
    private var maxVolume: Double {
        let buyMax = manager.orderData.map { $0.buyVolume }.max() ?? 0
        let sellMax = manager.orderData.map { $0.sellVolume }.max() ?? 0
        return max(buyMax, sellMax)
    }
    
    var body: some View {
           VStack(spacing: 0) {
               Text("호가창")
                   .font(.headline)
                   .padding()
               
               // 매수/매도 구분 헤더
               HStack(spacing: 0) {
                   Text("매수")
                       .frame(maxWidth: .infinity)
                       .background(Color.blue.opacity(0.1))
                       .padding(.vertical, 8)
                   Rectangle()
                       .fill(Color.gray.opacity(0.3))
                       .frame(width: 1)
                   Text("매도")
                       .frame(maxWidth: .infinity)
                       .background(Color.red.opacity(0.1))
                       .padding(.vertical, 8)
               }
               
               HStack(spacing: 0) {
                   // 매수 영역
                   ScrollView {
                       LazyVStack(alignment: .trailing, spacing: 0) {
                           ForEach(manager.orderData.sorted(by: { $0.price < $1.price })) { data in
                               HStack(spacing: 0) {
                                   // 매수 잔량
                                   Text(String(format: "%.0f", data.buyVolume))
                                       .font(.caption)
                                       .frame(width: 60, alignment: .trailing)
                                       .padding(.trailing, 4)
                                   
                                   // 매수 잔량 바
                                   Rectangle()
                                       .fill(Color.blue.opacity(0.3))
                                       .frame(width: CGFloat(data.buyVolume / maxVolume) * 80, height: 25)
                                   
                                   // 매수 가격
                                   Text(String(format: "%.1f", data.price))
                                       .font(.caption)
                                       .frame(width: 50)
                                       .foregroundColor(.blue)
                                       .background(data.price == manager.currentPrice ? Color.blue.opacity(0.1) : Color.clear)
                                       .padding(.trailing, 16)
                               }
                               Divider()
                           }
                       }
                   }
                   .frame(maxHeight: 400) // 스크롤뷰의 최대 높이 설정
                   
                   // 중앙 구분선
                   Rectangle()
                       .fill(Color.gray.opacity(0.3))
                       .frame(width: 1)
                   
                   // 매도 영역
                   ScrollView {
                       LazyVStack(alignment: .leading, spacing: 0) {
                           ForEach(manager.orderData.sorted(by: { $0.price > $1.price })) { data in
                               HStack(spacing: 0) {
                                   // 매도 가격
                                   Text(String(format: "%.1f", data.price))
                                       .font(.caption)
                                       .frame(width: 50)
                                       .foregroundColor(.red)
                                       .background(data.price == manager.currentPrice ? Color.red.opacity(0.1) : Color.clear)
                                       .padding(.leading, 16)
                                   
                                   // 매도 잔량 바
                                   Rectangle()
                                       .fill(Color.red.opacity(0.3))
                                       .frame(width: CGFloat(data.sellVolume / maxVolume) * 80, height: 25)
                                   
                                   // 매도 잔량
                                   Text(String(format: "%.0f", data.sellVolume))
                                       .font(.caption)
                                       .frame(width: 60, alignment: .leading)
                                       .padding(.leading, 4)
                               }
                               Divider()
                           }
                       }
                   }
                   .frame(maxHeight: 400) // 스크롤뷰의 최대 높이 설정
               }
               .padding()
               
               // 컨트롤 버튼
               HStack {
                   Button("시작") {
                       manager.startSimulation()
                   }
                   .padding()
                   
                   Button("정지") {
                       manager.stopSimulation()
                   }
                   .padding()
               }
           }
       }
}

#Preview {
    ContentView()
}

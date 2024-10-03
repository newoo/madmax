//
//  ContentView.swift
//  madmax
//
//  Created by Taeheon Woo on 9/13/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var webSocket = WebSocketManager()

    var body: some View {
        List(webSocket.tradeItem) { item in
            Text("price: \(item.price), side: \(item.side)")
        }
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  OrderBook
//
//  Created by Kang Minsu on 9/27/24.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = OrderBookViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            viewModel.openWebSocket()
        }
        .onDisappear {
            viewModel.closeWebSocket()
        }
    }
}

#Preview {
    ContentView()
}

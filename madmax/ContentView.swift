//
//  ContentView.swift
//  madmax
//
//  Created by Taeheon Woo on 9/13/24.
//

import SwiftUI

struct ContentView: View {
    let wsConnter = WSConnector()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            await wsConnter.connect()
        }
    }
}

#Preview {
    ContentView()
}

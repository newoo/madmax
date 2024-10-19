//
//  ContentView.swift
//  BitmaxTrading
//
//  Created by Min Min on 9/18/24.
//

import Combine
import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationStack {
      VStack {
        NavigationLink("push Bixmax Openbook") {
          BitmaxOpenBookView()
        }
      }
    }
  }
}

#Preview {
  ContentView()
}

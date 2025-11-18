//
//  ContentView.swift
//  TwitchWrapper
//
//  Main view displaying the Twitch web view in full screen.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TwitchWebView()
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}

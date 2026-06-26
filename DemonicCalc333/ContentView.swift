//
//  ContentView.swift
//  DemonicCalc333
//
//  Created by David Martens on 25.06.26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var engine = CalculatorEngine()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                DemonicTheme.backgroundGradient
                    .ignoresSafeArea()

                if proxy.size.width > proxy.size.height {
                    LandscapeCalculatorView(engine: engine)
                } else {
                    PortraitCalculatorView(engine: engine)
                }
            }
        }
        .statusBarHidden(false)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  FitBoard
//
//  Created by Thibault Giraudon on 29/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var healthStore: HealthKitViewModel = .init()
    var body: some View {
        Button("Fetch Data") {
            Task {
                await healthStore.fetchAllWorkouts()
            }
        }
    }
}

#Preview {
    ContentView()
}

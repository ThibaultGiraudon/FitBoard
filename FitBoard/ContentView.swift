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
        NavigationStack {
            List {
                ForEach(healthStore.workouts, id: \.self) { workout in
                    NavigationLink {
                        
                    } label: {
                        RunRowView(workout: workout)
                    }
                }
            }
            .background(Color.background)
            .scrollContentBackground(.hidden)
            .onAppear {
                healthStore.workouts = [
                    Workout(startDate: .now, endDate: .now, avgHR: 166, distance: 6010, duration: 2285, kcalBurned: 446, pace: 6.34, elevationGain: 6025)
                ]
            }
            .navigationTitle("My runs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fetch", systemImage: "plus") {
                        Task {
                            await healthStore.fetchAllWorkouts()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

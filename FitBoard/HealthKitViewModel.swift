//
//  HealthKitViewModel.swift
//  FitBoard
//
//  Created by Thibault Giraudon on 29/09/2025.
//

import Foundation
import Combine
import HealthKit

class HealthKitViewModel: ObservableObject {
    @Published var isAuthorized: Bool = false
    
    init() {
        Task { await requestAuthorization() }
    }
    
    func requestAuthorization() async {
        isAuthorized = false
        do {
            try await HealthKitManager.shared.requestAuthorization()
            isAuthorized = true
        } catch {
            print("HealthKit authorization error: \(error)")
        }
    }
    
    func fetchAllWorkouts() async {
        do {
            let workouts = try await HealthKitManager.shared.fetchWorkouts()
            
            
            for workout in workouts {
                guard let energy = try await HealthKitManager.shared.fetchActiveEnergy(for: workout) else {
                    print("Failed to kcal burned")
                    return
                }
                
                guard let avgHR = try await HealthKitManager.shared.fetchAverageHeartRate(for: workout) else {
                    print("Failed to get average HR")
                    return
                }
                
                guard let distance = try await HealthKitManager.shared.fetchDistance(for: workout) else {
                    print("Failed to get distance")
                    return
                }
                
                let paceMinutesPerMeter: Int = Int(workout.duration / (distance / 1000)) / 60
                let paceSecondsPerMeter: Int = Int(workout.duration / (distance / 1000)) % 60

                print("Workout: \(workout.duration / 60) minutes")
                print(workout)
                print(workout.startDate)
                print(workout.endDate)
                print("Workout burned \(energy) kcal")
                print("Workout average HR: \(avgHR) bpm")
                print("Workout distance: \(distance) m")
                print("Workout pace: \(paceMinutesPerMeter)'\(paceSecondsPerMeter)\" min/km")
                print("---")
                
            }
        } catch {
            print("Failed to fetch workouts: \(error)")
        }
    }
}

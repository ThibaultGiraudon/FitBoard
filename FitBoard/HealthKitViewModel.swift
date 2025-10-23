//
//  HealthKitViewModel.swift
//  FitBoard
//
//  Created by Thibault Giraudon on 29/09/2025.
//

import Foundation
import Combine
import HealthKit

struct Workout: Identifiable, Hashable {
    let id = UUID().uuidString
    let startDate: Date
    let endDate: Date
    let avgHR: Double
    let distance: Double
    let duration: Int
    let kcalBurned: Double
    let pace: Double
    var stringPace: String {
        let paceMinutesPerMeter: Int = Int(self.duration / (Int(self.distance) / 1000)) / 60
        let paceSecondsPerMeter: Int = Int(self.duration / (Int(self.distance) / 1000)) % 60
        
        return "\(paceMinutesPerMeter)'\(paceSecondsPerMeter)\" /km"
    }
    let elevationGain: Double
}

class HealthKitViewModel: ObservableObject {
    @Published var isAuthorized: Bool = false
    @Published var workouts: [Workout] = []
    
    var totalDistance: Int {
        var distance: Int = 0
        
        workouts.forEach { distance += Int($0.distance) }
        
        return distance / 1000
    }
    
    var totalTime: String {
        var time: Int = 0
        
        workouts.forEach { time += Int($0.duration) }
        
        return "\(time / 3600)h \((time % 3600) / 60)min"
    }
    var totalElevationGained: Int {
        var elevation: Int = 0
        
        workouts.forEach { elevation += Int($0.elevationGain) }
        
        return elevation
    }
    
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
            let fetchedWorkouts = try await HealthKitManager.shared.fetchWorkouts()
            
            
            for workout in fetchedWorkouts {
                guard let energy = try await HealthKitManager.shared.fetchActiveEnergy(for: workout) else {
                    print("Failed to kcal burned")
                    continue
                }
                
                guard let avgHR = try await HealthKitManager.shared.fetchAverageHeartRate(for: workout) else {
                    print("Failed to get average HR")
                    continue
                }
                
                guard let distance = try await HealthKitManager.shared.fetchDistance(for: workout) else {
                    print("Failed to get distance")
                    continue
                }
                
                guard let elevation = workout.metadata?["HKElevationAscended"] as? HKQuantity else {
                    print("Failed to get elevation")
                    continue
                }
                
                let pace: Double = workout.duration / (distance / 1000) / 60
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
                
                self.workouts.append(Workout(startDate: workout.startDate, endDate: workout.endDate, avgHR: avgHR, distance: distance, duration: Int(workout.duration), kcalBurned: energy, pace: pace, elevationGain: elevation.doubleValue(for: HKUnit.meter())))
                
            }
        } catch {
            print("Failed to fetch workouts: \(error)")
        }
    }
}

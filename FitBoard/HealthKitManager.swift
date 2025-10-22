//
//  HealthKitManager.swift
//  FitBoard
//
//  Created by Thibault Giraudon on 29/09/2025.
//

import Foundation
import Combine
import HealthKit

class HealthKitManager: ObservableObject {
    static var shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    func requestAuthorization() async throws {
        var typesToRead: Set<HKObjectType> = [.workoutType(), .activitySummaryType()]
        
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            typesToRead.insert(energy)
        }
        
        if let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            typesToRead.insert(heartRate)
        }
        
        if let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            typesToRead.insert(distance)
        }
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    func fetchWorkouts() async throws -> [HKWorkout] {
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let workouts = results as? [HKWorkout] else {
                    continuation.resume(throwing: NSError(
                        domain: "HealthKitWorkoutQuery",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Requesting workouts failed."]
                    ))
                    return
                }
                
                continuation.resume(returning: workouts)
            }
            
            self.healthStore.execute(query)
        }
    }
}

extension HealthKitManager {
    
    func fetchActiveEnergy(for workout: HKWorkout) async throws -> Double? {
        try await withCheckedThrowingContinuation { continuation in
            let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            let predicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let sum = result?.sumQuantity() {
                    continuation.resume(returning: sum.doubleValue(for: .kilocalorie()))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    func fetchAverageHeartRate(for workout: HKWorkout) async throws -> Double? {
        try await withCheckedThrowingContinuation { continuation in
            let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            let predicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let avg = result?.averageQuantity() {
                    continuation.resume(returning: avg.doubleValue(for: HKUnit(from: "count/min")))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    func fetchDistance(for workout: HKWorkout) async throws -> Double? {
        try await withCheckedThrowingContinuation { continuation in
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let predicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let avg = result?.sumQuantity() {
                    continuation.resume(returning: avg.doubleValue(for: HKUnit.meter()))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            self.healthStore.execute(query)
        }
    }
}

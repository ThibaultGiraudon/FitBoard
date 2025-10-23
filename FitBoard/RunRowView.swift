//
//  RunRowView.swift
//  FitBoard
//
//  Created by Thibault Giraudon on 22/10/2025.
//

import SwiftUI

extension Date {
    /// Converts a `Date` to `String`
    ///
    /// - Parameter format: A `String` representing the format into converts the date.
    /// - Returns: A `String` equal at the initial date.
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return dateFormatter.string(from: self)
    }
}

struct RunRowView: View {
    var workout: Workout
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(workout.startDate.toString(format: "dd MMM. YYYY"))
                .foregroundStyle(.secondary)
            Text("\(workout.distance/1000, specifier: "%.2f" ) km")
                .font(.switzer(size: 36, weight: .bold))
                .italic()
                .foregroundStyle(.primaryText)
            HStack {
                Image(systemName: "clock")
                Text("\(workout.duration/3600):\(workout.duration % 3600 / 60):\(workout.duration % 60 < 10 ? "0" : "")\(workout.duration % 60)")
                Spacer()
                Image(systemName: "figure.run")
                    .foregroundStyle(.teal)
                Text(workout.stringPace)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    RunRowView(workout: Workout(startDate: .now, endDate: .now, avgHR: 166, distance: 6010, duration: 2285, kcalBurned: 446, pace: 6.3, elevationGain: 6015))
}

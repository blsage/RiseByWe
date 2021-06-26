//
//  LiftModel.swift
//  Rise by We
//
//  Created by Benjamin Leonardo Sage on 6/23/21.
//

import Foundation

class ExerciseModel: ObservableObject {
    @Published var exercises = initialExercises {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(exercises.map(AnyExercise.init)) {
                UserDefaults.standard.set(encoded, forKey: "Exercises")
            }
        }
    }
    
    init() {
        if let lifts = UserDefaults.standard.data(forKey: "Exercises") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([AnyExercise].self, from: lifts).map({ $0.base }) {
                exercises = decoded
                return
            }
        }
    }
    
    var recapText: String {
        exercises.map { $0.name + ": " + $0.notesString }.joined(separator: "\n")
    }
    
    func resetExercises() {
        exercises = Self.initialExercises
    }
    
    static var initialExercises: [Exercise] = [
        WeightedExercise(name: "Bench", weights: [WeightedExercise.Weight(pounds: 55, hit: true),
                                                  WeightedExercise.Weight(pounds: 60, hit: true),
                                                  WeightedExercise.Weight(pounds: 65, hit: true),
                                                  WeightedExercise.Weight(pounds: 70, hit: false),
                                                  WeightedExercise.Weight(pounds: 70, hit: true),
                                                  WeightedExercise.Weight(pounds: 75, hit: true),
                                                  WeightedExercise.Weight(pounds: 80, hit: false)]),
        WeightedExercise(name: "Shoulder Press", weights: [WeightedExercise.Weight(pounds: 50, hit: true),
                                                           WeightedExercise.Weight(pounds: 55, hit: true),
                                                           WeightedExercise.Weight(pounds: 60, hit: false),
                                                           WeightedExercise.Weight(pounds: 60, hit: false),
                                                           WeightedExercise.Weight(pounds: 60, hit: false),
                                                           WeightedExercise.Weight(pounds: 50, hit: false)]),
        WeightedExercise(name: "Rows", weights: [WeightedExercise.Weight(pounds: 60, hit: true),
                                                 WeightedExercise.Weight(pounds: 65, hit: true),
                                                 WeightedExercise.Weight(pounds: 70, hit: true),
                                                 WeightedExercise.Weight(pounds: 75, hit: false),
                                                 WeightedExercise.Weight(pounds: 75, hit: true)]),
        BodyweightExercise(name: "Pull-ups", reps: [BodyweightExercise.Reps(reps: [3, 2, 2], hit: true),
                                                    BodyweightExercise.Reps(reps: [3, 3, 2], hit: false),
                                                    BodyweightExercise.Reps(reps: [3, 3, 2], hit: false),
                                                    BodyweightExercise.Reps(reps: [3, 3, 2], hit: true)]),
        WeightedExercise(name: "Squats", weights: [WeightedExercise.Weight(pounds: 65, hit: true),
                                                   WeightedExercise.Weight(pounds: 70, hit: true),
                                                   WeightedExercise.Weight(pounds: 75, hit: true),
                                                   WeightedExercise.Weight(pounds: 80, hit: true)]),
        WeightedExercise(name: "Deadlifts", weights: [WeightedExercise.Weight(pounds: 95, hit: true),
                                                      WeightedExercise.Weight(pounds: 100, hit: true),
                                                      WeightedExercise.Weight(pounds: 105, hit: true)])
    ]
}

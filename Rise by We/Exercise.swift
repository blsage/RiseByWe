//
//  Exercise.swift
//  Rise by We
//
//  Created by Benjamin Leonardo Sage on 6/25/21.
//

import Foundation

enum ExerciseType: String, Codable {
    case bodyweight, weighted
    
    var metatype: Exercise.Type {
        switch self {
        case .bodyweight:
            return BodyweightExercise.self
        case .weighted:
            return WeightedExercise.self
        }
    }
}

struct AnyExercise: Codable {
    var base: Exercise
    
    init(_ base: Exercise) {
        self.base = base
    }
    
    private enum CodingKeys: CodingKey {
        case type, base
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(ExerciseType.self, forKey: .type)
        self.base = try type.metatype.init(from: decoder)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type(of: base).type, forKey: .type)
        try base.encode(to: encoder)
    }
}

protocol Exercise: Codable {
    var name: String { get set }
    var justUpdated: Bool { get }
    var levelString: String { get }
    var hitLast: Bool { get }
    var notesString: String { get }
    
    mutating func update(hit: Bool)
    mutating func undo()
    
    static var type: ExerciseType { get }
}

struct BodyweightExercise: Codable, Exercise {
    static var type = ExerciseType.bodyweight
    
    var name: String
    
    struct Reps: Codable {
        var reps: [Int]
        var hit: Bool
        var date: Date = Date(timeIntervalSince1970: 0)
    }
    var reps: [Reps]
    
    var currentReps: [Int] {
        guard let last = reps.last else {
            return []
        }
        if last.hit {
            if Set(last.reps).count == 1 {
                return [last.reps[0] + 1, last.reps[1], last.reps[2]]
            } else if last.reps[1] == last.reps[2] {
                return [last.reps[0], last.reps[1] + 1, last.reps[2]]
            } else {
                return [last.reps[0], last.reps[1], last.reps[2] + 1]
            }
        } else if missedLast3 {
            return last.reps.map { $0 - 1 }
        } else {
            return last.reps
        }
    }
    
    var missedLast3: Bool {
        let last3 = reps.suffix(3)
        let sameWeights = Set(last3.map { $0.reps }).count == 1
        let allMissed = last3.map { $0.hit } == [false, false, false]
        
        return sameWeights && allMissed
    }
    
    var justUpdated: Bool {
        let timeSinceUpdated = Calendar.current.dateComponents([.hour], from: reps.last!.date, to: Date()).hour ?? 0
        return timeSinceUpdated < 12
    }
    
    var levelString: String {
        "\(currentReps[0]), \(currentReps[1]), \(currentReps[2])"
    }
    var hitLast: Bool {
        reps.last!.hit
    }
    var notesString: String {
        reps.map { $0.hit ? $0.reps.map { String($0) }.joined() : "X" }.joined(separator: " ")
    }
    mutating func update(hit: Bool) {
        reps.append(Reps(reps: currentReps, hit: hit, date: Date()))
    }
    mutating func undo() {
        reps.removeLast()
    }
}

struct WeightedExercise: Encodable, Exercise {
    static var type = ExerciseType.weighted
    static let plates = [2.5, 5, 10, 25, 35, 45]
        
    var name: String
    
    struct Weight: Codable {
        var pounds: Int
        var hit: Bool
        var date: Date = Date(timeIntervalSince1970: 0)
    }
    var weights: [Weight]
    
    var currentWeight: Int {
        guard let last = weights.last else {
            return -1
        }
        if last.hit {
            return last.pounds + 5
        } else if missedLast3 {
            let nextDouble = Double(last.pounds) * 0.9
            var next = Int(floor(nextDouble))
            while next % 5 != 0 {
                next -= 1
            }
            return next
        } else {
            return last.pounds
        }
    }
    
    var missedLast3: Bool {
        let last3 = weights.suffix(3)
        let sameWeights = Set(last3.map { $0.pounds }).count == 1
        let allMissed = last3.map { $0.hit } == [false, false, false]
        return sameWeights && allMissed
    }
    
    var justUpdated: Bool {
        let timeSinceUpdated = Calendar.current.dateComponents([.hour], from: weights.last!.date, to: Date()).hour ?? 0
        return timeSinceUpdated < 12
    }
    
    var levelString: String {
        "\(currentWeight) lbs"
    }
    var hitLast: Bool {
        weights.last!.hit
    }
    var notesString: String {
        weights.map { $0.hit ? String($0.pounds) : "X" }.joined(separator: " ")
    }
    
    var weight: Int { currentWeight }
    
    mutating func update(hit: Bool) {
        weights.append(Weight(pounds: currentWeight, hit: hit, date: Date()))
    }
    mutating func undo() {
        weights.removeLast()
    }
    
    static func calculatePlates(fromWeight weight: Int) -> [Double] {
        let additionalWeight = weight - 45
        let eachSide = Double(additionalWeight) / 2
        
        var remainingWeight = eachSide
        var plates: [Double] = []
        
        while remainingWeight > 0 {
            let plate = Self.plates.reduce(0) { result, double in
                double > remainingWeight ? result : double
            }
            plates.append(plate)
            remainingWeight -= plate
        }
        
        return plates
    }
    
    static func calculateSupersetPlates(fromWeight weight1: Int, and weight2: Int) -> ([Double], [Double], Bool) {
        let firstLighter = weight1 < weight2
        
        let smaller = min(weight1, weight2)
        let larger = max(weight1, weight2)
        let base = Self.calculatePlates(fromWeight: smaller)
        
        let additionalWeight = Self.calculatePlates(fromWeight: larger - Int(2 * base.reduce(0.0) { Double($0) + $1 }))
        
        return (base, additionalWeight, firstLighter)
    }
}

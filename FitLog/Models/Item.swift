import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var muscleGroup: String
    var equipment: String
    var type: String
    
    init(name: String, muscleGroup: String, equipment: String, type: String) {
        self.id = UUID()
        self.name = name
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.type = type
    }
}

@Model
final class ExerciseSet {
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    
    init(weight: Double, reps: Int) {
        self.weight = weight
        self.reps = reps
        self.isCompleted = false
    }
}

@Model
final class WorkoutExercise {
    var exercise: Exercise
    var sets: [ExerciseSet]
    var order: Int
    
    init(exercise: Exercise, order: Int) {
        self.exercise = exercise
        self.sets = []
        self.order = order
    }
}

@Model
final class Workout {
    var id: UUID
    var name: String
    var date: Date
    var duration: Int
    var exercises: [WorkoutExercise]
    var notes: String
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.date = Date()
        self.duration = 0
        self.exercises = []
        self.notes = ""
    }
}

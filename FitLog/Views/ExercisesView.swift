//
//  ExercisesView.swift
//  FitLog
//
//  Created by Lucas Chaves Pinheiro on 13/05/26.
//

import SwiftUI
import SwiftData

struct ExercisesView: View {
    @Query private var exercises: [Exercise]
    @Environment(\.modelContext) private var modelContext
    
    let muscleGroups = ["Todos", "Peito", "Costas", "Pernas", "Ombro", "Bíceps", "Tríceps", "Abdômen"]
    @State private var selectedGroup = "Todos"
    
    var filteredExercises: [Exercise] {
        if selectedGroup == "Todos" {
            return exercises
        }
        return exercises.filter { $0.muscleGroup == selectedGroup }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // filtro de grupos musculares
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(muscleGroups, id: \.self) { group in
                                Button(action: { selectedGroup = group }) {
                                    Text(group)
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(selectedGroup == group ? Color.purple : Color.white.opacity(0.08))
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    
                    // lista de exercicios
                    if filteredExercises.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Text("🏋️")
                                .font(.system(size: 48))
                            Text("Nenhum exercício ainda")
                                .foregroundColor(.gray)
                            Text("Adicione seu primeiro exercício!")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        Spacer()
                    } else {
                        List(filteredExercises) { exercise in
                            ExerciseRow(exercise: exercise)
                                .listRowBackground(Color.white.opacity(0.05))
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Exercícios")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addSampleExercises) {
                        Image(systemName: "plus")
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }
    
    func addSampleExercises() {
        guard exercises.isEmpty else { return }
        
        let samples = [
            Exercise(name: "Supino Reto", muscleGroup: "Peito", equipment: "Barra", type: "Composto"),
            Exercise(name: "Crossover", muscleGroup: "Peito", equipment: "Cabo", type: "Isolado"),
            Exercise(name: "Puxada Frontal", muscleGroup: "Costas", equipment: "Máquina", type: "Composto"),
            Exercise(name: "Remada Curvada", muscleGroup: "Costas", equipment: "Barra", type: "Composto"),
            Exercise(name: "Agachamento", muscleGroup: "Pernas", equipment: "Barra", type: "Composto"),
            Exercise(name: "Leg Press", muscleGroup: "Pernas", equipment: "Máquina", type: "Composto"),
            Exercise(name: "Desenvolvimento", muscleGroup: "Ombro", equipment: "Halter", type: "Composto"),
            Exercise(name: "Rosca Direta", muscleGroup: "Bíceps", equipment: "Barra", type: "Isolado"),
            Exercise(name: "Tríceps Pulley", muscleGroup: "Tríceps", equipment: "Cabo", type: "Isolado"),
        ]
        samples.forEach { modelContext.insert($0) }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var muscleColor: Color {
        switch exercise.muscleGroup {
        case "Peito": return .purple
        case "Costas": return .blue
        case "Pernas": return .green
        case "Ombro": return .orange
        case "Bíceps": return .pink
        case "Tríceps": return .yellow
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(muscleColor.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(exercise.name.prefix(1)))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(muscleColor)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text("\(exercise.muscleGroup) · \(exercise.type)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(exercise.equipment)
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.08))
                .foregroundColor(.gray)
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ExercisesView()
        .modelContainer(for: Exercise.self, inMemory: true)
}

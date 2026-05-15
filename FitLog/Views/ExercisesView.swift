import SwiftUI
import SwiftData

struct ExercisesView: View {
    @Query private var exercises: [Exercise]
    @Environment(\.modelContext) private var modelContext
    
    let muscleGroups = ["Todos", "Peito", "Costas", "Pernas", "Ombro", "Bíceps", "Tríceps", "Abdômen"]
    @State private var selectedGroup = "Todos"
    
    var filteredExercises: [Exercise] {
        if selectedGroup == "Todos" { return exercises }
        return exercises.filter { $0.muscleGroup == selectedGroup }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(muscleGroups, id: \.self) { group in
                                Button(action: { selectedGroup = group }) {
                                    Text(group)
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(selectedGroup == group ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    
                    if filteredExercises.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: AppIcons.gym)
                                .font(.system(size: 48))
                                .foregroundColor(AppTheme.Colors.primary)
                            Text("Nenhum exercício ainda")
                                .foregroundColor(.gray)
                            Text("Toque no + para adicionar!")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        Spacer()
                    } else {
                        List(filteredExercises) { exercise in
                            ExerciseRow(exercise: exercise)
                                .listRowBackground(AppTheme.Colors.surface)
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
                            .foregroundColor(AppTheme.Colors.primary)
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

#Preview {
    ExercisesView()
        .modelContainer(for: Exercise.self, inMemory: true)
}

import SwiftUI
import SwiftData

struct ExercisesView: View {
    @Query private var exercises: [Exercise]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddExercise = false
    
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
                    Button(action: { showingAddExercise = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
    }
}

#Preview {
    ExercisesView()
        .modelContainer(for: Exercise.self, inMemory: true)
}

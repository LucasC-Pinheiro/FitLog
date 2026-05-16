import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]

    @State private var workoutName = "Meu Treino"
    @State private var selectedExercises: [WorkoutExercise] = []
    @State private var showingExercisePicker = false
    @State private var elapsedSeconds = 0
    @State private var timer: Timer? = nil

    var elapsedFormatted: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: AppIcons.close)
                            Text("Descartar")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.danger)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text(elapsedFormatted)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.Colors.success)
                        Text("tempo")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: { saveWorkout() }) {
                        HStack(spacing: 4) {
                            Image(systemName: AppIcons.save)
                            Text("Salvar")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.Radius.medium)
                    }
                }
                .padding()

                // Workout Name
                TextField("Nome do treino", text: $workoutName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                Divider().background(Color.white.opacity(0.1))

                // Exercises List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(selectedExercises.enumerated()), id: \.element.id) { _, we in
                            WorkoutExerciseCard(workoutExercise: we)
                        }

                        // Add Exercise Button
                        Button(action: { showingExercisePicker = true }) {
                            HStack {
                                Image(systemName: AppIcons.addExercise)
                                Text("Adicionar exercício")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(AppTheme.Colors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.Colors.primaryDim)
                            .cornerRadius(AppTheme.Radius.large)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                                    .stroke(AppTheme.Colors.primaryGlow, lineWidth: 1)
                            )
                        }
                        .padding(.top, 4)

                        // Finish Workout Button
                        if !selectedExercises.isEmpty {
                            Button(action: saveWorkout) {
                                HStack(spacing: 4) {
                                    Image(systemName: AppIcons.checkmark)
                                    Text("Finalizar treino")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.Colors.primary)
                                .cornerRadius(AppTheme.Radius.large)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView(exercises: exercises) { exercise in
                let we = WorkoutExercise(exercise: exercise, order: selectedExercises.count)
                we.sets = [ExerciseSet(weight: 0, reps: 0)]
                selectedExercises.append(we)
            }
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    func saveWorkout() {
        timer?.invalidate()
        let workout = Workout(name: workoutName)
        workout.duration = elapsedSeconds / 60
        workout.exercises = selectedExercises
        selectedExercises.forEach { modelContext.insert($0) }
        modelContext.insert(workout)
        dismiss()
    }
}

// MARK: - Exercise Picker
struct ExercisePickerView: View {
    let exercises: [Exercise]
    let onSelect: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddExercise = false

    let muscleGroups = ["Todos", "Peito", "Costas", "Pernas", "Ombro", "Bíceps", "Tríceps"]
    @State private var selectedGroup = "Todos"

    var filtered: [Exercise] {
        selectedGroup == "Todos" ? exercises : exercises.filter { $0.muscleGroup == selectedGroup }
    }

    var body: some View {
        NavigationStack {
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
                        .padding()
                    }

                    if filtered.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: AppIcons.gym)
                                .font(.system(size: 48))
                                .foregroundColor(AppTheme.Colors.primary)
                            Text("Nenhum exercício cadastrado")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Crie seu primeiro exercício tocando em 'Novo'")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            Spacer()
                        }
                    } else {
                        List(filtered) { exercise in
                            Button(action: {
                                onSelect(exercise)
                                dismiss()
                            }) {
                                HStack {
                                    Text(exercise.name)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(exercise.muscleGroup)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .listRowBackground(AppTheme.Colors.surface)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Escolher exercício")
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { showingAddExercise = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Novo")
                        }
                        .foregroundColor(AppTheme.Colors.primary)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
    }
}

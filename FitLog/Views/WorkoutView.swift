import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]

    @State private var workoutName = "Meu Treino"
    @State private var selectedExercises: [WorkoutExercise] = []
    @State private var showingExercisePicker = false
    @State private var startTime = Date()
    @State private var elapsedSeconds = 0
    @State private var timer: Timer? = nil

    var elapsedFormatted: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {

                    // header
                    HStack {
                        Button("Cancelar") { dismiss() }
                            .foregroundColor(.red)

                        Spacer()

                        Text(elapsedFormatted)
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.green)

                        Spacer()

                        Button("Salvar") { saveWorkout() }
                            .foregroundColor(.purple)
                            .fontWeight(.semibold)
                    }
                    .padding()

                    // nome do treino
                    TextField("Nome do treino", text: $workoutName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 12)

                    Divider().background(Color.white.opacity(0.1))

                    // lista de exercícios
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(selectedExercises.enumerated()), id: \.element.id) { index, we in
                                WorkoutExerciseCard(workoutExercise: we)
                            }

                            // botão adicionar exercício
                            Button(action: { showingExercisePicker = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Adicionar exercício")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(.purple)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.top, 4)

                            // botão finalizar
                            if !selectedExercises.isEmpty {
                                Button(action: saveWorkout) {
                                    Text("Finalizar treino ✓")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.purple)
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
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

// MARK: - Card de exercício no treino
struct WorkoutExerciseCard: View {
    @Bindable var workoutExercise: WorkoutExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(workoutExercise.exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(workoutExercise.exercise.muscleGroup)
                    .font(.system(size: 11))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.15))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
            }

            // header das colunas
            HStack {
                Text("Série").frame(width: 36)
                Text("KG").frame(maxWidth: .infinity)
                Text("Reps").frame(maxWidth: .infinity)
                Text("✓").frame(width: 28)
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.gray)

            // séries
            ForEach(Array(workoutExercise.sets.enumerated()), id: \.offset) { index, set in
                SetRow(set: set, index: index + 1)
            }

            // botão adicionar série
            Button(action: {
                workoutExercise.sets.append(ExerciseSet(weight: 0, reps: 0))
            }) {
                Text("+ série")
                    .font(.system(size: 13))
                    .foregroundColor(.purple)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Linha de série
struct SetRow: View {
    @Bindable var set: ExerciseSet
    let index: Int

    var body: some View {
        HStack {
            Text("\(index)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 36)

            TextField("0", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.07))
                .cornerRadius(8)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)

            TextField("0", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.07))
                .cornerRadius(8)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)

            Button(action: { set.isCompleted.toggle() }) {
                Circle()
                    .fill(set.isCompleted ? Color.green : Color.white.opacity(0.1))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(set.isCompleted ? 1 : 0.3)
                    )
            }
            .frame(width: 28)
        }
    }
}

// MARK: - Picker de exercícios
struct ExercisePickerView: View {
    let exercises: [Exercise]
    let onSelect: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss

    let muscleGroups = ["Todos", "Peito", "Costas", "Pernas", "Ombro", "Bíceps", "Tríceps"]
    @State private var selectedGroup = "Todos"

    var filtered: [Exercise] {
        selectedGroup == "Todos" ? exercises : exercises.filter { $0.muscleGroup == selectedGroup }
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
                                        .background(selectedGroup == group ? Color.purple : Color.white.opacity(0.08))
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                    }

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
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Escolher exercício")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .foregroundColor(.purple)
                }
            }
        }
    }
}

import SwiftUI
import SwiftData

// MARK: - Workout View
/// Tela de treino ativo com design premium
/// Melhorias: Timer animado, header glassmorphism, cards modernos,
/// feedback visual melhorado, animações suaves, confirmação de saída
struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]

    @State private var workoutName = "Meu Treino"
    @State private var selectedExercises: [WorkoutExercise] = []
    @State private var showingExercisePicker = false
    @State private var showingDiscardAlert = false
    @State private var elapsedSeconds = 0
    @State private var timer: Timer? = nil
    @State private var isVisible = false

    var elapsedFormatted: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    var totalSets: Int {
        selectedExercises.flatMap { $0.sets }.count
    }

    var completedSets: Int {
        selectedExercises.flatMap { $0.sets }.filter { $0.isCompleted }.count
    }

    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.horizontal, AppTheme.Spacing.large)
                    .padding(.top, AppTheme.Spacing.medium)

                // Workout name input
                workoutNameInput
                    .padding(.horizontal, AppTheme.Spacing.large)
                    .padding(.top, AppTheme.Spacing.medium)

                // Stats bar
                if !selectedExercises.isEmpty {
                    statsBar
                        .padding(.horizontal, AppTheme.Spacing.large)
                        .padding(.top, AppTheme.Spacing.medium)
                }

                // Exercises List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.medium) {
                        ForEach(Array(selectedExercises.enumerated()), id: \.element.id) { index, we in
                            WorkoutExerciseCard(workoutExercise: we)
                                .staggeredAppear(index: index, isVisible: isVisible)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        removeExercise(we)
                                    } label: {
                                        Label("Remover", systemImage: "trash")
                                    }
                                }
                        }

                        // Add Exercise Button
                        addExerciseButton
                            .staggeredAppear(index: selectedExercises.count, isVisible: isVisible)

                        // Finish Workout Button
                        if !selectedExercises.isEmpty {
                            finishButton
                                .padding(.top, AppTheme.Spacing.small)
                        }

                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.large)
                    .padding(.top, AppTheme.Spacing.large)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startTimer()
            withAnimation(AppTheme.Animation.smooth.delay(0.2)) {
                isVisible = true
            }
        }
        .onDisappear { timer?.invalidate() }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView(exercises: exercises) { exercise in
                addExercise(exercise)
            }
        }
        .alert("Descartar treino?", isPresented: $showingDiscardAlert) {
            Button("Continuar treinando", role: .cancel) { }
            Button("Descartar", role: .destructive) { dismiss() }
        } message: {
            Text("Todo o progresso deste treino será perdido.")
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            // Discard button
            Button(action: {
                AppTheme.Haptics.warning()
                if selectedExercises.isEmpty {
                    dismiss()
                } else {
                    showingDiscardAlert = true
                }
            }) {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("Sair")
                        .font(AppTheme.Typography.labelMedium())
                }
                .foregroundColor(AppTheme.Colors.danger)
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.vertical, AppTheme.Spacing.small)
                .background(AppTheme.Colors.dangerDim)
                .cornerRadius(AppTheme.Radius.pill)
            }

            Spacer()

            // Timer
            timerDisplay

            Spacer()

            // Save button
            Button(action: saveWorkout) {
                HStack(spacing: AppTheme.Spacing.xxs) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("Salvar")
                        .font(AppTheme.Typography.labelMedium())
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.vertical, AppTheme.Spacing.small)
                .background(AppTheme.Gradients.primary)
                .cornerRadius(AppTheme.Radius.pill)
                .shadow(AppTheme.Shadows.glow)
            }
            .disabled(selectedExercises.isEmpty)
            .opacity(selectedExercises.isEmpty ? 0.5 : 1)
        }
    }

    private var timerDisplay: some View {
        VStack(spacing: 2) {
            HStack(spacing: AppTheme.Spacing.xxs) {
                Circle()
                    .fill(AppTheme.Colors.success)
                    .frame(width: 6, height: 6)

                Text(elapsedFormatted)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .contentTransition(.numericText())
            }

            Text("em andamento")
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
        .padding(.vertical, AppTheme.Spacing.small)
        .glassCard(cornerRadius: AppTheme.Radius.medium)
    }

    // MARK: - Workout Name
    private var workoutNameInput: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "pencil")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textTertiary)

            TextField("Nome do treino", text: $workoutName)
                .font(AppTheme.Typography.headline())
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.surfaceElevated)
        .cornerRadius(AppTheme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
        )
    }

    // MARK: - Stats Bar
    private var statsBar: some View {
        HStack(spacing: AppTheme.Spacing.large) {
            StatPill(
                icon: "dumbbell.fill",
                value: "\(selectedExercises.count)",
                label: "exercícios"
            )

            StatPill(
                icon: "checkmark.circle.fill",
                value: "\(completedSets)/\(totalSets)",
                label: "séries"
            )

            if completedSets > 0 {
                StatPill(
                    icon: "percent",
                    value: "\(Int(Double(completedSets) / Double(max(totalSets, 1)) * 100))%",
                    label: "completo"
                )
            }
        }
    }

    // MARK: - Add Exercise Button
    private var addExerciseButton: some View {
        Button(action: {
            AppTheme.Haptics.light()
            showingExercisePicker = true
        }) {
            HStack(spacing: AppTheme.Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primaryDim)
                        .frame(width: 44, height: 44)

                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Adicionar exercício")
                        .font(AppTheme.Typography.titleSmall())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text("Escolha da sua biblioteca")
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
            .padding(AppTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                    )
                    .foregroundColor(AppTheme.Colors.primaryDim)
            )
        }
    }

    // MARK: - Finish Button
    private var finishButton: some View {
        PremiumButton(
            title: "Finalizar treino",
            icon: "checkmark.circle.fill"
        ) {
            saveWorkout()
        }
    }

    // MARK: - Actions
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    func addExercise(_ exercise: Exercise) {
        AppTheme.Haptics.success()
        let we = WorkoutExercise(exercise: exercise, order: selectedExercises.count)
        we.sets = [ExerciseSet(weight: 0, reps: 0)]
        withAnimation(AppTheme.Animation.spring) {
            selectedExercises.append(we)
        }
    }

    func removeExercise(_ exercise: WorkoutExercise) {
        AppTheme.Haptics.medium()
        withAnimation(AppTheme.Animation.spring) {
            selectedExercises.removeAll { $0.id == exercise.id }
        }
    }

    func saveWorkout() {
        guard !selectedExercises.isEmpty else { return }

        AppTheme.Haptics.success()
        timer?.invalidate()

        let workout = Workout(name: workoutName)
        workout.duration = elapsedSeconds / 60
        workout.exercises = selectedExercises
        selectedExercises.forEach { modelContext.insert($0) }
        modelContext.insert(workout)
        dismiss()
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.primary)

            Text(value)
                .font(AppTheme.Typography.labelMedium())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(label)
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.Radius.pill)
    }
}

// MARK: - Exercise Picker View
/// Modal para seleção de exercícios com filtros e busca
struct ExercisePickerView: View {
    let exercises: [Exercise]
    let onSelect: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddExercise = false
    @State private var searchText = ""

    let muscleGroups = ["Todos", "Peito", "Costas", "Pernas", "Ombro", "Bíceps", "Tríceps", "Abdômen"]
    @State private var selectedGroup = "Todos"

    var filtered: [Exercise] {
        var result = exercises

        if selectedGroup != "Todos" {
            result = result.filter { $0.muscleGroup == selectedGroup }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                        .padding(.horizontal, AppTheme.Spacing.large)
                        .padding(.top, AppTheme.Spacing.medium)

                    // Filter chips
                    filterChips
                        .padding(.top, AppTheme.Spacing.medium)

                    // Content
                    if filtered.isEmpty {
                        emptyState
                    } else {
                        exerciseList
                    }
                }
            }
            .navigationTitle("Escolher exercício")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { showingAddExercise = true }) {
                        HStack(spacing: AppTheme.Spacing.xxs) {
                            Image(systemName: "plus")
                            Text("Novo")
                        }
                        .font(AppTheme.Typography.labelMedium())
                        .foregroundColor(AppTheme.Colors.primary)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .font(AppTheme.Typography.labelMedium())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
    }

    private var searchBar: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textTertiary)

            TextField("Buscar exercício...", text: $searchText)
                .font(AppTheme.Typography.bodyMedium())
                .foregroundColor(AppTheme.Colors.textPrimary)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.surfaceElevated)
        .cornerRadius(AppTheme.Radius.medium)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.small) {
                ForEach(muscleGroups, id: \.self) { group in
                    Button(action: {
                        AppTheme.Haptics.selection()
                        withAnimation(AppTheme.Animation.quick) {
                            selectedGroup = group
                        }
                    }) {
                        Text(group)
                            .font(AppTheme.Typography.labelMedium())
                            .padding(.horizontal, AppTheme.Spacing.medium)
                            .padding(.vertical, AppTheme.Spacing.small)
                            .background(
                                selectedGroup == group ?
                                AppTheme.Colors.primary : AppTheme.Colors.surface
                            )
                            .foregroundColor(
                                selectedGroup == group ?
                                    .white : AppTheme.Colors.textSecondary
                            )
                            .cornerRadius(AppTheme.Radius.pill)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.large)
        }
    }

    private var exerciseList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.small) {
                ForEach(filtered) { exercise in
                    Button(action: {
                        AppTheme.Haptics.medium()
                        onSelect(exercise)
                        dismiss()
                    }) {
                        ExerciseRow(exercise: exercise)
                            .padding(AppTheme.Spacing.medium)
                            .background(AppTheme.Colors.surfaceElevated)
                            .cornerRadius(AppTheme.Radius.medium)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.large)
            .padding(.top, AppTheme.Spacing.medium)
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryDim)
                    .frame(width: 100, height: 100)

                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.Colors.primary)
            }

            VStack(spacing: AppTheme.Spacing.small) {
                Text(exercises.isEmpty ? "Nenhum exercício cadastrado" : "Nenhum resultado")
                    .font(AppTheme.Typography.titleMedium())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(exercises.isEmpty ?
                     "Crie seu primeiro exercício tocando em 'Novo'" :
                        "Tente ajustar os filtros ou busca")
                    .font(AppTheme.Typography.bodySmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if exercises.isEmpty {
                Button(action: { showingAddExercise = true }) {
                    Text("Criar exercício")
                        .font(AppTheme.Typography.labelMedium())
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.horizontal, AppTheme.Spacing.extraLarge)
                        .padding(.vertical, AppTheme.Spacing.medium)
                        .background(AppTheme.Colors.primaryDim)
                        .cornerRadius(AppTheme.Radius.pill)
                }
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.extraLarge)
    }
}

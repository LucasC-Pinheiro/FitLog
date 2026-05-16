import SwiftUI
import SwiftData

// MARK: - Exercises View
/// Biblioteca de exercícios com design premium
/// Melhorias: Busca integrada, filtros animados, cards modernos,
/// swipe actions, agrupamento visual, animações de entrada
struct ExercisesView: View {
    @Query private var exercises: [Exercise]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddExercise = false
    @State private var searchText = ""
    @State private var isVisible = false

    let muscleGroups = ["Todos", "Peito", "Costas", "Pernas", "Ombro", "Bíceps", "Tríceps", "Abdômen"]
    @State private var selectedGroup = "Todos"

    var filteredExercises: [Exercise] {
        var result = exercises

        if selectedGroup != "Todos" {
            result = result.filter { $0.muscleGroup == selectedGroup }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result.sorted { $0.name < $1.name }
    }

    var groupedExercises: [String: [Exercise]] {
        Dictionary(grouping: filteredExercises) { $0.muscleGroup }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
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
                    if filteredExercises.isEmpty {
                        emptyState
                    } else {
                        exercisesList
                    }
                }
            }
            .navigationTitle("Exercícios")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        AppTheme.Haptics.light()
                        showingAddExercise = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppTheme.Gradients.primary)
                    }
                }
            }
            .onAppear {
                withAnimation(AppTheme.Animation.smooth.delay(0.1)) {
                    isVisible = true
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
    }

    // MARK: - Search Bar
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
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
        )
    }

    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.small) {
                ForEach(muscleGroups, id: \.self) { group in
                    FilterChip(
                        title: group,
                        isSelected: selectedGroup == group,
                        color: group == "Todos" ? AppTheme.Colors.primary :
                            (AppTheme.Colors.muscleColors[group] ?? AppTheme.Colors.primary)
                    ) {
                        AppTheme.Haptics.selection()
                        withAnimation(AppTheme.Animation.spring) {
                            selectedGroup = group
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.large)
        }
    }

    // MARK: - Exercises List
    private var exercisesList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: AppTheme.Spacing.medium, pinnedViews: .sectionHeaders) {
                if selectedGroup == "Todos" {
                    // Grouped by muscle
                    ForEach(groupedExercises.keys.sorted(), id: \.self) { muscleGroup in
                        Section {
                            ForEach(Array((groupedExercises[muscleGroup] ?? []).enumerated()), id: \.element.id) { index, exercise in
                                ExerciseListCard(exercise: exercise) {
                                    deleteExercise(exercise)
                                }
                                .staggeredAppear(index: index, isVisible: isVisible)
                            }
                        } header: {
                            sectionHeader(for: muscleGroup, count: groupedExercises[muscleGroup]?.count ?? 0)
                        }
                    }
                } else {
                    // Flat list for filtered
                    ForEach(Array(filteredExercises.enumerated()), id: \.element.id) { index, exercise in
                        ExerciseListCard(exercise: exercise) {
                            deleteExercise(exercise)
                        }
                        .staggeredAppear(index: index, isVisible: isVisible)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.large)
            .padding(.top, AppTheme.Spacing.medium)
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
    }

    private func sectionHeader(for muscleGroup: String, count: Int) -> some View {
        HStack {
            Circle()
                .fill(AppTheme.Colors.muscleColors[muscleGroup] ?? AppTheme.Colors.primary)
                .frame(width: 8, height: 8)

            Text(muscleGroup)
                .font(AppTheme.Typography.labelMedium())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text("(\(count))")
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textTertiary)

            Spacer()
        }
        .padding(.vertical, AppTheme.Spacing.small)
        .padding(.horizontal, AppTheme.Spacing.small)
        .background(AppTheme.Colors.background)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.extraLarge) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryDim)
                    .frame(width: 120, height: 120)

                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.Colors.primary)
            }

            VStack(spacing: AppTheme.Spacing.small) {
                Text(exercises.isEmpty ? "Crie seus exercícios" : "Nenhum resultado")
                    .font(AppTheme.Typography.titleLarge())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(exercises.isEmpty ?
                     "Monte sua biblioteca personalizada\nde exercícios favoritos" :
                        "Tente ajustar a busca ou filtros")
                    .font(AppTheme.Typography.bodyMedium())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if exercises.isEmpty {
                PremiumButton(
                    title: "Criar primeiro exercício",
                    icon: "plus"
                ) {
                    showingAddExercise = true
                }
                .padding(.horizontal, AppTheme.Spacing.xxl)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.extraLarge)
    }

    // MARK: - Actions
    func deleteExercise(_ exercise: Exercise) {
        AppTheme.Haptics.medium()
        withAnimation(AppTheme.Animation.spring) {
            modelContext.delete(exercise)
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                if isSelected && title != "Todos" {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                }

                Text(title)
                    .font(AppTheme.Typography.labelMedium())
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small)
            .background(isSelected ? color : AppTheme.Colors.surface)
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .cornerRadius(AppTheme.Radius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.pill)
                    .stroke(isSelected ? color.opacity(0.5) : AppTheme.Colors.surfaceBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Exercise List Card
struct ExerciseListCard: View {
    let exercise: Exercise
    let onDelete: () -> Void

    var muscleColor: Color {
        AppTheme.Colors.muscleColors[exercise.muscleGroup] ?? AppTheme.Colors.primary
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                    .fill(
                        LinearGradient(
                            colors: [muscleColor.opacity(0.3), muscleColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Text(String(exercise.name.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(muscleColor)
            }

            // Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(exercise.name)
                    .font(AppTheme.Typography.titleSmall())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                HStack(spacing: AppTheme.Spacing.small) {
                    Label(exercise.muscleGroup, systemImage: "figure.arms.open")
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(muscleColor)

                    Text("•")
                        .foregroundColor(AppTheme.Colors.textMuted)

                    Text(exercise.type)
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }

            Spacer()

            // Equipment badge
            Text(exercise.equipment)
                .font(AppTheme.Typography.labelSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.small)
                .padding(.vertical, AppTheme.Spacing.xxs)
                .background(AppTheme.Colors.surface)
                .cornerRadius(AppTheme.Radius.small)
        }
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.surfaceElevated)
        .cornerRadius(AppTheme.Radius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
        )
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Excluir", systemImage: "trash")
            }
        }
    }
}

#Preview {
    ExercisesView()
        .modelContainer(for: Exercise.self, inMemory: true)
}

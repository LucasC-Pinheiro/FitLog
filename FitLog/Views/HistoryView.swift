import SwiftUI
import SwiftData

// MARK: - History View
/// Histórico de treinos com design premium
/// Melhorias: Agrupamento por período, cards expandíveis,
/// estatísticas resumidas, animações suaves, melhor empty state
struct HistoryView: View {
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    @State private var isVisible = false
    @State private var selectedPeriod = "Todos"

    let periods = ["Todos", "Esta semana", "Este mês"]

    var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedPeriod {
        case "Esta semana":
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return workouts.filter { $0.date >= startOfWeek }
        case "Este mês":
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return workouts.filter { $0.date >= startOfMonth }
        default:
            return workouts
        }
    }

    var groupedByMonth: [String: [Workout]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "pt_BR")

        return Dictionary(grouping: filteredWorkouts) { workout in
            formatter.string(from: workout.date).capitalized
        }
    }

    var sortedMonths: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "pt_BR")

        return groupedByMonth.keys.sorted { key1, key2 in
            guard let date1 = formatter.date(from: key1.lowercased()),
                  let date2 = formatter.date(from: key2.lowercased()) else {
                return key1 > key2
            }
            return date1 > date2
        }
    }

    var totalDuration: Int {
        filteredWorkouts.reduce(0) { $0 + $1.duration }
    }

    var totalVolume: Double {
        filteredWorkouts.flatMap { $0.exercises }
            .flatMap { $0.sets }
            .reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()

                if workouts.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        // Period filter
                        periodFilter
                            .padding(.horizontal, AppTheme.Spacing.large)
                            .padding(.top, AppTheme.Spacing.medium)

                        // Stats summary
                        if !filteredWorkouts.isEmpty {
                            statsSummary
                                .padding(.horizontal, AppTheme.Spacing.large)
                                .padding(.top, AppTheme.Spacing.medium)
                        }

                        // Workouts list
                        workoutsList
                    }
                }
            }
            .navigationTitle("Histórico")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                withAnimation(AppTheme.Animation.smooth.delay(0.1)) {
                    isVisible = true
                }
            }
        }
    }

    // MARK: - Period Filter
    private var periodFilter: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            ForEach(periods, id: \.self) { period in
                Button(action: {
                    AppTheme.Haptics.selection()
                    withAnimation(AppTheme.Animation.spring) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period)
                        .font(AppTheme.Typography.labelMedium())
                        .padding(.horizontal, AppTheme.Spacing.medium)
                        .padding(.vertical, AppTheme.Spacing.small)
                        .background(selectedPeriod == period ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                        .foregroundColor(selectedPeriod == period ? .white : AppTheme.Colors.textSecondary)
                        .cornerRadius(AppTheme.Radius.pill)
                }
            }
            Spacer()
        }
    }

    // MARK: - Stats Summary
    private var statsSummary: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            MiniStatCard(
                icon: "flame.fill",
                value: "\(filteredWorkouts.count)",
                label: "treinos",
                color: AppTheme.Colors.streak
            )

            MiniStatCard(
                icon: "clock.fill",
                value: "\(totalDuration)",
                label: "min total",
                color: AppTheme.Colors.success
            )

            MiniStatCard(
                icon: "scalemass.fill",
                value: String(format: "%.0f", totalVolume / 1000),
                label: "ton",
                color: AppTheme.Colors.primary
            )
        }
    }

    // MARK: - Workouts List
    private var workoutsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: AppTheme.Spacing.medium, pinnedViews: .sectionHeaders) {
                ForEach(sortedMonths, id: \.self) { month in
                    Section {
                        ForEach(Array((groupedByMonth[month] ?? []).enumerated()), id: \.element.id) { index, workout in
                            HistoryCard(workout: workout) {
                                deleteWorkout(workout)
                            }
                            .staggeredAppear(index: index, isVisible: isVisible)
                        }
                    } header: {
                        monthHeader(month, count: groupedByMonth[month]?.count ?? 0)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.large)
            .padding(.top, AppTheme.Spacing.medium)
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
    }

    private func monthHeader(_ month: String, count: Int) -> some View {
        HStack {
            Text(month)
                .font(AppTheme.Typography.labelMedium())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text("(\(count) treinos)")
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

                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.Colors.primary)
            }

            VStack(spacing: AppTheme.Spacing.small) {
                Text("Nenhum treino registrado")
                    .font(AppTheme.Typography.titleLarge())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Complete seu primeiro treino e\nele aparecerá aqui")
                    .font(AppTheme.Typography.bodyMedium())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.extraLarge)
    }

    // MARK: - Actions
    func deleteWorkout(_ workout: Workout) {
        AppTheme.Haptics.medium()
        withAnimation(AppTheme.Animation.spring) {
            modelContext.delete(workout)
        }
    }
}

// MARK: - Mini Stat Card
struct MiniStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(AppTheme.Typography.titleSmall())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(label)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
        .padding(.vertical, AppTheme.Spacing.small)
        .background(color.opacity(0.1))
        .cornerRadius(AppTheme.Radius.medium)
    }
}

// MARK: - History Card
struct HistoryCard: View {
    let workout: Workout
    let onDelete: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            Button(action: {
                AppTheme.Haptics.light()
                withAnimation(AppTheme.Animation.spring) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: AppTheme.Spacing.medium) {
                    // Date badge
                    dateBadge

                    // Workout info
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                        HStack {
                            Text(workout.name)
                                .font(AppTheme.Typography.titleSmall())
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Spacer()

                            // Duration
                            HStack(spacing: AppTheme.Spacing.xxs) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10))
                                Text("\(workout.duration) min")
                                    .font(AppTheme.Typography.labelSmall())
                            }
                            .foregroundColor(AppTheme.Colors.success)
                            .padding(.horizontal, AppTheme.Spacing.small)
                            .padding(.vertical, AppTheme.Spacing.xxs)
                            .background(AppTheme.Colors.successDim)
                            .cornerRadius(AppTheme.Radius.small)
                        }

                        Text("\(workout.exercises.count) exercício\(workout.exercises.count == 1 ? "" : "s")")
                            .font(AppTheme.Typography.caption())
                            .foregroundColor(AppTheme.Colors.textSecondary)

                        // Muscle groups chips
                        if !workout.exercises.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppTheme.Spacing.xxs) {
                                    let muscles = Set(workout.exercises.map { $0.exercise.muscleGroup })
                                    ForEach(Array(muscles).prefix(4), id: \.self) { muscle in
                                        Text(muscle)
                                            .font(AppTheme.Typography.caption())
                                            .foregroundColor(AppTheme.Colors.muscleColors[muscle] ?? AppTheme.Colors.primary)
                                            .padding(.horizontal, AppTheme.Spacing.xs)
                                            .padding(.vertical, 2)
                                            .background((AppTheme.Colors.muscleColors[muscle] ?? AppTheme.Colors.primary).opacity(0.15))
                                            .cornerRadius(AppTheme.Radius.xs)
                                    }
                                }
                            }
                        }
                    }

                    // Expand indicator
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textMuted)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(AppTheme.Spacing.medium)
            }

            // Expanded content
            if isExpanded {
                expandedContent
            }
        }
        .background(AppTheme.Colors.surfaceElevated)
        .cornerRadius(AppTheme.Radius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
        )
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Excluir treino", systemImage: "trash")
            }
        }
    }

    private var dateBadge: some View {
        VStack(spacing: 2) {
            Text(workout.date.formatted(.dateTime.month(.abbreviated).locale(Locale(identifier: "pt_BR"))))
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textTertiary)
                .textCase(.uppercase)

            Text(workout.date.formatted(.dateTime.day()))
                .font(AppTheme.Typography.statSmall())
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .frame(width: 50)
        .padding(.vertical, AppTheme.Spacing.small)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.Radius.medium)
    }

    private var expandedContent: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Divider()
                .background(AppTheme.Colors.surfaceBorder)
                .padding(.horizontal, AppTheme.Spacing.medium)

            ForEach(workout.exercises) { we in
                HStack {
                    Circle()
                        .fill(AppTheme.Colors.muscleColors[we.exercise.muscleGroup] ?? AppTheme.Colors.primary)
                        .frame(width: 6, height: 6)

                    Text(we.exercise.name)
                        .font(AppTheme.Typography.bodySmall())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Spacer()

                    Text("\(we.sets.count) séries")
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                .padding(.horizontal, AppTheme.Spacing.medium)
            }
        }
        .padding(.bottom, AppTheme.Spacing.medium)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: Workout.self, inMemory: true)
}

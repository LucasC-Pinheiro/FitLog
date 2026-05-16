import SwiftUI
import SwiftData
import Charts

// MARK: - Progress View
/// Tela de progresso com gráficos premium
/// Melhorias: Cards de métricas, gráficos animados, seleção visual,
/// empty state melhorado, melhor organização de dados
struct ProgressView: View {
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Query private var exercises: [Exercise]
    @State private var selectedExercise: Exercise?
    @State private var isVisible = false

    var progressData: [(date: Date, weight: Double)] {
        guard let exercise = selectedExercise else { return [] }
        var data: [(date: Date, weight: Double)] = []

        for workout in workouts {
            for we in workout.exercises {
                if we.exercise.id == exercise.id {
                    let maxWeight = we.sets.map { $0.weight }.max() ?? 0
                    if maxWeight > 0 {
                        data.append((date: workout.date, weight: maxWeight))
                    }
                }
            }
        }
        return data.sorted { $0.date < $1.date }
    }

    var personalRecord: Double {
        progressData.map { $0.weight }.max() ?? 0
    }

    var averageWeight: Double {
        guard !progressData.isEmpty else { return 0 }
        return progressData.map { $0.weight }.reduce(0, +) / Double(progressData.count)
    }

    var improvement: Double {
        guard progressData.count >= 2 else { return 0 }
        let first = progressData.first?.weight ?? 0
        let last = progressData.last?.weight ?? 0
        guard first > 0 else { return 0 }
        return ((last - first) / first) * 100
    }

    var weeklyVolume: [(week: String, volume: Double)] {
        let calendar = Calendar.current
        var volumeByWeek: [String: Double] = [:]

        for workout in workouts.prefix(30) {
            let week = calendar.component(.weekOfYear, from: workout.date)
            let key = "S\(week)"
            let volume = workout.exercises.flatMap { $0.sets }.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
            volumeByWeek[key, default: 0] += volume
        }

        return volumeByWeek.sorted { $0.key < $1.key }.suffix(8).map { (week: $0.key, volume: $0.value) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()

                if exercises.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppTheme.Spacing.extraLarge) {
                            // Exercise selector
                            exerciseSelector
                                .staggeredAppear(index: 0, isVisible: isVisible)

                            if selectedExercise != nil {
                                // Personal Record Card
                                if personalRecord > 0 {
                                    personalRecordCard
                                        .staggeredAppear(index: 1, isVisible: isVisible)
                                }

                                // Stats Row
                                if !progressData.isEmpty {
                                    statsRow
                                        .staggeredAppear(index: 2, isVisible: isVisible)
                                }

                                // Weight Progress Chart
                                if !progressData.isEmpty {
                                    weightProgressChart
                                        .staggeredAppear(index: 3, isVisible: isVisible)
                                }

                                // Volume Chart
                                if !weeklyVolume.isEmpty {
                                    volumeChart
                                        .staggeredAppear(index: 4, isVisible: isVisible)
                                }

                                // No data state
                                if progressData.isEmpty {
                                    noDataState
                                        .staggeredAppear(index: 1, isVisible: isVisible)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.large)
                        .padding(.top, AppTheme.Spacing.medium)
                        .padding(.bottom, AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("Progresso")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                if selectedExercise == nil {
                    selectedExercise = exercises.first
                }
                withAnimation(AppTheme.Animation.smooth.delay(0.1)) {
                    isVisible = true
                }
            }
        }
    }

    // MARK: - Exercise Selector
    private var exerciseSelector: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            SectionHeader(title: "Selecione um exercício")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.small) {
                    ForEach(exercises) { exercise in
                        ExerciseChip(
                            exercise: exercise,
                            isSelected: selectedExercise?.id == exercise.id
                        ) {
                            AppTheme.Haptics.selection()
                            withAnimation(AppTheme.Animation.spring) {
                                selectedExercise = exercise
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Personal Record Card
    private var personalRecordCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(AppTheme.Colors.warning)

                    Text("RECORDE PESSOAL")
                        .font(AppTheme.Typography.labelSmall())
                        .foregroundColor(AppTheme.Colors.warning)
                        .textCase(.uppercase)
                }

                if let exercise = selectedExercise {
                    Text(exercise.name)
                        .font(AppTheme.Typography.bodyMedium())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.xxs) {
                    Text(String(format: "%.1f", personalRecord))
                        .font(AppTheme.Typography.statLarge())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text("kg")
                        .font(AppTheme.Typography.titleMedium())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.Colors.warningDim)
                    .frame(width: 70, height: 70)

                Image(systemName: "crown.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.Colors.warning)
            }
        }
        .padding(AppTheme.Spacing.extraLarge)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.xxl)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.warning.opacity(0.2),
                                AppTheme.Colors.primary.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: AppTheme.Radius.xxl)
                    .fill(AppTheme.Gradients.glassBackground)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.xxl)
                .stroke(AppTheme.Colors.warning.opacity(0.3), lineWidth: 1)
        )
        .shadow(AppTheme.Shadows.medium)
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            ProgressStatCard(
                title: "Média",
                value: String(format: "%.1f", averageWeight),
                unit: "kg",
                icon: "chart.bar.fill",
                color: AppTheme.Colors.primary
            )

            ProgressStatCard(
                title: "Evolução",
                value: String(format: "%.0f", improvement),
                unit: "%",
                icon: improvement >= 0 ? "arrow.up.right" : "arrow.down.right",
                color: improvement >= 0 ? AppTheme.Colors.success : AppTheme.Colors.danger
            )

            ProgressStatCard(
                title: "Sessões",
                value: "\(progressData.count)",
                unit: "",
                icon: "calendar",
                color: AppTheme.Colors.accent
            )
        }
    }

    // MARK: - Weight Progress Chart
    private var weightProgressChart: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            SectionHeader(title: "Evolução do peso máximo", subtitle: "kg por sessão")

            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
                    .fill(AppTheme.Colors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
                            .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
                    )

                Chart(progressData, id: \.date) { item in
                    LineMark(
                        x: .value("Data", item.date),
                        y: .value("Peso", item.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary, AppTheme.Colors.primaryLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))

                    AreaMark(
                        x: .value("Data", item.date),
                        y: .value("Peso", item.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary.opacity(0.3), AppTheme.Colors.primary.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    PointMark(
                        x: .value("Data", item.date),
                        y: .value("Peso", item.weight)
                    )
                    .foregroundStyle(AppTheme.Colors.primary)
                    .symbolSize(50)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                        AxisGridLine().foregroundStyle(AppTheme.Colors.surfaceBorder)
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated), centered: true)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(AppTheme.Colors.surfaceBorder)
                        AxisValueLabel()
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
                .frame(height: 220)
                .padding(AppTheme.Spacing.large)
            }
        }
    }

    // MARK: - Volume Chart
    private var volumeChart: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            SectionHeader(title: "Volume semanal", subtitle: "kg total levantado")

            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
                    .fill(AppTheme.Colors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
                            .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
                    )

                Chart(weeklyVolume, id: \.week) { item in
                    BarMark(
                        x: .value("Semana", item.week),
                        y: .value("Volume", item.volume)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.accent, AppTheme.Colors.accent.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(AppTheme.Radius.xs)
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(AppTheme.Colors.surfaceBorder)
                        AxisValueLabel()
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
                .frame(height: 180)
                .padding(AppTheme.Spacing.large)
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.extraLarge) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryDim)
                    .frame(width: 120, height: 120)

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.Colors.primary)
            }

            VStack(spacing: AppTheme.Spacing.small) {
                Text("Acompanhe seu progresso")
                    .font(AppTheme.Typography.titleLarge())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Crie exercícios e complete treinos\npara visualizar sua evolução")
                    .font(AppTheme.Typography.bodyMedium())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.extraLarge)
    }

    // MARK: - No Data State
    private var noDataState: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.surface)
                    .frame(width: 80, height: 80)

                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.Colors.textMuted)
            }

            VStack(spacing: AppTheme.Spacing.xxs) {
                Text("Sem dados para este exercício")
                    .font(AppTheme.Typography.titleSmall())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Complete treinos com este exercício\npara ver seu progresso")
                    .font(AppTheme.Typography.bodySmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxl)
        .glassCard()
    }
}

// MARK: - Exercise Chip
struct ExerciseChip: View {
    let exercise: Exercise
    let isSelected: Bool
    let action: () -> Void

    var muscleColor: Color {
        AppTheme.Colors.muscleColors[exercise.muscleGroup] ?? AppTheme.Colors.primary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Circle()
                    .fill(isSelected ? Color.white : muscleColor)
                    .frame(width: 8, height: 8)

                Text(exercise.name)
                    .font(AppTheme.Typography.labelMedium())
                    .lineLimit(1)
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small)
            .background(isSelected ? muscleColor : AppTheme.Colors.surface)
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .cornerRadius(AppTheme.Radius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.pill)
                    .stroke(isSelected ? muscleColor : AppTheme.Colors.surfaceBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Progress Stat Card
struct ProgressStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(AppTheme.Typography.titleLarge())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                if !unit.isEmpty {
                    Text(unit)
                        .font(AppTheme.Typography.labelSmall())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }

            Text(title)
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.large)
        .background(color.opacity(0.1))
        .cornerRadius(AppTheme.Radius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ProgressView()
        .modelContainer(for: Workout.self, inMemory: true)
}

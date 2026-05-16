import SwiftUI
import SwiftData

// MARK: - Home View

struct HomeView: View {
    @State private var showingWorkout = false
    @Query private var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    @AppStorage("userName") private var userName = "Atleta"
    @AppStorage("weeklyGoal") private var weeklyGoal = 4

    // Animation states
    @State private var isVisible = false
    @State private var showContent = false

    var motivationalPhrase: String {
        let phrases = [
            "Cada série te deixa mais forte",
            "O progresso é a vitória",
            "Seu corpo agradece o esforço",
            "Hoje é dia de quebrar recordes",
            "Consistência é a chave",
            "Você é mais forte do que pensa",
            "Cada repetição conta",
            "Vamo bombar!",
            "Seu futuro self vai agradecer",
            "Treinar é se amar",
            "Dor hoje, ganho amanhã",
            "Você não é igual a ontem"
        ]
        return phrases.randomElement() ?? "Vamo treinar!"
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Bom dia"
        case 12..<18: return "Boa tarde"
        default: return "Boa noite"
        }
    }

    var totalThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return workouts.filter { $0.date >= startOfWeek }.count
    }

    var weeklyProgress: Double {
        min(Double(totalThisWeek) / Double(weeklyGoal), 1.0)
    }

    var currentStreak: Int {
        guard !workouts.isEmpty else { return 0 }
        let sorted = workouts.sorted { $0.date > $1.date }
        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: Date())

        for workout in sorted {
            let workoutDay = Calendar.current.startOfDay(for: workout.date)
            if workoutDay == checkDate {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate)!
            } else if workoutDay < checkDate {
                break
            }
        }
        return streak
    }

    var lastWorkout: Workout? {
        workouts.sorted { $0.date > $1.date }.first
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundView

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.extraLarge) {
                        // Header
                        headerSection
                            .staggeredAppear(index: 0, isVisible: showContent)

                        // Streak & Progress Card
                        streakCard
                            .staggeredAppear(index: 1, isVisible: showContent)

                        // Stats Row
                        statsRow
                            .staggeredAppear(index: 2, isVisible: showContent)

                        // Last Workout or Empty State
                        lastWorkoutSection
                            .staggeredAppear(index: 3, isVisible: showContent)

                        // Start Workout Button
                        startWorkoutButton
                            .staggeredAppear(index: 4, isVisible: showContent)
                    }
                    .padding(.horizontal, AppTheme.Spacing.large)
                    .padding(.top, AppTheme.Spacing.medium)
                    .padding(.bottom, AppTheme.Spacing.xxxl)
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
            .onAppear {
                withAnimation(AppTheme.Animation.smooth.delay(0.1)) {
                    showContent = true
                }
            }
            .sheet(isPresented: $showingWorkout) {
                WorkoutView()
            }
        }
    }

    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            // Gradient orbs
            Circle()
                .fill(AppTheme.Colors.primary.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: -50, y: -100)

            Circle()
                .fill(AppTheme.Colors.accent.opacity(0.05))
                .frame(width: 200, height: 200)
                .blur(radius: 80)
                .offset(x: 150, y: 300)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("\(greeting),")
                    .font(AppTheme.Typography.bodyMedium())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                Text(userName)
                    .font(AppTheme.Typography.headline())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(motivationalPhrase)
                    .font(AppTheme.Typography.bodySmall())
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .padding(.top, AppTheme.Spacing.xxs)
            }

            Spacer()

            NavigationLink(destination: ProfileView()) {
                AvatarView(name: userName, size: 50)
            }
        }
    }

    // MARK: - Streak Card
    private var streakCard: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            // Top row: Streak info + Progress ring
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.streak)

                        Text("Sequência")
                            .font(AppTheme.Typography.labelMedium())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .textCase(.uppercase)
                    }

                    HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.xxs) {
                        Text("\(currentStreak)")
                            .font(AppTheme.Typography.statLarge())
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .contentTransition(.numericText())

                        Text(currentStreak == 1 ? "dia" : "dias")
                            .font(AppTheme.Typography.bodyMedium())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }

                Spacer()

                // Weekly progress ring
                VStack(spacing: AppTheme.Spacing.xs) {
                    ZStack {
                        ProgressRing(
                            progress: weeklyProgress,
                            lineWidth: 6,
                            size: 56,
                            gradientColors: [AppTheme.Colors.primary, AppTheme.Colors.primaryLight]
                        )

                        Text("\(totalThisWeek)/\(weeklyGoal)")
                            .font(AppTheme.Typography.labelSmall())
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }

                    Text("Esta semana")
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }

            // Week days
            weekDaysRow
        }
        .padding(AppTheme.Spacing.extraLarge)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.xxl)
                    .fill(AppTheme.Gradients.streakCard)

                RoundedRectangle(cornerRadius: AppTheme.Radius.xxl)
                    .fill(AppTheme.Gradients.glassBackground)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.xxl)
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.Colors.streak.opacity(0.3), AppTheme.Colors.primary.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(currentStreak > 0 ? AppTheme.Shadows.streakGlow : AppTheme.Shadows.medium)
    }

    private var weekDaysRow: some View {
        HStack(spacing: 0) {
            ForEach(weekDays(), id: \.3) { day, hasWorkout, isToday, _ in
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text(day)
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(isToday ? AppTheme.Colors.textPrimary : AppTheme.Colors.textMuted)

                    ZStack {
                        Circle()
                            .fill(
                                isToday ? AppTheme.Colors.primary :
                                    (hasWorkout ? AppTheme.Colors.primary.opacity(0.6) : AppTheme.Colors.surface)
                            )
                            .frame(width: 32, height: 32)

                        if hasWorkout {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        } else if isToday {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .shadow(isToday ? AppTheme.Shadows.glow : AppTheme.Shadows.small)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            StatCard(
                title: "Total",
                value: "\(workouts.count)",
                subtitle: "treinos",
                icon: "figure.strengthtraining.traditional",
                accentColor: AppTheme.Colors.primary
            )

            StatCard(
                title: "Recorde",
                value: "\(calculateBestStreak())",
                subtitle: "dias seguidos",
                icon: "trophy.fill",
                accentColor: AppTheme.Colors.warning
            )
        }
    }

    private func calculateBestStreak() -> Int {
        guard !workouts.isEmpty else { return 0 }
        let sorted = workouts.sorted { $0.date < $1.date }
        var bestStreak = 1
        var currentStreak = 1
        var previousDate: Date?

        for workout in sorted {
            let workoutDay = Calendar.current.startOfDay(for: workout.date)
            if let prev = previousDate {
                let dayDiff = Calendar.current.dateComponents([.day], from: prev, to: workoutDay).day ?? 0
                if dayDiff == 1 {
                    currentStreak += 1
                    bestStreak = max(bestStreak, currentStreak)
                } else if dayDiff > 1 {
                    currentStreak = 1
                }
            }
            previousDate = workoutDay
        }
        return bestStreak
    }

    // MARK: - Last Workout Section
    @ViewBuilder
    private var lastWorkoutSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            SectionHeader(title: "Último treino")

            if let last = lastWorkout {
                lastWorkoutCard(last)
            } else {
                emptyWorkoutState
            }
        }
    }

    private func lastWorkoutCard(_ workout: Workout) -> some View {
        HStack(spacing: AppTheme.Spacing.large) {
            // Workout info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(workout.name)
                    .font(AppTheme.Typography.titleMedium())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                HStack(spacing: AppTheme.Spacing.small) {
                    Label(
                        workout.date.formatted(date: .abbreviated, time: .omitted),
                        systemImage: "calendar"
                    )

                    Text("•")
                        .foregroundColor(AppTheme.Colors.textMuted)

                    Label(
                        "\(workout.exercises.count) exercícios",
                        systemImage: "dumbbell.fill"
                    )
                }
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textSecondary)

                // Muscle groups tags
                if !workout.exercises.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            let muscleGroups = Set(workout.exercises.map { $0.exercise.muscleGroup })
                            ForEach(Array(muscleGroups).prefix(3), id: \.self) { muscle in
                                ChipView(
                                    text: muscle,
                                    color: AppTheme.Colors.muscleColors[muscle] ?? AppTheme.Colors.primary
                                )
                            }
                        }
                    }
                    .padding(.top, AppTheme.Spacing.xxs)
                }
            }

            Spacer()

            // Completed indicator
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.successDim)
                    .frame(width: 48, height: 48)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.success)
            }
        }
        .padding(AppTheme.Spacing.large)
        .glassCard(cornerRadius: AppTheme.Radius.extraLarge)
    }

    private var emptyWorkoutState: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryDim)
                    .frame(width: 80, height: 80)

                Image(systemName: "figure.run")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primary)
            }

            VStack(spacing: AppTheme.Spacing.xs) {
                Text("Nenhum treino ainda")
                    .font(AppTheme.Typography.titleSmall())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Comece seu primeiro treino e\nacompanhe seu progresso!")
                    .font(AppTheme.Typography.bodySmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxl)
        .glassCard(cornerRadius: AppTheme.Radius.extraLarge)
    }

    // MARK: - Start Workout Button
    private var startWorkoutButton: some View {
        Button(action: {
            AppTheme.Haptics.medium()
            showingWorkout = true
        }) {
            HStack(spacing: AppTheme.Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text("Iniciar treino")
                        .font(AppTheme.Typography.titleMedium())
                        .foregroundColor(.white)

                    Text("Registre seus exercícios")
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(AppTheme.Spacing.large)
            .background(AppTheme.Gradients.primary)
            .cornerRadius(AppTheme.Radius.extraLarge)
            .shadow(AppTheme.Shadows.glowStrong)
        }
    }

    // MARK: - Helper Functions
    func weekDays() -> [(String, Bool, Bool, Int)] {
        let days = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sab", "Dom"]
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        // Convert Sunday=1 to Monday=1 format
        let adjustedToday = today == 1 ? 7 : today - 1
        let workoutDays = Set(workouts.compactMap { workout -> Int? in
            let weekday = calendar.component(.weekday, from: workout.date)
            return weekday == 1 ? 7 : weekday - 1
        })

        return days.enumerated().map { index, day in
            let dayNumber = index + 1
            return (day, workoutDays.contains(dayNumber), dayNumber == adjustedToday, index)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Workout.self, inMemory: true)
}

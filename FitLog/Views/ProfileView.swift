import SwiftUI
import SwiftData

// MARK: - Profile View
/// Perfil do usuário com design premium
/// Melhorias: Avatar animado, cards de stats modernos, conquistas visuais,
/// meta semanal interativa, volume total destacado, animações de entrada
struct ProfileView: View {
    @Query private var workouts: [Workout]
    @Query private var exercises: [Exercise]
    @AppStorage("userName") private var userName = "Atleta"
    @AppStorage("weeklyGoal") private var weeklyGoal = 4
    @State private var showingEditName = false
    @State private var tempName = ""
    @State private var isVisible = false

    var totalVolume: Double {
        workouts.flatMap { $0.exercises }.flatMap { $0.sets }.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
    }

    var totalDuration: Int {
        workouts.reduce(0) { $0 + $1.duration }
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

    var thisWeekCount: Int {
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return workouts.filter { $0.date >= startOfWeek }.count
    }

    var level: (name: String, icon: String, color: Color) {
        switch workouts.count {
        case 0..<5: return ("Iniciante", "leaf.fill", AppTheme.Colors.success)
        case 5..<20: return ("Intermediário", "flame.fill", AppTheme.Colors.warning)
        case 20..<50: return ("Avançado", "bolt.fill", AppTheme.Colors.primary)
        default: return ("Elite", "crown.fill", Color.yellow)
        }
    }

    var weeklyProgress: Double {
        min(Double(thisWeekCount) / Double(weeklyGoal), 1.0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundView

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.extraLarge) {
                        // Profile header
                        profileHeader
                            .staggeredAppear(index: 0, isVisible: isVisible)

                        // Stats cards
                        statsSection
                            .staggeredAppear(index: 1, isVisible: isVisible)

                        // Volume card
                        volumeCard
                            .staggeredAppear(index: 2, isVisible: isVisible)

                        // Weekly goal
                        weeklyGoalCard
                            .staggeredAppear(index: 3, isVisible: isVisible)

                        // Achievements
                        achievementsSection
                            .staggeredAppear(index: 4, isVisible: isVisible)
                    }
                    .padding(.horizontal, AppTheme.Spacing.large)
                    .padding(.top, AppTheme.Spacing.medium)
                    .padding(.bottom, AppTheme.Spacing.xxxl)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .onAppear {
                withAnimation(AppTheme.Animation.smooth.delay(0.1)) {
                    isVisible = true
                }
            }
            .alert("Seu nome", isPresented: $showingEditName) {
                TextField("Nome", text: $tempName)
                Button("Salvar") {
                    userName = tempName
                    AppTheme.Haptics.success()
                }
                Button("Cancelar", role: .cancel) { }
            }
        }
    }

    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            Circle()
                .fill(AppTheme.Colors.primary.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(y: -200)
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryGlow)
                    .frame(width: 110, height: 110)
                    .blur(radius: 20)

                Circle()
                    .fill(AppTheme.Gradients.primary)
                    .frame(width: 90, height: 90)

                Text(String(userName.prefix(1)).uppercased())
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(AppTheme.Shadows.glowStrong)

            // Name & Level
            VStack(spacing: AppTheme.Spacing.small) {
                Button(action: {
                    tempName = userName
                    showingEditName = true
                }) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(userName)
                            .font(AppTheme.Typography.headline())
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                }

                // Level badge
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: level.icon)
                        .foregroundColor(level.color)

                    Text(level.name)
                        .font(AppTheme.Typography.labelMedium())
                        .foregroundColor(level.color)
                }
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(level.color.opacity(0.15))
                .cornerRadius(AppTheme.Radius.pill)
            }
        }
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            ProfileStatBox(
                icon: "flame.fill",
                value: "\(workouts.count)",
                label: "Treinos",
                color: AppTheme.Colors.streak
            )

            ProfileStatBox(
                icon: "bolt.fill",
                value: "\(currentStreak)",
                label: "Sequência",
                color: AppTheme.Colors.primary
            )

            ProfileStatBox(
                icon: "clock.fill",
                value: "\(totalDuration)",
                label: "Min total",
                color: AppTheme.Colors.success
            )
        }
    }

    // MARK: - Volume Card
    private var volumeCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "scalemass.fill")
                        .foregroundColor(AppTheme.Colors.primary)

                    Text("VOLUME TOTAL")
                        .font(AppTheme.Typography.labelSmall())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .textCase(.uppercase)
                }

                HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.xxs) {
                    Text(String(format: "%.1f", totalVolume / 1000))
                        .font(AppTheme.Typography.statLarge())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text("toneladas")
                        .font(AppTheme.Typography.bodyMedium())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                Text("levantadas ao longo da sua jornada")
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryDim)
                    .frame(width: 60, height: 60)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.Colors.primary)
            }
        }
        .padding(AppTheme.Spacing.extraLarge)
        .glassCard(cornerRadius: AppTheme.Radius.xxl)
    }

    // MARK: - Weekly Goal Card
    private var weeklyGoalCard: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            // Header
            HStack {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "target")
                        .foregroundColor(AppTheme.Colors.primary)

                    Text("Meta Semanal")
                        .font(AppTheme.Typography.titleSmall())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }

                Spacer()

                Text("\(thisWeekCount)/\(weeklyGoal)")
                    .font(AppTheme.Typography.labelMedium())
                    .foregroundColor(weeklyProgress >= 1 ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.small)
                        .fill(AppTheme.Colors.surface)
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: AppTheme.Radius.small)
                        .fill(
                            weeklyProgress >= 1 ?
                            AppTheme.Gradients.successGradient :
                                AppTheme.Gradients.primary
                        )
                        .frame(width: geo.size.width * weeklyProgress, height: 10)
                        .animation(AppTheme.Animation.smooth, value: weeklyProgress)
                }
            }
            .frame(height: 10)

            // Goal stepper
            HStack {
                Text("Ajustar meta:")
                    .font(AppTheme.Typography.bodySmall())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                Spacer()

                HStack(spacing: AppTheme.Spacing.medium) {
                    Button(action: {
                        if weeklyGoal > 1 {
                            AppTheme.Haptics.selection()
                            weeklyGoal -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(weeklyGoal > 1 ? AppTheme.Colors.primary : AppTheme.Colors.textMuted)
                    }
                    .disabled(weeklyGoal <= 1)

                    Text("\(weeklyGoal)x")
                        .font(AppTheme.Typography.titleMedium())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(width: 40)

                    Button(action: {
                        if weeklyGoal < 7 {
                            AppTheme.Haptics.selection()
                            weeklyGoal += 1
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(weeklyGoal < 7 ? AppTheme.Colors.primary : AppTheme.Colors.textMuted)
                    }
                    .disabled(weeklyGoal >= 7)
                }
            }
        }
        .padding(AppTheme.Spacing.extraLarge)
        .background(AppTheme.Colors.surfaceElevated)
        .cornerRadius(AppTheme.Radius.extraLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
                .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
        )
    }

    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            SectionHeader(title: "Conquistas", subtitle: "\(unlockedCount)/6 desbloqueadas")

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.medium) {
                AchievementCard(
                    icon: "figure.walk",
                    title: "Primeiro Treino",
                    description: "Complete 1 treino",
                    unlocked: workouts.count >= 1
                )

                AchievementCard(
                    icon: "flame.fill",
                    title: "Em Chamas",
                    description: "3 dias seguidos",
                    unlocked: currentStreak >= 3
                )

                AchievementCard(
                    icon: "bolt.fill",
                    title: "10 Treinos",
                    description: "Complete 10 treinos",
                    unlocked: workouts.count >= 10
                )

                AchievementCard(
                    icon: "star.fill",
                    title: "25 Treinos",
                    description: "Complete 25 treinos",
                    unlocked: workouts.count >= 25
                )

                AchievementCard(
                    icon: "trophy.fill",
                    title: "50 Treinos",
                    description: "Complete 50 treinos",
                    unlocked: workouts.count >= 50
                )

                AchievementCard(
                    icon: "crown.fill",
                    title: "Lenda",
                    description: "Complete 100 treinos",
                    unlocked: workouts.count >= 100
                )
            }
        }
    }

    var unlockedCount: Int {
        var count = 0
        if workouts.count >= 1 { count += 1 }
        if currentStreak >= 3 { count += 1 }
        if workouts.count >= 10 { count += 1 }
        if workouts.count >= 25 { count += 1 }
        if workouts.count >= 50 { count += 1 }
        if workouts.count >= 100 { count += 1 }
        return count
    }
}

// MARK: - Profile Stat Box
struct ProfileStatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)

            Text(value)
                .font(AppTheme.Typography.statSmall())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(label)
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textTertiary)
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

// MARK: - Achievement Card
struct AchievementCard: View {
    let icon: String
    let title: String
    let description: String
    let unlocked: Bool

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            ZStack {
                Circle()
                    .fill(unlocked ? AppTheme.Colors.primaryDim : AppTheme.Colors.surface)
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(unlocked ? AppTheme.Colors.primary : AppTheme.Colors.textMuted)
                    .scaleEffect(unlocked && isAnimating ? 1.1 : 1)
            }
            .shadow(unlocked ? AppTheme.Shadows.glow : AppTheme.Shadows.small)

            Text(title)
                .font(AppTheme.Typography.labelSmall())
                .foregroundColor(unlocked ? AppTheme.Colors.textPrimary : AppTheme.Colors.textMuted)
                .lineLimit(1)

            Text(description)
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.medium)
        .padding(.horizontal, AppTheme.Spacing.small)
        .background(unlocked ? AppTheme.Colors.primaryDim.opacity(0.3) : AppTheme.Colors.surface)
        .cornerRadius(AppTheme.Radius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .stroke(
                    unlocked ? AppTheme.Colors.primary.opacity(0.3) : AppTheme.Colors.surfaceBorder,
                    lineWidth: 1
                )
        )
        .onAppear {
            if unlocked {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: Workout.self, inMemory: true)
}

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var workouts: [Workout]
    @Query private var exercises: [Exercise]
    @AppStorage("userName") private var userName = "Atleta"
    @AppStorage("weeklyGoal") private var weeklyGoal = 4
    @State private var showingEditName = false
    @State private var tempName = ""

    var totalVolume: Double {
        workouts.flatMap { $0.exercises }.flatMap { $0.sets }.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
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
            } else { break }
        }
        return streak
    }

    var thisWeekCount: Int {
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return workouts.filter { $0.date >= startOfWeek }.count
    }

    var level: String {
        switch workouts.count {
        case 0..<5: return "Iniciante"
        case 5..<20: return "Intermediário"
        case 20..<50: return "Avançado"
        default: return "Elite"
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        VStack(spacing: 12) {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.purple, .purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(String(userName.prefix(1)).uppercased())
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .shadow(color: .purple.opacity(0.4), radius: 12)

                            Button(action: {
                                tempName = userName
                                showingEditName = true
                            }) {
                                HStack(spacing: 6) {
                                    Text(userName)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                    Image(systemName: AppIcons.edit)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }

                            HStack(spacing: 4) {
                                Image(systemName: AppIcons.levelUp)
                                    .foregroundColor(.yellow)
                                Text(level)
                            }
                            .font(.system(size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(AppTheme.Colors.primaryDim)
                            .foregroundColor(AppTheme.Colors.primary)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(AppTheme.Colors.primaryGlow, lineWidth: 1)
                            )
                        }
                        .padding(.top, 8)

                        HStack(spacing: 12) {
                            ProfileStatCard(icon: AppIcons.gym, value: "\(workouts.count)", label: "Treinos")
                            ProfileStatCard(icon: AppIcons.streak, value: "\(currentStreak)", label: "Sequência")
                            ProfileStatCard(icon: AppIcons.trophy, value: "\(exercises.count)", label: "Exercícios")
                        }
                        .padding(.horizontal)

                        ZStack {
                            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                                .fill(AppTheme.Colors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                                        .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
                                )
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Volume total levantado")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Text("\(totalVolume / 1000, specifier: "%.1f") toneladas")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Image(systemName: AppIcons.gym)
                                    .font(.system(size: 36))
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            .padding(AppTheme.Spacing.large)
                        }
                        .padding(.horizontal)

                        ZStack {
                            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                                .fill(AppTheme.Colors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                                        .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
                                )

                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    HStack(spacing: 4) {
                                        Image(systemName: AppIcons.target)
                                            .foregroundColor(AppTheme.Colors.primary)
                                        Text("Meta semanal")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    Spacer()
                                    Text("\(thisWeekCount)/\(weeklyGoal) treinos")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white.opacity(0.08))
                                            .frame(height: 8)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(LinearGradient(
                                                colors: [.purple, .purple.opacity(0.7)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ))
                                            .frame(width: geo.size.width * min(Double(thisWeekCount) / Double(weeklyGoal), 1.0), height: 8)
                                    }
                                }
                                .frame(height: 8)

                                HStack {
                                    Text("Ajustar meta:")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Stepper("\(weeklyGoal)x por semana", value: $weeklyGoal, in: 1...7)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(AppTheme.Spacing.large)
                        }
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 4) {
                                Image(systemName: AppIcons.trophy)
                                    .foregroundColor(.yellow)
                                Text("Conquistas")
                            }
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                AchievementBadge(icon: AppIcons.gym, title: "Primeiro Treino", unlocked: workouts.count >= 1)
                                AchievementBadge(icon: AppIcons.streak, title: "3 dias seguidos", unlocked: currentStreak >= 3)
                                AchievementBadge(icon: "bolt.fill", title: "10 treinos", unlocked: workouts.count >= 10)
                                AchievementBadge(icon: AppIcons.gym, title: "25 treinos", unlocked: workouts.count >= 25)
                                AchievementBadge(icon: AppIcons.trophy, title: "50 treinos", unlocked: workouts.count >= 50)
                                AchievementBadge(icon: "crown.fill", title: "100 treinos", unlocked: workouts.count >= 100)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .alert("Seu nome", isPresented: $showingEditName) {
                TextField("Nome", text: $tempName)
                Button("Salvar") { userName = tempName }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }
}

struct ProfileStatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .fill(AppTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                        .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
                )
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.primary)
                Text(value)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(unlocked ? AppTheme.Colors.primary : .gray.opacity(0.3))
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(unlocked ? .white : .gray.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(unlocked ? AppTheme.Colors.primaryDim : AppTheme.Colors.surface)
        .cornerRadius(AppTheme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                .stroke(unlocked ? AppTheme.Colors.primaryGlow : AppTheme.Colors.surfaceBorder, lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: Workout.self, inMemory: true)
}

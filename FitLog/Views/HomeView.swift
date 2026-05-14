import SwiftUI
import SwiftData

struct HomeView: View {
    @state private var showingWorkout = false
    @Query private var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    
    var totalThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return workouts.filter { $0.date >= startOfWeek }.count
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
            } else {
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
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // greeting
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bom dia 👋")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Text("FitLog")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Circle()
                                .fill(LinearGradient(colors: [.purple, .purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text("F")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        .padding(.horizontal)
                        
                        // streak card
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(colors: [Color.purple.opacity(0.4), Color.purple.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🔥 Sequência atual")
                                    .font(.system(size: 12))
                                    .foregroundColor(.purple.opacity(0.8))
                                Text("\(currentStreak) dias")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                // week days
                                HStack(spacing: 6) {
                                    ForEach(weekDays(), id: \.0) { day, hasWorkout, isToday in
                                        VStack(spacing: 4) {
                                            Circle()
                                                .fill(isToday ? Color.purple : (hasWorkout ? Color.purple.opacity(0.6) : Color.white.opacity(0.1)))
                                                .frame(width: 28, height: 28)
                                                .overlay(
                                                    Text(day)
                                                        .font(.system(size: 9, weight: .bold))
                                                        .foregroundColor(.white)
                                                )
                                                .shadow(color: isToday ? .purple : .clear, radius: 4)
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        
                        // stats row
                        HStack(spacing: 12) {
                            StatCard(title: "Esta semana", value: "\(totalThisWeek)", subtitle: "treinos")
                            StatCard(title: "Total", value: "\(workouts.count)", subtitle: "treinos")
                        }
                        .padding(.horizontal)
                        
                        // last workout
                        if let last = lastWorkout {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Último treino")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                        )
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(last.name)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                            Text(last.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                            Text("\(last.exercises.count) exercícios")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text("✓")
                                            .font(.system(size: 20))
                                            .foregroundColor(.green)
                                            .padding(10)
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                    .padding(16)
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                VStack(spacing: 8) {
                                    Text("🏋️")
                                        .font(.system(size: 32))
                                    Text("Nenhum treino ainda")
                                        .foregroundColor(.gray)
                                    Text("Comece seu primeiro treino!")
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                .padding(24)
                            }
                            .padding(.horizontal)
                        }
                        
                        // start workout button
                        Button(action: { showingWorkout = true}) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Iniciar treino")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.purple)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showingWorkout){
                            WorkoutView()
                        }
                        
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
        }
    }
    
    func weekDays() -> [(String, Bool, Bool)] {
        let days = ["S", "T", "Q", "Q", "S", "S", "D"]
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        let workoutDays = Set(workouts.map { calendar.component(.weekday, from: $0.date) })
        
        return days.enumerated().map { index, day in
            let weekday = index + 1
            return (day, workoutDays.contains(weekday), weekday == today)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Workout.self, inMemory: true)
}

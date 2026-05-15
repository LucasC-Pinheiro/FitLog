import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Query private var exercises: [Exercise]
    @State private var selectedExercise: Exercise?

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

    var weeklyVolume: [(week: String, volume: Double)] {
        let calendar = Calendar.current
        var volumeByWeek: [String: Double] = [:]

        for workout in workouts.prefix(20) {
            let week = calendar.component(.weekOfYear, from: workout.date)
            let year = calendar.component(.year, from: workout.date)
            let key = "\(year)-W\(week)"
            let volume = workout.exercises.flatMap { $0.sets }.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
            volumeByWeek[key, default: 0] += volume
        }

        return volumeByWeek.sorted { $0.key < $1.key }.suffix(6).map { (week: $0.key, volume: $0.value) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exercício")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(exercises) { exercise in
                                        Button(action: { selectedExercise = exercise }) {
                                            Text(exercise.name)
                                                .font(.system(size: 13, weight: .medium))
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 7)
                                                .background(selectedExercise?.id == exercise.id ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                                                .foregroundColor(.white)
                                                .cornerRadius(20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        if let exercise = selectedExercise, personalRecord > 0 {
                            ZStack {
                                RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
                                    .fill(LinearGradient(
                                        colors: [Color.purple.opacity(0.4), Color.purple.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.Radius.extraLarge)
                                            .stroke(AppTheme.Colors.primaryGlow, lineWidth: 1)
                                    )

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Image(systemName: AppIcons.trophy)
                                                .foregroundColor(.yellow)
                                            Text("Recorde pessoal")
                                        }
                                        .font(.system(size: 12))
                                        .foregroundColor(.purple.opacity(0.8))
                                        Text(exercise.name)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("\(personalRecord, specifier: "%.1f") kg")
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    Image(systemName: AppIcons.gym)
                                        .font(.system(size: 40))
                                        .foregroundColor(AppTheme.Colors.primary)
                                }
                                .padding(20)
                            }
                            .padding(.horizontal)
                        }

                        if !progressData.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Evolução do peso máximo")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)

                                ZStack {
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                                        .fill(AppTheme.Colors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                                                .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
                                        )

                                    Chart(progressData, id: \.date) { item in
                                        LineMark(
                                            x: .value("Data", item.date),
                                            y: .value("Peso", item.weight)
                                        )
                                        .foregroundStyle(AppTheme.Colors.primary)
                                        .lineStyle(StrokeStyle(lineWidth: 2))

                                        AreaMark(
                                            x: .value("Data", item.date),
                                            y: .value("Peso", item.weight)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color.purple.opacity(0.3), Color.purple.opacity(0)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )

                                        PointMark(
                                            x: .value("Data", item.date),
                                            y: .value("Peso", item.weight)
                                        )
                                        .foregroundStyle(AppTheme.Colors.primary)
                                        .symbolSize(40)
                                    }
                                    .chartXAxis {
                                        AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                                            AxisGridLine().foregroundStyle(Color.white.opacity(0.05))
                                            AxisValueLabel(format: .dateTime.day().month(), centered: true)
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks { value in
                                            AxisGridLine().foregroundStyle(Color.white.opacity(0.05))
                                            AxisValueLabel()
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                    .frame(height: 200)
                                    .padding()
                                }
                                .padding(.horizontal)
                            }
                        }

                        if !weeklyVolume.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Volume semanal (kg)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)

                                ZStack {
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                                        .fill(AppTheme.Colors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                                                .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
                                        )

                                    Chart(weeklyVolume, id: \.week) { item in
                                        BarMark(
                                            x: .value("Semana", item.week),
                                            y: .value("Volume", item.volume)
                                        )
                                        .foregroundStyle(AppTheme.Colors.primary.gradient)
                                        .cornerRadius(4)
                                    }
                                    .chartXAxis {
                                        AxisMarks { _ in
                                            AxisValueLabel()
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks { _ in
                                            AxisGridLine().foregroundStyle(Color.white.opacity(0.05))
                                            AxisValueLabel()
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                    .frame(height: 160)
                                    .padding()
                                }
                                .padding(.horizontal)
                            }
                        }

                        if exercises.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Nenhum dado ainda")
                                    .foregroundColor(.gray)
                                Text("Complete alguns treinos para ver seu progresso!")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Progresso")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .onAppear {
                if selectedExercise == nil {
                    selectedExercise = exercises.first
                }
            }
        }
    }
}

#Preview {
    ProgressView()
        .modelContainer(for: Workout.self, inMemory: true)
}

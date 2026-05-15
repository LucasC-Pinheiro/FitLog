import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if workouts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.Colors.primary)
                        Text("Nenhum treino ainda")
                            .foregroundColor(.gray)
                        Text("Complete seu primeiro treino!")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                } else {
                    List {
                        ForEach(workouts) { workout in
                            HistoryRow(workout: workout)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .onDelete(perform: deleteWorkouts)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Histórico")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
    }

    func deleteWorkouts(offsets: IndexSet) {
        for index in offsets {
            let workout = workouts[index]
            modelContext.delete(workout)
        }
    }
}

struct HistoryRow: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(workout.date.formatted(.dateTime.month(.abbreviated).locale(Locale(identifier: "pt_BR"))))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                Text(workout.date.formatted(.dateTime.day()))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 44)
            .padding(.vertical, 8)
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.Radius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                    .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(workout.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: AppIcons.clock)
                            .font(.system(size: 10))
                        Text("\(workout.duration) min")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.Colors.success.opacity(0.12))
                    .foregroundColor(AppTheme.Colors.success)
                    .cornerRadius(8)
                }

                Text("\(workout.exercises.count) exercício\(workout.exercises.count == 1 ? "" : "s")")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                if !workout.exercises.isEmpty {
                    Text(workout.exercises.prefix(3).map { $0.exercise.name }.joined(separator: " · "))
                        .font(.system(size: 11))
                        .foregroundColor(.gray.opacity(0.7))
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.Radius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
        )
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: Workout.self, inMemory: true)
}

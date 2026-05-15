import SwiftUI

// MARK: - StatCard
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .fill(AppTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                        .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
                )
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.vertical, AppTheme.Spacing.large)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ExerciseRow
struct ExerciseRow: View {
    let exercise: Exercise

    var muscleColor: Color {
        AppTheme.Colors.muscleColors[exercise.muscleGroup] ?? .gray
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                .fill(muscleColor.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(exercise.name.prefix(1)))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(muscleColor)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text("\(exercise.muscleGroup) · \(exercise.type)")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()

            Text(exercise.equipment)
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.surface)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .cornerRadius(AppTheme.Radius.small)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - WorkoutExerciseCard
struct WorkoutExerciseCard: View {
    @Bindable var workoutExercise: WorkoutExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(workoutExercise.exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Text(workoutExercise.exercise.muscleGroup)
                    .font(.system(size: 11))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primaryDim)
                    .foregroundColor(AppTheme.Colors.primary)
                    .cornerRadius(AppTheme.Radius.small)
            }

            HStack {
                Text("Série").frame(width: 36)
                Text("KG").frame(maxWidth: .infinity)
                Text("Reps").frame(maxWidth: .infinity)
                Text("✓").frame(width: 28)
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(AppTheme.Colors.textSecondary)

            ForEach(Array(workoutExercise.sets.enumerated()), id: \.offset) { index, set in
                SetRow(set: set, index: index + 1)
            }

            Button(action: {
                workoutExercise.sets.append(ExerciseSet(weight: 0, reps: 0))
            }) {
                Text("+ série")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.primary)
            }
        }
        .padding(14)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.Radius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
        )
    }
}

// MARK: - SetRow
struct SetRow: View {
    @Bindable var set: ExerciseSet
    let index: Int

    var body: some View {
        HStack {
            Text("\(index)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .frame(width: 36)

            TextField("0", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.07))
                .cornerRadius(AppTheme.Radius.small)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity)

            TextField("0", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.07))
                .cornerRadius(AppTheme.Radius.small)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity)

            Button(action: { set.isCompleted.toggle() }) {
                Circle()
                    .fill(set.isCompleted ? AppTheme.Colors.success : Color.white.opacity(0.1))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(set.isCompleted ? 1 : 0.3)
                    )
            }
            .frame(width: 28)
        }
    }
}

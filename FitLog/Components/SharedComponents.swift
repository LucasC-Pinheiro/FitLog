import SwiftUI

// MARK: - Premium Button
/// Botão primário com gradiente, glow e feedback tátil
struct PremiumButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let isLoading: Bool
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
        case ghost
    }

    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            AppTheme.Haptics.medium()
            action()
        }) {
            HStack(spacing: AppTheme.Spacing.small) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(AppTheme.Typography.titleSmall())
                }
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.large)
            .background(backgroundView)
            .cornerRadius(AppTheme.Radius.large)
            .overlay(overlayView)
        }
        .disabled(isLoading)
        .pressEffect(isPressed: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .shadow(style == .primary ? AppTheme.Shadows.glow : AppTheme.Shadows.small)
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            AppTheme.Gradients.primary
        case .secondary:
            AppTheme.Colors.surfaceElevated
        case .ghost:
            Color.clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .ghost:
            return AppTheme.Colors.primary
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch style {
        case .primary:
            EmptyView()
        case .secondary:
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
        case .ghost:
            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - Premium Text Field
/// Campo de texto estilizado com label flutuante
struct PremiumTextField: View {
    let placeholder: String
    let icon: String?
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isFocused ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                    .frame(width: 24)
                    .animation(AppTheme.Animation.quick, value: isFocused)
            }

            TextField(placeholder, text: $text)
                .font(AppTheme.Typography.bodyLarge())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .keyboardType(keyboardType)
                .focused($isFocused)
        }
        .padding(.horizontal, AppTheme.Spacing.large)
        .padding(.vertical, AppTheme.Spacing.medium + 2)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                .fill(AppTheme.Colors.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                .stroke(
                    isFocused ? AppTheme.Colors.primary : AppTheme.Colors.surfaceBorder,
                    lineWidth: isFocused ? 2 : 1
                )
                .animation(AppTheme.Animation.quick, value: isFocused)
        )
    }
}

// MARK: - Stat Card (Premium)
/// Card de estatística com visual glassmorphism
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    var icon: String? = nil
    var accentColor: Color = AppTheme.Colors.primary
    var showGlow: Bool = false

    @State private var isVisible = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentColor)
                    .padding(.bottom, AppTheme.Spacing.xxs)
            }

            Text(title)
                .font(AppTheme.Typography.labelSmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text(value)
                .font(AppTheme.Typography.statMedium())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .contentTransition(.numericText())

            Text(subtitle)
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .padding(.vertical, AppTheme.Spacing.extraLarge)
        .padding(.horizontal, AppTheme.Spacing.medium)
        .frame(maxWidth: .infinity)
        .glassCard()
        .shadow(showGlow ? AppTheme.Shadows.glow : AppTheme.Shadows.small)
        .scaleEffect(isVisible ? 1 : 0.9)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(AppTheme.Animation.springBouncy) {
                isVisible = true
            }
        }
    }
}

// MARK: - Exercise Row (Premium)
/// Row de exercício com visual refinado
struct ExerciseRow: View {
    let exercise: Exercise

    var muscleColor: Color {
        AppTheme.Colors.muscleColors[exercise.muscleGroup] ?? AppTheme.Colors.textSecondary
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            // Icon container with gradient
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                    .fill(
                        LinearGradient(
                            colors: [muscleColor.opacity(0.3), muscleColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Text(String(exercise.name.prefix(1)))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(muscleColor)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(exercise.name)
                    .font(AppTheme.Typography.titleSmall())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                HStack(spacing: AppTheme.Spacing.xs) {
                    Text(exercise.muscleGroup)
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(muscleColor)

                    Circle()
                        .fill(AppTheme.Colors.textMuted)
                        .frame(width: 3, height: 3)

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
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}

// MARK: - Workout Exercise Card (Premium)
/// Card de exercício durante treino com visual premium
struct WorkoutExerciseCard: View {
    @Bindable var workoutExercise: WorkoutExercise

    var muscleColor: Color {
        AppTheme.Colors.muscleColors[workoutExercise.exercise.muscleGroup] ?? AppTheme.Colors.primary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text(workoutExercise.exercise.name)
                        .font(AppTheme.Typography.titleMedium())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text(workoutExercise.exercise.equipment)
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }

                Spacer()

                Text(workoutExercise.exercise.muscleGroup)
                    .font(AppTheme.Typography.labelSmall())
                    .padding(.horizontal, AppTheme.Spacing.small)
                    .padding(.vertical, AppTheme.Spacing.xxs)
                    .background(muscleColor.opacity(0.15))
                    .foregroundColor(muscleColor)
                    .cornerRadius(AppTheme.Radius.small)
            }

            // Column headers
            HStack {
                Text("Série")
                    .frame(width: 40, alignment: .leading)
                Text("KG")
                    .frame(maxWidth: .infinity)
                Text("Reps")
                    .frame(maxWidth: .infinity)
                Text("")
                    .frame(width: 32)
            }
            .font(AppTheme.Typography.labelSmall())
            .foregroundColor(AppTheme.Colors.textMuted)
            .textCase(.uppercase)

            // Sets
            ForEach(Array(workoutExercise.sets.enumerated()), id: \.offset) { index, set in
                SetRow(set: set, index: index + 1)
            }

            // Add set button
            Button(action: {
                AppTheme.Haptics.light()
                withAnimation(AppTheme.Animation.spring) {
                    workoutExercise.sets.append(ExerciseSet(weight: 0, reps: 0))
                }
            }) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Adicionar série")
                        .font(AppTheme.Typography.labelMedium())
                }
                .foregroundColor(AppTheme.Colors.primary)
                .padding(.top, AppTheme.Spacing.xs)
            }
        }
        .padding(AppTheme.Spacing.large)
        .glassCard()
    }
}

// MARK: - Set Row (Premium)
/// Row de série com inputs estilizados
struct SetRow: View {
    @Bindable var set: ExerciseSet
    let index: Int

    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            // Set number
            Text("\(index)")
                .font(AppTheme.Typography.labelLarge())
                .foregroundColor(set.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                .frame(width: 40, alignment: .leading)

            // Weight input
            TextField("0", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(AppTheme.Typography.bodyMedium())
                .padding(.vertical, AppTheme.Spacing.small)
                .background(AppTheme.Colors.surfaceElevated)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .cornerRadius(AppTheme.Radius.small)
                .frame(maxWidth: .infinity)

            // Reps input
            TextField("0", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(AppTheme.Typography.bodyMedium())
                .padding(.vertical, AppTheme.Spacing.small)
                .background(AppTheme.Colors.surfaceElevated)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .cornerRadius(AppTheme.Radius.small)
                .frame(maxWidth: .infinity)

            // Complete button
            Button(action: {
                AppTheme.Haptics.success()
                withAnimation(AppTheme.Animation.springBouncy) {
                    set.isCompleted.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(set.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.surfaceElevated)
                        .frame(width: 32, height: 32)

                    Circle()
                        .stroke(
                            set.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.surfaceBorder,
                            lineWidth: 2
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(set.isCompleted ? 1 : 0.3)
                        .scaleEffect(set.isCompleted ? 1 : 0.8)
                }
            }
            .shadow(set.isCompleted ? AppTheme.Shadows.successGlow : AppTheme.Shadows.small)
        }
        .padding(.vertical, AppTheme.Spacing.xxs)
    }
}

// MARK: - Empty State View
/// Estado vazio com visual premium e animação
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.extraLarge) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryDim)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.1 : 1)
                    .opacity(isAnimating ? 0.5 : 0.8)

                Circle()
                    .fill(AppTheme.Colors.primaryDim)
                    .frame(width: 80, height: 80)

                Image(systemName: icon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }

            VStack(spacing: AppTheme.Spacing.small) {
                Text(title)
                    .font(AppTheme.Typography.titleLarge())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(AppTheme.Typography.bodyMedium())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                PremiumButton(title: actionTitle, icon: "plus", action: action)
                    .padding(.horizontal, AppTheme.Spacing.xxl)
            }
        }
        .padding(AppTheme.Spacing.xxl)
    }
}

// MARK: - Section Header
/// Header de seção com estilo premium
struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var action: (() -> Void)? = nil
    var actionLabel: String = "Ver todos"

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(title)
                    .font(AppTheme.Typography.titleMedium())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }

            Spacer()

            if let action = action {
                Button(action: action) {
                    HStack(spacing: AppTheme.Spacing.xxs) {
                        Text(actionLabel)
                            .font(AppTheme.Typography.labelMedium())
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
    }
}

// MARK: - Avatar View
/// Avatar do usuário com gradiente
struct AvatarView: View {
    let name: String
    var size: CGFloat = 44

    var initials: String {
        String(name.prefix(1)).uppercased()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Gradients.primary)
                .frame(width: size, height: size)

            Text(initials)
                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .shadow(AppTheme.Shadows.small)
    }
}

// MARK: - Streak Badge
/// Badge de sequência com efeito glow
struct StreakBadge: View {
    let days: Int
    var isCompact: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xxs) {
            Image(systemName: "flame.fill")
                .font(.system(size: isCompact ? 12 : 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.streak)

            Text("\(days)")
                .font(isCompact ? AppTheme.Typography.labelMedium() : AppTheme.Typography.titleSmall())
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(.horizontal, AppTheme.Spacing.small)
        .padding(.vertical, AppTheme.Spacing.xxs)
        .background(AppTheme.Colors.streakGlow)
        .cornerRadius(AppTheme.Radius.pill)
        .shadow(AppTheme.Shadows.streakGlow)
    }
}

// MARK: - Progress Ring
/// Anel de progresso animado
struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    var lineWidth: CGFloat = 8
    var size: CGFloat = 60
    var gradientColors: [Color] = [AppTheme.Colors.primary, AppTheme.Colors.primaryLight]

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(AppTheme.Colors.surface, lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: gradientColors,
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
        }
        .onAppear {
            withAnimation(AppTheme.Animation.smooth.delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(AppTheme.Animation.smooth) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Chip / Tag
/// Tag ou chip para categorias
struct ChipView: View {
    let text: String
    var color: Color = AppTheme.Colors.primary
    var isSelected: Bool = false

    var body: some View {
        Text(text)
            .font(AppTheme.Typography.labelSmall())
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.xs)
            .background(isSelected ? color : color.opacity(0.15))
            .cornerRadius(AppTheme.Radius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.pill)
                    .stroke(color.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
    }
}

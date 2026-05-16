import SwiftUI

// MARK: - Onboarding View
/// Tela de onboarding premium com animações e visual moderno
/// Problema anterior: Onboarding básico com apenas emoji, sem personalidade
/// Melhoria: Visual impactante com gradientes, animações de entrada,
/// seletor de meta semanal e melhor hierarquia visual
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var userName = ""
    @State private var weeklyGoal = 4
    @State private var currentStep = 0

    // Animation states
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var showParticles = false

    private let totalSteps = 2

    var body: some View {
        ZStack {
            // Background with gradient
            backgroundView

            // Floating particles
            if showParticles {
                FloatingParticlesView()
            }

            // Content
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                    .padding(.top, AppTheme.Spacing.large)

                Spacer()

                // Step content with animation
                Group {
                    if currentStep == 0 {
                        welcomeStep
                    } else {
                        goalStep
                    }
                }
                .opacity(contentOpacity)
                .offset(y: contentOffset)

                Spacer()

                // Bottom action area
                bottomArea
                    .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .padding(.horizontal, AppTheme.Spacing.extraLarge)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            // Gradient orbs
            Circle()
                .fill(AppTheme.Colors.primary.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -100, y: -200)

            Circle()
                .fill(AppTheme.Colors.accent.opacity(0.1))
                .frame(width: 250, height: 250)
                .blur(radius: 60)
                .offset(x: 150, y: 100)

            // Subtle grid pattern
            GeometryReader { geometry in
                Path { path in
                    let spacing: CGFloat = 40
                    for x in stride(from: 0, to: geometry.size.width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    for y in stride(from: 0, to: geometry.size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.02), lineWidth: 0.5)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                    .frame(width: step == currentStep ? 24 : 8, height: 8)
                    .animation(AppTheme.Animation.spring, value: currentStep)
            }
        }
    }

    // MARK: - Welcome Step
    private var welcomeStep: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            // Logo
            logoView

            // Welcome text
            VStack(spacing: AppTheme.Spacing.medium) {
                Text("Bem-vindo ao")
                    .font(AppTheme.Typography.titleLarge())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                Text("FitLog")
                    .font(AppTheme.Typography.displayLarge())
                    .foregroundStyle(AppTheme.Gradients.primary)

                Text("Transforme seus treinos em resultados.\nAcompanhe cada série, cada progresso.")
                    .font(AppTheme.Typography.bodyMedium())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, AppTheme.Spacing.small)
            }

            // Name input
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("Como podemos te chamar?")
                    .font(AppTheme.Typography.labelMedium())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                PremiumTextField(
                    placeholder: "Seu nome",
                    icon: "person.fill",
                    text: $userName
                )
            }
            .padding(.top, AppTheme.Spacing.extraLarge)
        }
    }

    // MARK: - Goal Step
    private var goalStep: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            // Goal icon
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryDim)
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(AppTheme.Gradients.primary)
                    .frame(width: 90, height: 90)

                Image(systemName: "target")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
            .shadow(AppTheme.Shadows.glowStrong)

            // Goal text
            VStack(spacing: AppTheme.Spacing.medium) {
                Text("Olá, \(userName)!")
                    .font(AppTheme.Typography.headline())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Qual é sua meta semanal?")
                    .font(AppTheme.Typography.titleLarge())
                    .foregroundColor(AppTheme.Colors.textSecondary)

                Text("Defina quantos treinos você quer fazer por semana")
                    .font(AppTheme.Typography.bodySmall())
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }

            // Goal selector
            goalSelector
                .padding(.top, AppTheme.Spacing.large)
        }
    }

    // MARK: - Goal Selector
    private var goalSelector: some View {
        VStack(spacing: AppTheme.Spacing.extraLarge) {
            // Visual display
            HStack(spacing: AppTheme.Spacing.medium) {
                ForEach(1...7, id: \.self) { day in
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Circle()
                            .fill(day <= weeklyGoal ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(day <= weeklyGoal ? 1 : 0)
                            )
                            .shadow(day <= weeklyGoal ? AppTheme.Shadows.glow : AppTheme.Shadows.small)

                        Text(dayLabel(day))
                            .font(AppTheme.Typography.caption())
                            .foregroundColor(day <= weeklyGoal ? AppTheme.Colors.textPrimary : AppTheme.Colors.textMuted)
                    }
                    .onTapGesture {
                        AppTheme.Haptics.selection()
                        withAnimation(AppTheme.Animation.spring) {
                            weeklyGoal = day
                        }
                    }
                }
            }

            // Slider
            VStack(spacing: AppTheme.Spacing.small) {
                Slider(value: Binding(
                    get: { Double(weeklyGoal) },
                    set: { weeklyGoal = Int($0) }
                ), in: 1...7, step: 1)
                .tint(AppTheme.Colors.primary)

                HStack {
                    Text("1 dia")
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textMuted)
                    Spacer()
                    Text("7 dias")
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.small)

            // Goal message
            goalMessage
        }
    }

    private var goalMessage: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: goalMessageIcon)
                .font(.system(size: 20))
                .foregroundColor(goalMessageColor)

            Text(goalMessageText)
                .font(AppTheme.Typography.bodySmall())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(AppTheme.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(goalMessageColor.opacity(0.1))
        .cornerRadius(AppTheme.Radius.medium)
    }

    private var goalMessageIcon: String {
        switch weeklyGoal {
        case 1...2: return "leaf.fill"
        case 3...4: return "flame.fill"
        case 5...6: return "bolt.fill"
        default: return "star.fill"
        }
    }

    private var goalMessageColor: Color {
        switch weeklyGoal {
        case 1...2: return AppTheme.Colors.success
        case 3...4: return AppTheme.Colors.primary
        case 5...6: return AppTheme.Colors.warning
        default: return AppTheme.Colors.streak
        }
    }

    private var goalMessageText: String {
        switch weeklyGoal {
        case 1...2: return "Ótimo começo! Consistência é a chave."
        case 3...4: return "Meta equilibrada! Ideal para progressão."
        case 5...6: return "Intenso! Lembre-se de descansar."
        default: return "Atleta dedicado! Máxima performance."
        }
    }

    private func dayLabel(_ day: Int) -> String {
        let labels = ["S", "T", "Q", "Q", "S", "S", "D"]
        return labels[day - 1]
    }

    // MARK: - Logo View
    private var logoView: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(AppTheme.Colors.primaryGlow)
                .frame(width: 140, height: 140)
                .blur(radius: 30)

            // Main circle
            Circle()
                .fill(AppTheme.Gradients.primary)
                .frame(width: 100, height: 100)

            // Icon
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(.white)
                .rotationEffect(.degrees(-30))
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
    }

    // MARK: - Bottom Area
    private var bottomArea: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            PremiumButton(
                title: currentStep == totalSteps - 1 ? "Começar a treinar" : "Continuar",
                icon: currentStep == totalSteps - 1 ? "arrow.right" : nil
            ) {
                handleContinue()
            }
            .disabled(!canContinue)
            .opacity(canContinue ? 1 : 0.5)

            if currentStep > 0 {
                Button(action: handleBack) {
                    Text("Voltar")
                        .font(AppTheme.Typography.labelMedium())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
    }

    private var canContinue: Bool {
        switch currentStep {
        case 0:
            return !userName.trimmingCharacters(in: .whitespaces).isEmpty
        default:
            return true
        }
    }

    // MARK: - Actions
    private func handleContinue() {
        AppTheme.Haptics.medium()

        if currentStep < totalSteps - 1 {
            withAnimation(AppTheme.Animation.smooth) {
                contentOpacity = 0
                contentOffset = -30
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentStep += 1
                withAnimation(AppTheme.Animation.smooth) {
                    contentOpacity = 1
                    contentOffset = 0
                }
            }
        } else {
            completeOnboarding()
        }
    }

    private func handleBack() {
        AppTheme.Haptics.light()

        withAnimation(AppTheme.Animation.smooth) {
            contentOpacity = 0
            contentOffset = 30
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentStep -= 1
            withAnimation(AppTheme.Animation.smooth) {
                contentOpacity = 1
                contentOffset = 0
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(weeklyGoal, forKey: "weeklyGoal")

        AppTheme.Haptics.success()

        withAnimation(AppTheme.Animation.smooth) {
            hasCompletedOnboarding = true
        }
    }

    private func startAnimations() {
        withAnimation(AppTheme.Animation.springBouncy.delay(0.2)) {
            logoScale = 1
            logoOpacity = 1
        }

        withAnimation(AppTheme.Animation.smooth.delay(0.5)) {
            contentOpacity = 1
            contentOffset = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showParticles = true
        }
    }
}

// MARK: - Floating Particles View
/// Partículas flutuantes para efeito visual premium
struct FloatingParticlesView: View {
    let particleCount = 20

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<particleCount, id: \.self) { index in
                FloatingParticle(
                    size: geometry.size,
                    delay: Double(index) * 0.1
                )
            }
        }
        .ignoresSafeArea()
    }
}

struct FloatingParticle: View {
    let size: CGSize
    let delay: Double

    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0

    var body: some View {
        Circle()
            .fill(AppTheme.Colors.primary.opacity(0.3))
            .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
            .position(position)
            .opacity(opacity)
            .blur(radius: 1)
            .onAppear {
                position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )

                withAnimation(.easeInOut(duration: Double.random(in: 3...6)).repeatForever(autoreverses: true).delay(delay)) {
                    position = CGPoint(
                        x: CGFloat.random(in: 0...size.width),
                        y: CGFloat.random(in: 0...size.height)
                    )
                    opacity = Double.random(in: 0.2...0.5)
                }
            }
    }
}

#Preview {
    OnboardingView()
}

import SwiftUI

// MARK: - Content View
/// Tab bar principal com navegação premium
/// Melhorias: Tab bar estilizada, botão de treino central destacado,
/// animações de transição, feedback háptico
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingWorkout = false
    @State private var previousTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)

                HistoryView()
                    .tag(1)

                // Placeholder for center button
                Color.clear
                    .tag(2)

                ProgressView()
                    .tag(3)

                ExercisesView()
                    .tag(4)
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == 2 {
                    // Center button pressed - show workout
                    AppTheme.Haptics.medium()
                    showingWorkout = true
                    selectedTab = previousTab
                } else {
                    AppTheme.Haptics.light()
                    previousTab = newValue
                }
            }

            // Custom tab bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingWorkout) {
            WorkoutView()
        }
    }

    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            // Home
            TabBarButton(
                icon: "house.fill",
                label: "Início",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            // History
            TabBarButton(
                icon: "clock.fill",
                label: "Histórico",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            // Center workout button
            CenterWorkoutButton {
                AppTheme.Haptics.medium()
                showingWorkout = true
            }

            // Progress
            TabBarButton(
                icon: "chart.line.uptrend.xyaxis",
                label: "Progresso",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }

            // Exercises
            TabBarButton(
                icon: "dumbbell.fill",
                label: "Exercícios",
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
        }
        .padding(.horizontal, AppTheme.Spacing.small)
        .padding(.top, AppTheme.Spacing.medium)
        .padding(.bottom, AppTheme.Spacing.small)
        .background(
            ZStack {
                // Blur background
                Rectangle()
                    .fill(.ultraThinMaterial)

                // Gradient overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.background.opacity(0.9),
                                AppTheme.Colors.background.opacity(0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Top border
                VStack {
                    Rectangle()
                        .fill(AppTheme.Colors.surfaceBorder)
                        .frame(height: 0.5)
                    Spacer()
                }
            }
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.textMuted)
                    .scaleEffect(isSelected ? 1.1 : 1)
                    .animation(AppTheme.Animation.spring, value: isSelected)

                Text(label)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.textMuted)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Center Workout Button
struct CenterWorkoutButton: View {
    let action: () -> Void

    @State private var isPressed = false
    @State private var isPulsing = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(AppTheme.Colors.primaryGlow)
                    .frame(width: 70, height: 70)
                    .scaleEffect(isPulsing ? 1.1 : 1)
                    .opacity(isPulsing ? 0.5 : 0.3)

                // Main button
                Circle()
                    .fill(AppTheme.Gradients.primary)
                    .frame(width: 56, height: 56)
                    .shadow(AppTheme.Shadows.glow)

                // Plus icon
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressed ? 0.9 : 1)
            .animation(AppTheme.Animation.spring, value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .offset(y: -20)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    ContentView()
}

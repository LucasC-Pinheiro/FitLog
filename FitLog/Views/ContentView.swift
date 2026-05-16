import SwiftUI

// MARK: - Content View
/// Navegação principal usando TabView nativa do iOS
/// Abordagem: TabView nativa estilizada sem conflitos de blur/material
struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showingWorkout = false

    enum Tab: Int, CaseIterable {
        case home = 0
        case history = 1
        case workout = 2
        case progress = 3
        case exercises = 4

        var title: String {
            switch self {
            case .home: return "Início"
            case .history: return "Histórico"
            case .workout: return "Treino"
            case .progress: return "Progresso"
            case .exercises: return "Exercícios"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .history: return "clock.fill"
            case .workout: return "plus.circle.fill"
            case .progress: return "chart.line.uptrend.xyaxis"
            case .exercises: return "dumbbell.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.title, systemImage: Tab.home.icon)
                }
                .tag(Tab.home)

            HistoryView()
                .tabItem {
                    Label(Tab.history.title, systemImage: Tab.history.icon)
                }
                .tag(Tab.history)

            // Placeholder view for workout tab
            WorkoutPlaceholderView()
                .tabItem {
                    Label(Tab.workout.title, systemImage: Tab.workout.icon)
                }
                .tag(Tab.workout)

            ProgressView()
                .tabItem {
                    Label(Tab.progress.title, systemImage: Tab.progress.icon)
                }
                .tag(Tab.progress)

            ExercisesView()
                .tabItem {
                    Label(Tab.exercises.title, systemImage: Tab.exercises.icon)
                }
                .tag(Tab.exercises)
        }
        .tint(AppTheme.Colors.primary)
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .workout {
                // Intercept workout tab and show sheet instead
                AppTheme.Haptics.medium()
                showingWorkout = true
                // Return to previous tab
                selectedTab = oldValue
            } else {
                AppTheme.Haptics.light()
            }
        }
        .sheet(isPresented: $showingWorkout) {
            WorkoutView()
        }
    }
}

// MARK: - Workout Placeholder View
/// Placeholder para o tab de treino (nunca será exibido)
struct WorkoutPlaceholderView: View {
    var body: some View {
        Color.clear
    }
}

#Preview {
    ContentView()
}

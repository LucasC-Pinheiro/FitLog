import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingWorkout = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Início", systemImage: "house.fill") }
                .tag(0)

            Color.clear
                .tabItem { Label("Treino", systemImage: "plus.circle.fill") }
                .tag(1)

            HistoryView()
                .tabItem { Label("Histórico", systemImage: "list.bullet") }
                .tag(2)

            ProgressView()
                .tabItem { Label("Progresso", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(3)

            ExercisesView()
                .tabItem { Label("Exercícios", systemImage: "dumbbell.fill") }
                .tag(4)
        }
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 1 {
                showingWorkout = true
                selectedTab = 0
            }
        }
        .sheet(isPresented: $showingWorkout) {
            WorkoutView()
        }
    }
}

#Preview {
    ContentView()
}

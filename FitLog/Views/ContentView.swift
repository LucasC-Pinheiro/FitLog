import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Início", systemImage: "house.fill")
                }
            
            Text("Novo Treino")
                .tabItem {
                    Label("Treino", systemImage: "plus.circle.fill")
                }
            
            Text("Histórico")
                .tabItem {
                    Label("Histórico", systemImage: "list.bullet")
                }
            
            Text("Progresso")
                .tabItem {
                    Label("Progresso", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            ExercisesView()
                .tabItem {
                    Label("Exercícios", systemImage: "dumbbell.fill")
                }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

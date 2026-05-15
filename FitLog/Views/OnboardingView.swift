import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var userName = ""
    @State private var weeklyGoal = 4

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // logo
                VStack(spacing: 16) {
                    Text("💪")
                        .font(.system(size: 72))
                    Text("FitLog")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    Text("Rastreie seu progresso na academia")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 60)

                Spacer()

                // form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Qual é o seu nome?")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        TextField("Digite seu nome", text: $userName)
                            .font(.system(size: 16))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .background(AppTheme.Colors.surface)
                            .cornerRadius(AppTheme.Radius.medium)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // botão começar
                Button(action: startApp) {
                    Text("Começar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.Radius.large)
                }
                .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(userName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
    }

    func startApp() {
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(weeklyGoal, forKey: "weeklyGoal")
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
}

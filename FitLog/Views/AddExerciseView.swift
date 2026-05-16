import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedMuscleGroup = "Peito"
    @State private var selectedEquipment = "Barra"
    @State private var selectedType = "Composto"

    let muscleGroups = ["Peito", "Costas", "Pernas", "Ombro", "Bíceps", "Tríceps", "Abdômen"]
    let equipments = ["Barra", "Halter", "Máquina", "Cabo", "Peso corporal", "Outro"]
    let types = ["Composto", "Isolado"]

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Nome
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nome do exercício")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray)

                            TextField("Ex: Supino Reto", text: $name)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(14)
                                .background(AppTheme.Colors.surface)
                                .cornerRadius(AppTheme.Radius.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                                        .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
                                )
                        }

                        // Grupo Muscular
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Grupo muscular")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(muscleGroups, id: \.self) { group in
                                    Button(action: { selectedMuscleGroup = group }) {
                                        Text(group)
                                            .font(.system(size: 13, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(selectedMuscleGroup == group ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                                            .foregroundColor(.white)
                                            .cornerRadius(AppTheme.Radius.medium)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                                                    .stroke(selectedMuscleGroup == group ? AppTheme.Colors.primaryGlow : AppTheme.Colors.surfaceBorder, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }

                        // Equipamento
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Equipamento")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(equipments, id: \.self) { equipment in
                                    Button(action: { selectedEquipment = equipment }) {
                                        Text(equipment)
                                            .font(.system(size: 13, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(selectedEquipment == equipment ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                                            .foregroundColor(.white)
                                            .cornerRadius(AppTheme.Radius.medium)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                                                    .stroke(selectedEquipment == equipment ? AppTheme.Colors.primaryGlow : AppTheme.Colors.surfaceBorder, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }

                        // Tipo
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray)

                            HStack(spacing: 8) {
                                ForEach(types, id: \.self) { type in
                                    Button(action: { selectedType = type }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: type == "Composto" ? "figure.strengthtraining.traditional" : "figure.arms.open")
                                                .font(.system(size: 24))
                                                .foregroundColor(selectedType == type ? .white : .gray)
                                            Text(type)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(selectedType == type ? .white : .gray)
                                            Text(type == "Composto" ? "Múltiplos grupos" : "Um grupo")
                                                .font(.system(size: 10))
                                                .foregroundColor(selectedType == type ? .white.opacity(0.7) : .gray.opacity(0.5))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(selectedType == type ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                                        .cornerRadius(AppTheme.Radius.large)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                                                .stroke(selectedType == type ? AppTheme.Colors.primaryGlow : AppTheme.Colors.surfaceBorder, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }

                        // Botão salvar
                        Button(action: saveExercise) {
                            HStack(spacing: 8) {
                                Image(systemName: AppIcons.checkmark)
                                Text("Criar exercício")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSave ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                            .cornerRadius(AppTheme.Radius.large)
                        }
                        .disabled(!canSave)
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationTitle("Novo Exercício")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(AppTheme.Colors.danger)
                }
            }
        }
    }

    func saveExercise() {
        let exercise = Exercise(
            name: name.trimmingCharacters(in: .whitespaces),
            muscleGroup: selectedMuscleGroup,
            equipment: selectedEquipment,
            type: selectedType
        )
        modelContext.insert(exercise)
        dismiss()
    }
}

#Preview {
    AddExerciseView()
        .modelContainer(for: Exercise.self, inMemory: true)
}

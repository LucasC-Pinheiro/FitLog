import SwiftUI
import SwiftData

// MARK: - Add Exercise View
/// Formulário premium para criar novos exercícios
/// Melhorias: Layout visual melhorado, feedback animado,
/// seleção intuitiva com ícones, validação visual
struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedMuscleGroup = "Peito"
    @State private var selectedEquipment = "Barra"
    @State private var selectedType = "Composto"
    @State private var isVisible = false

    let muscleGroups = ["Peito", "Costas", "Pernas", "Ombro", "Bíceps", "Tríceps", "Abdômen", "Glúteos"]
    let equipments = ["Barra", "Halter", "Máquina", "Cabo", "Peso corporal", "Kettlebell", "Outro"]
    let types = ["Composto", "Isolado"]

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var selectedColor: Color {
        AppTheme.Colors.muscleColors[selectedMuscleGroup] ?? AppTheme.Colors.primary
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.extraLarge) {
                        // Preview card
                        previewCard
                            .staggeredAppear(index: 0, isVisible: isVisible)

                        // Name input
                        nameSection
                            .staggeredAppear(index: 1, isVisible: isVisible)

                        // Muscle group
                        muscleGroupSection
                            .staggeredAppear(index: 2, isVisible: isVisible)

                        // Equipment
                        equipmentSection
                            .staggeredAppear(index: 3, isVisible: isVisible)

                        // Type
                        typeSection
                            .staggeredAppear(index: 4, isVisible: isVisible)

                        // Save button
                        saveButton
                            .staggeredAppear(index: 5, isVisible: isVisible)
                    }
                    .padding(AppTheme.Spacing.large)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .navigationTitle("Novo Exercício")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("Cancelar")
                            .font(AppTheme.Typography.labelMedium())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
            .onAppear {
                withAnimation(AppTheme.Animation.smooth.delay(0.1)) {
                    isVisible = true
                }
            }
        }
    }

    // MARK: - Preview Card
    private var previewCard: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                    .fill(
                        LinearGradient(
                            colors: [selectedColor.opacity(0.3), selectedColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Text(name.isEmpty ? "?" : String(name.prefix(1)).uppercased())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(selectedColor)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(name.isEmpty ? "Nome do exercício" : name)
                    .font(AppTheme.Typography.titleMedium())
                    .foregroundColor(name.isEmpty ? AppTheme.Colors.textMuted : AppTheme.Colors.textPrimary)

                HStack(spacing: AppTheme.Spacing.small) {
                    Text(selectedMuscleGroup)
                        .foregroundColor(selectedColor)

                    Text("•")
                        .foregroundColor(AppTheme.Colors.textMuted)

                    Text(selectedEquipment)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                .font(AppTheme.Typography.caption())
            }

            Spacer()

            Text(selectedType)
                .font(AppTheme.Typography.labelSmall())
                .padding(.horizontal, AppTheme.Spacing.small)
                .padding(.vertical, AppTheme.Spacing.xxs)
                .background(selectedColor.opacity(0.15))
                .foregroundColor(selectedColor)
                .cornerRadius(AppTheme.Radius.small)
        }
        .padding(AppTheme.Spacing.large)
        .glassCard(cornerRadius: AppTheme.Radius.extraLarge)
    }

    // MARK: - Name Section
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            SectionLabel(title: "Nome do exercício", icon: "textformat")

            PremiumTextField(
                placeholder: "Ex: Supino Reto",
                icon: "dumbbell.fill",
                text: $name
            )
        }
    }

    // MARK: - Muscle Group Section
    private var muscleGroupSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            SectionLabel(title: "Grupo muscular", icon: "figure.arms.open")

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.small) {
                ForEach(muscleGroups, id: \.self) { group in
                    SelectableChip(
                        title: group,
                        isSelected: selectedMuscleGroup == group,
                        color: AppTheme.Colors.muscleColors[group] ?? AppTheme.Colors.primary
                    ) {
                        AppTheme.Haptics.selection()
                        withAnimation(AppTheme.Animation.quick) {
                            selectedMuscleGroup = group
                        }
                    }
                }
            }
        }
    }

    // MARK: - Equipment Section
    private var equipmentSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            SectionLabel(title: "Equipamento", icon: "wrench.and.screwdriver")

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.small) {
                ForEach(equipments, id: \.self) { equipment in
                    EquipmentCard(
                        title: equipment,
                        icon: equipmentIcon(for: equipment),
                        isSelected: selectedEquipment == equipment
                    ) {
                        AppTheme.Haptics.selection()
                        withAnimation(AppTheme.Animation.quick) {
                            selectedEquipment = equipment
                        }
                    }
                }
            }
        }
    }

    private func equipmentIcon(for equipment: String) -> String {
        switch equipment {
        case "Barra": return "minus.rectangle.fill"
        case "Halter": return "circle.lefthalf.filled"
        case "Máquina": return "gearshape.fill"
        case "Cabo": return "cable.connector"
        case "Peso corporal": return "figure.stand"
        case "Kettlebell": return "drop.fill"
        default: return "questionmark.circle.fill"
        }
    }

    // MARK: - Type Section
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            SectionLabel(title: "Tipo de exercício", icon: "tag.fill")

            HStack(spacing: AppTheme.Spacing.medium) {
                ForEach(types, id: \.self) { type in
                    TypeCard(
                        title: type,
                        subtitle: type == "Composto" ? "Múltiplos grupos" : "Um grupo muscular",
                        icon: type == "Composto" ? "figure.strengthtraining.traditional" : "figure.arms.open",
                        isSelected: selectedType == type
                    ) {
                        AppTheme.Haptics.selection()
                        withAnimation(AppTheme.Animation.quick) {
                            selectedType = type
                        }
                    }
                }
            }
        }
    }

    // MARK: - Save Button
    private var saveButton: some View {
        PremiumButton(
            title: "Criar exercício",
            icon: "checkmark.circle.fill"
        ) {
            saveExercise()
        }
        .disabled(!canSave)
        .opacity(canSave ? 1 : 0.5)
    }

    // MARK: - Actions
    func saveExercise() {
        guard canSave else { return }

        AppTheme.Haptics.success()

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

// MARK: - Section Label
struct SectionLabel: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.Colors.primary)

            Text(title)
                .font(AppTheme.Typography.labelMedium())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
        }
    }
}

// MARK: - Selectable Chip
struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.labelSmall())
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.medium)
                .background(isSelected ? color : AppTheme.Colors.surfaceElevated)
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                .cornerRadius(AppTheme.Radius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                        .stroke(isSelected ? color : AppTheme.Colors.surfaceBorder, lineWidth: 1)
                )
        }
    }
}

// MARK: - Equipment Card
struct EquipmentCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.small) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textTertiary)

                Text(title)
                    .font(AppTheme.Typography.labelMedium())
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
            .padding(AppTheme.Spacing.medium)
            .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surfaceElevated)
            .cornerRadius(AppTheme.Radius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.medium)
                    .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surfaceBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Type Card
struct TypeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.small) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textTertiary)

                Text(title)
                    .font(AppTheme.Typography.titleSmall())
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)

                Text(subtitle)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(isSelected ? .white.opacity(0.7) : AppTheme.Colors.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.large)
            .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surfaceElevated)
            .cornerRadius(AppTheme.Radius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.large)
                    .stroke(isSelected ? AppTheme.Colors.primaryGlow : AppTheme.Colors.surfaceBorder, lineWidth: isSelected ? 2 : 1)
            )
            .shadow(isSelected ? AppTheme.Shadows.glow : AppTheme.Shadows.small)
        }
    }
}

#Preview {
    AddExerciseView()
        .modelContainer(for: Exercise.self, inMemory: true)
}

import SwiftUI

struct ColorPickerSheet: View {
    let currentHex: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var selectedColor: Color
    
    private let pastels: [String] = [
        "#A8D8EA", "#AA96DA", "#FCBAD3", "#FFFFD2",
        "#B5EAD7", "#E2F0CB", "#FFDAC1", "#C7CEEA",
        "#F3E8FF", "#D1E8E4", "#FFE5E5", "#E8F4FD",
        "#F0E6FF", "#E6F2E6", "#FFF2E6", "#E6E6FA",
        "#F5E6CC", "#CCE5FF", "#FFCCCC", "#D4F1F4",
        "#DFE6E9", "#FFEAA7", "#DDA0DD", "#98D8C8",
    ]
    
    init(currentHex: String, onSave: @escaping (String) -> Void) {
        self.currentHex = currentHex
        self.onSave = onSave
        _selectedColor = State(initialValue: Color(hex: currentHex))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(colors: [selectedColor.opacity(0.7), selectedColor],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(height: 100)
                        .shadow(color: selectedColor.opacity(0.3), radius: 14, y: 6)
                        .overlay(
                            Image(systemName: "refrigerator.fill")
                                .font(.system(size: 36, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.3))
                        )
                        .padding(.horizontal, 24)
                    
                    // Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 6), spacing: 14) {
                        ForEach(pastels, id: \.self) { hex in
                            let isSelected = selectedColor.toHex().uppercased() == hex.uppercased()
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 46, height: 46)
                                .overlay(
                                    Circle().strokeBorder(Color.primary, lineWidth: isSelected ? 3 : 0)
                                )
                                .shadow(color: Color(hex: hex).opacity(0.4), radius: isSelected ? 6 : 3, y: 2)
                                .scaleEffect(isSelected ? 1.1 : 1.0)
                                .animation(.spring(response: 0.25), value: isSelected)
                                .onTapGesture {
                                    HapticManager.selection()
                                    selectedColor = Color(hex: hex)
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // System color picker
                    ColorPicker(appState.L("custom_color"), selection: $selectedColor, supportsOpacity: false)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .navigationTitle(appState.L("choose_color"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(appState.L("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(appState.L("save")) {
                        onSave(selectedColor.toHex())
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

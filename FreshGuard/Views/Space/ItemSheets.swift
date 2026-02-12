import SwiftUI

// MARK: - Add Item Sheet
struct AddItemSheet: View {
    let space: SpaceItem
    @ObservedObject var viewModel: SpaceViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName = ""
    @State private var expiryDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var selectedSection: SpaceSection?
    @FocusState private var nameFieldFocused: Bool
    
    init(space: SpaceItem, viewModel: SpaceViewModel) {
        self.space = space
        self.viewModel = viewModel
        _selectedSection = State(initialValue: space.defaultSection)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    nameField
                    
                    if space.type.hasSections {
                        sectionPicker
                    }
                    
                    if space.type.showsExpiryDate {
                        dateSection
                    }
                }
                .padding(24)
            }
            .navigationTitle(appState.L("add_item"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(appState.L("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(appState.L("confirm")) {
                        let trimmed = itemName.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        viewModel.addItem(
                            to: space.id,
                            name: trimmed,
                            expiryDate: space.type.showsExpiryDate ? expiryDate : nil,
                            section: selectedSection
                        )
                        dismiss()
                    }
                    .disabled(itemName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .onAppear { nameFieldFocused = true }
        }
    }
    
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel(appState.L("item_name"))
            
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(Color(hex: space.colorHex))
                    .font(.system(size: 14))
                TextField(appState.L("item_name_placeholder"), text: $itemName)
                    .font(.system(size: 17))
                    .focused($nameFieldFocused)
            }
            .padding(14)
            .background(fieldBackground)
        }
    }
    
    private var sectionPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel(appState.L("select_section"))
            HStack(spacing: 10) {
                ForEach(space.sections, id: \.self) { section in
                    Button {
                        HapticManager.selection()
                        selectedSection = section
                    } label: {
                        Text(appState.L(section.localizedKey))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(selectedSection == section ? .white : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 11)
                            .background(
                                Capsule().fill(selectedSection == section ? Color(hex: space.colorHex) : Color(.tertiarySystemBackground))
                            )
                    }
                }
            }
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel(appState.L("expiry_date_label"))
            
            DatePicker("", selection: $expiryDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.locale, appState.currentLanguage.calendarLocale)
                .tint(Color(hex: space.colorHex))
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground))
                )
            
            // Quick buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    quickBtn(appState.L("one_week")) { addToDate(days: 7) }
                    quickBtn(appState.L("two_weeks")) { addToDate(days: 14) }
                    quickBtn(appState.L("one_month")) { addToDate(months: 1) }
                    quickBtn(appState.L("three_months")) { addToDate(months: 3) }
                    quickBtn(appState.L("six_months")) { addToDate(months: 6) }
                    quickBtn(appState.L("one_year")) { addToDate(months: 12) }
                }
            }
        }
    }
    
    private func quickBtn(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(Color(.tertiarySystemBackground)))
        }
    }
    
    private func addToDate(days: Int = 0, months: Int = 0) {
        let cal = Calendar.current
        var date = Date()
        if days > 0 { date = cal.date(byAdding: .day, value: days, to: date) ?? date }
        if months > 0 { date = cal.date(byAdding: .month, value: months, to: date) ?? date }
        expiryDate = date
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .tracking(0.3)
    }
    
    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground))
    }
}

// MARK: - Edit Item Sheet
struct EditItemSheet: View {
    let space: SpaceItem
    let originalItem: FoodItem
    @ObservedObject var viewModel: SpaceViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName: String
    @State private var expiryDate: Date
    @State private var selectedSection: SpaceSection?
    @State private var showDeleteAlert = false
    
    init(space: SpaceItem, item: FoodItem, viewModel: SpaceViewModel) {
        self.space = space
        self.originalItem = item
        self.viewModel = viewModel
        _itemName = State(initialValue: item.name)
        _expiryDate = State(initialValue: item.expiryDate ?? Date())
        _selectedSection = State(initialValue: item.section)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text(appState.L("item_name"))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundColor(Color(hex: space.colorHex))
                                .font(.system(size: 14))
                            TextField("", text: $itemName)
                                .font(.system(size: 17))
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
                    }
                    
                    // Section
                    if space.type.hasSections {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(appState.L("select_section"))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 10) {
                                ForEach(space.sections, id: \.self) { section in
                                    Button {
                                        HapticManager.selection()
                                        selectedSection = section
                                    } label: {
                                        Text(appState.L(section.localizedKey))
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundColor(selectedSection == section ? .white : .primary)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 11)
                                            .background(Capsule().fill(selectedSection == section ? Color(hex: space.colorHex) : Color(.tertiarySystemBackground)))
                                    }
                                }
                            }
                        }
                    }
                    
                    // Date
                    if space.type.showsExpiryDate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(appState.L("expiry_date_label"))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            DatePicker("", selection: $expiryDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .environment(\.locale, appState.currentLanguage.calendarLocale)
                                .tint(Color(hex: space.colorHex))
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground)))
                        }
                    }
                    
                    // Added on info
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.secondary.opacity(0.4))
                        Text("\(appState.L("added_on")) \(originalItem.formattedStoredDate())")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary.opacity(0.4))
                        Spacer()
                    }
                    
                    // Delete
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text(appState.L("delete_item"))
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14).fill(Color.red.opacity(0.08))
                        )
                    }
                }
                .padding(24)
            }
            .navigationTitle(appState.L("edit_item"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(appState.L("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(appState.L("save")) {
                        let trimmed = itemName.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        var updated = originalItem
                        updated.name = trimmed
                        updated.expiryDate = space.type.showsExpiryDate ? expiryDate : nil
                        updated.section = selectedSection
                        viewModel.updateItem(in: space.id, item: updated)
                        dismiss()
                    }
                    .disabled(itemName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .alert(appState.L("delete_confirm_title"), isPresented: $showDeleteAlert) {
                Button(appState.L("cancel"), role: .cancel) {}
                Button(appState.L("delete"), role: .destructive) {
                    viewModel.deleteItem(from: space.id, itemID: originalItem.id)
                    dismiss()
                }
            } message: {
                Text(appState.L("delete_confirm_msg"))
            }
        }
    }
}

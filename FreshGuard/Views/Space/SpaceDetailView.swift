import SwiftUI

struct SpaceDetailView: View {
    @Binding var space: SpaceItem
    @ObservedObject var viewModel: SpaceViewModel
    let onDismiss: () -> Void
    @EnvironmentObject var appState: AppState
    
    @State private var showAddItem = false
    @State private var showColorPicker = false
    @State private var showRename = false
    @State private var editingItem: FoodItem?
    @State private var renameText = ""
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: space.colorHex).opacity(0.12), Color(.systemBackground)],
                startPoint: .top, endPoint: .center
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                detailTopBar
                
                // Items list
                if space.items.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        if space.type.hasSections {
                            sectionsContent
                        } else {
                            flatContent
                        }
                        
                        // Bottom padding for FABs
                        Color.clear.frame(height: 120)
                    }
                }
                
                Spacer(minLength: 0)
            }
            
            // Floating action buttons
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    // Back (bottom left)
                    Button {
                        HapticManager.impact(.light)
                        onDismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray))
                                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                            )
                    }
                    
                    Spacer()
                    
                    // Add item (bottom right)
                    Button {
                        HapticManager.impact(.medium)
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 62, height: 62)
                            .background(
                                Circle()
                                    .fill(Color(hex: space.colorHex))
                                    .shadow(color: Color(hex: space.colorHex).opacity(0.45), radius: 14, y: 7)
                            )
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 34)
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddItemSheet(space: space, viewModel: viewModel)
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(currentHex: space.colorHex) { hex in
                viewModel.updateSpaceColor(id: space.id, hex: hex)
            }
        }
        .sheet(item: $editingItem) { item in
            EditItemSheet(space: space, item: item, viewModel: viewModel)
        }
        .alert(appState.L("rename_space"), isPresented: $showRename) {
            TextField(appState.L("custom_name_placeholder"), text: $renameText)
            Button(appState.L("cancel"), role: .cancel) {}
            Button(appState.L("save")) {
                viewModel.renameSpace(id: space.id, name: renameText)
            }
        }
    }
    
    // MARK: - Top Bar
    private var detailTopBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(space.isCustomName ? space.customName : appState.L(space.displayNameKey))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .onLongPressGesture {
                        renameText = space.customName
                        showRename = true
                    }
                
                Text("\(space.items.count) \(appState.L("items_count"))")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Color palette
            Button {
                HapticManager.selection()
                showColorPicker = true
            } label: {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: space.colorHex))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 12)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: space.type.defaultSFIcon)
                .font(.system(size: 56, weight: .ultraLight))
                .foregroundColor(.secondary.opacity(0.25))
            
            Text(appState.L("empty_space"))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary.opacity(0.4))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Sections Content
    private var sectionsContent: some View {
        VStack(spacing: 0) {
            ForEach(Array(space.sections.enumerated()), id: \.element) { idx, section in
                VStack(alignment: .leading, spacing: 8) {
                    // Section header
                    HStack {
                        Text(appState.L(section.localizedKey))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Spacer()
                        
                        Text("\(viewModel.sortedItems(for: space, section: section).count)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, idx == 0 ? 8 : 20)
                    
                    let items = viewModel.sortedItems(for: space, section: section)
                    if items.isEmpty {
                        emptySectionRow
                    } else {
                        ForEach(items) { item in
                            ItemRow(item: item, space: space, viewModel: viewModel,
                                    onEdit: { editingItem = item },
                                    onDelete: {
                                withAnimation(.spring(response: 0.35)) {
                                    viewModel.deleteItem(from: space.id, itemID: item.id)
                                }
                            })
                        }
                    }
                }
                
                // Section divider
                if idx < space.sections.count - 1 {
                    Divider()
                        .padding(.horizontal, 28)
                        .padding(.top, 12)
                }
            }
        }
    }
    
    // MARK: - Flat Content
    private var flatContent: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.sortedItems(for: space)) { item in
                ItemRow(item: item, space: space, viewModel: viewModel,
                        onEdit: { editingItem = item },
                        onDelete: {
                    withAnimation(.spring(response: 0.35)) {
                        viewModel.deleteItem(from: space.id, itemID: item.id)
                    }
                })
            }
        }
        .padding(.top, 8)
    }
    
    private var emptySectionRow: some View {
        HStack {
            Spacer()
            Text(appState.L("empty_section"))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary.opacity(0.3))
                .padding(.vertical, 24)
            Spacer()
        }
    }
}

// MARK: - Item Row
struct ItemRow: View {
    let item: FoodItem
    let space: SpaceItem
    let viewModel: SpaceViewModel
    let onEdit: () -> Void
    let onDelete: () -> Void
    @EnvironmentObject var appState: AppState
    @State private var swipeOffset: CGFloat = 0
    
    private let deleteThreshold: CGFloat = -80
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button behind
            if swipeOffset < -10 {
                HStack {
                    Spacer()
                    Button {
                        onDelete()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16))
                            Text(appState.L("delete"))
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(width: 72, height: 64)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red)
                        )
                    }
                    .padding(.trailing, 20)
                }
                .transition(.opacity)
            }
            
            // Main row
            HStack(spacing: 12) {
                // Traffic light (only for expiry-based spaces)
                if space.type.showsExpiryDate {
                    let lightColor = viewModel.trafficLightColor(for: item)
                    Circle()
                        .fill(lightColor)
                        .frame(width: 12, height: 12)
                        .shadow(color: lightColor.opacity(0.6), radius: 5)
                        .overlay(
                            Circle()
                                .stroke(lightColor.opacity(0.3), lineWidth: 2)
                                .frame(width: 18, height: 18)
                        )
                }
                
                // Name
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if item.isExpired {
                        Text(appState.L("expired"))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                // Right info
                VStack(alignment: .trailing, spacing: 2) {
                    if space.type.showsExpiryDate {
                        Text(appState.L("expiry_date_short"))
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        Text(item.formattedExpiryDate())
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.primary)
                    } else {
                        // Wine cellar: stored days
                        Text(appState.L("stored_days_label"))
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        HStack(spacing: 2) {
                            Text("\(item.daysStored)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Text(appState.L("days"))
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 3)
            .offset(x: swipeOffset)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        if value.translation.width < 0 {
                            swipeOffset = max(value.translation.width, -100)
                        } else if swipeOffset < 0 {
                            swipeOffset = min(0, swipeOffset + value.translation.width)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            if swipeOffset < deleteThreshold {
                                swipeOffset = -90
                            } else {
                                swipeOffset = 0
                            }
                        }
                    }
            )
            .onTapGesture {
                if swipeOffset < 0 {
                    withAnimation(.spring(response: 0.3)) { swipeOffset = 0 }
                } else {
                    onEdit()
                }
            }
        }
    }
}

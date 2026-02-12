import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var storeManager: StoreManager
    @StateObject private var viewModel: SpaceViewModel
    
    @State private var currentPage: Int = 0
    @State private var showSettings = false
    @State private var showSubscription = false
    @State private var showAddSpace = false
    @State private var navigateToSpace: SpaceItem?
    
    init() {
        _viewModel = StateObject(wrappedValue: SpaceViewModel(appState: AppState()))
    }
    
    var body: some View {
        ZStack {
            // Animated background
            backgroundView
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with title + gear
                topBar
                    .padding(.top, 8)
                
                // Urgent badge
                if viewModel.urgentItemCount() > 0 {
                    urgentBadge
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                Spacer()
                
                // Page dots
                pageIndicator
                    .padding(.bottom, 12)
                
                // MARK: - Panorama Carousel
                TabView(selection: $currentPage) {
                    ForEach(Array(appState.spaces.enumerated()), id: \.element.id) { index, space in
                        SpaceCardView(
                            space: space,
                            viewModel: viewModel,
                            onTap: {
                                HapticManager.impact(.medium)
                                navigateToSpace = space
                            },
                            onLockTap: {
                                HapticManager.impact(.light)
                                showSubscription = true
                            }
                        )
                        .tag(index)
                    }
                    
                    // "+" card to add space
                    AddSpaceCard {
                        if storeManager.isPro || appState.isProUser {
                            showAddSpace = true
                        } else {
                            showSubscription = true
                        }
                    }
                    .tag(appState.spaces.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: UIScreen.main.bounds.height * 0.52)
                .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: currentPage)
                
                // Space label
                spaceLabel
                    .padding(.top, 8)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.appState = appState
            currentPage = appState.currentPageIndex
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView()
        }
        .sheet(isPresented: $showAddSpace) {
            AddSpaceSheet(viewModel: viewModel)
        }
        .fullScreenCover(item: $navigateToSpace) { space in
            if let index = appState.spaces.firstIndex(where: { $0.id == space.id }) {
                SpaceDetailView(
                    space: $appState.spaces[index],
                    viewModel: viewModel,
                    onDismiss: {
                        navigateToSpace = nil
                        if let idx = appState.spaces.firstIndex(where: { $0.id == space.id }) {
                            currentPage = idx
                            appState.currentPageIndex = idx
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            if appState.isDarkMode {
                LinearGradient(colors: [Color(hex: "#1C1C1E"), Color(hex: "#000000")], startPoint: .top, endPoint: .bottom)
            } else {
                LinearGradient(colors: [Color(hex: "#F2F2F7"), Color(hex: "#E5E5EA")], startPoint: .top, endPoint: .bottom)
            }
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(appState.L("app_name"))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(appState.L("app_subtitle"))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                HapticManager.selection()
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    )
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Urgent Badge
    private var urgentBadge: some View {
        let count = viewModel.urgentItemCount()
        return HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: "#FF3B30"))
                .frame(width: 8, height: 8)
                .shadow(color: Color(hex: "#FF3B30").opacity(0.6), radius: 3)
            
            Text("\(count) \(appState.L("items_expiring_soon"))")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#FF3B30"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(hex: "#FF3B30").opacity(0.1))
        )
    }
    
    // MARK: - Page Indicator
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<appState.spaces.count + 1, id: \.self) { i in
                Capsule()
                    .fill(i == currentPage ? Color.primary : Color.secondary.opacity(0.25))
                    .frame(width: i == currentPage ? 20 : 6, height: 6)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }
    
    // MARK: - Space Label
    private var spaceLabel: some View {
        Group {
            if currentPage < appState.spaces.count {
                let space = appState.spaces[currentPage]
                Text(space.isCustomName ? space.customName : appState.L(space.displayNameKey))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            } else {
                Text(appState.L("add_space"))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentPage)
    }
}

// MARK: - Space Card View
struct SpaceCardView: View {
    let space: SpaceItem
    let viewModel: SpaceViewModel
    let onTap: () -> Void
    let onLockTap: () -> Void
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var storeManager: StoreManager
    
    private var isLocked: Bool {
        space.type.requiresPro && !storeManager.isPro && !appState.isProUser
    }
    
    var body: some View {
        ZStack {
            spaceVisual
            
            if isLocked {
                lockOverlay
            }
        }
        .padding(.horizontal, 36)
        .contentShape(Rectangle())
        .onTapGesture {
            isLocked ? onLockTap() : onTap()
        }
    }
    
    @ViewBuilder
    private var spaceVisual: some View {
        switch space.type {
        case .fridge:
            FridgeVisual(color: Color(hex: space.colorHex), itemCount: space.items.count, appState: appState)
        default:
            GenericSpaceVisual(
                icon: space.type.defaultSFIcon,
                label: space.isCustomName ? space.customName : appState.L(space.type.localizedKey),
                color: Color(hex: space.colorHex),
                itemCount: space.items.count
            )
        }
    }
    
    private var lockOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial.opacity(0.85))
            
            VStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(.secondary)
                
                Text("Pro")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
            }
        }
    }
}

// MARK: - Fridge Visual
struct FridgeVisual: View {
    let color: Color
    let itemCount: Int
    let appState: AppState
    
    var body: some View {
        ZStack {
            // Body
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(colors: [color.opacity(0.7), color], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .shadow(color: color.opacity(0.35), radius: 24, x: 0, y: 12)
            
            // Inner detail
            VStack(spacing: 0) {
                // Freezer section (top 35%)
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "snowflake")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(.white.opacity(0.5))
                        Text(appState.L("section_frozen"))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .frame(height: 100)
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 1.5)
                    .padding(.horizontal, 20)
                
                // Refrigerator section
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "refrigerator.fill")
                            .font(.system(size: 40, weight: .ultraLight))
                            .foregroundColor(.white.opacity(0.35))
                        
                        if itemCount > 0 {
                            HStack(spacing: 4) {
                                Text("\(itemCount)")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                Text(appState.L("items_unit"))
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(.white.opacity(0.7))
                        } else {
                            Text(appState.L("tap_to_open"))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.35))
                        }
                    }
                }
                
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 44, height: 5)
                    .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Generic Space Visual
struct GenericSpaceVisual: View {
    let icon: String
    let label: String
    let color: Color
    let itemCount: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(colors: [color.opacity(0.7), color], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .shadow(color: color.opacity(0.35), radius: 24, x: 0, y: 12)
            
            VStack(spacing: 14) {
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 52, weight: .ultraLight))
                    .foregroundColor(.white.opacity(0.45))
                
                Text(label)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                if itemCount > 0 {
                    Text("\(itemCount)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 44, height: 5)
                    .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Add Space Card
struct AddSpaceCard: View {
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(
                    Color.secondary.opacity(0.2),
                    style: StrokeStyle(lineWidth: 2.5, dash: [12, 8])
                )
            
            VStack(spacing: 14) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundColor(.secondary.opacity(0.3))
                
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.orange.opacity(0.6))
                    Text("Pro")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.4))
                }
            }
        }
        .padding(.horizontal, 36)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Add Space Sheet
struct AddSpaceSheet: View {
    @ObservedObject var viewModel: SpaceViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: SpaceType = .snackCabinet
    @State private var customName = ""
    
    private let proTypes: [SpaceType] = [.snackCabinet, .vanityTable, .wineCellar, .custom]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(appState.L("add_space_type"))) {
                    ForEach(proTypes, id: \.self) { type in
                        HStack(spacing: 14) {
                            Image(systemName: type.defaultSFIcon)
                                .foregroundColor(.accentColor)
                                .frame(width: 28)
                            
                            Text(appState.L(type.localizedKey))
                                .font(.system(size: 16))
                            
                            Spacer()
                            
                            if selectedType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            HapticManager.selection()
                            selectedType = type
                        }
                    }
                }
                
                Section(header: Text(appState.L("custom_name")),
                        footer: Text(appState.L("custom_name_footer"))) {
                    TextField(appState.L("custom_name_placeholder"), text: $customName)
                }
            }
            .navigationTitle(appState.L("add_space"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(appState.L("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(appState.L("confirm")) {
                        viewModel.addSpace(type: selectedType, customName: customName)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

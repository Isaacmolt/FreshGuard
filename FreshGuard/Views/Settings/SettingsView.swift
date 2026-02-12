import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SpaceViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    @State private var showSubscription = false
    @State private var showAddLight = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Traffic Lights
                Section {
                    ForEach(Array(appState.trafficLights.enumerated()), id: \.element.id) { index, _ in
                        TrafficLightRow(light: $appState.trafficLights[index])
                    }
                    .onDelete { indexSet in
                        let customOnly = indexSet.filter { appState.trafficLights[$0].isCustom }
                        appState.trafficLights.remove(atOffsets: IndexSet(customOnly))
                        viewModel.rescheduleNotifications()
                    }
                    
                    // Add custom (Pro)
                    Button {
                        if appState.isProUser {
                            showAddLight = true
                        } else {
                            showSubscription = true
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                            Text(appState.L("add_custom_light"))
                                .foregroundColor(.accentColor)
                            Spacer()
                            if !appState.isProUser {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text(appState.L("traffic_lights"))
                } footer: {
                    Text(appState.L("traffic_lights_footer"))
                }
                
                // MARK: - Language
                Section(header: Text(appState.L("language"))) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        HStack {
                            Text(lang.displayName)
                                .font(.system(size: 16))
                            Spacer()
                            if appState.currentLanguage == lang {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            HapticManager.selection()
                            appState.currentLanguage = lang
                        }
                    }
                }
                
                // MARK: - Timezone
                Section(header: Text(appState.L("timezone"))) {
                    NavigationLink {
                        TimezonePickerView()
                    } label: {
                        HStack {
                            Text(appState.L("current_timezone"))
                            Spacer()
                            Text(formatTZ(appState.selectedTimezoneID))
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                                .lineLimit(1)
                        }
                    }
                }
                
                // MARK: - Appearance
                Section(header: Text(appState.L("appearance"))) {
                    Toggle(isOn: $appState.isDarkMode) {
                        HStack(spacing: 10) {
                            Image(systemName: appState.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(appState.isDarkMode ? .purple : .orange)
                            Text(appState.L("dark_mode"))
                        }
                    }
                    .tint(.accentColor)
                }
                
                // MARK: - Subscription
                Section(header: Text(appState.L("subscription"))) {
                    Button {
                        showSubscription = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.orange)
                            
                            if appState.isProUser {
                                Text(appState.L("pro_active"))
                                    .foregroundColor(.primary)
                            } else {
                                Text(appState.L("upgrade_to_pro"))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            if appState.isProUser {
                                Text("PRO")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color.orange))
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // MARK: - About
                Section(header: Text(appState.L("about"))) {
                    HStack {
                        Text(appState.L("version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://freshguard.app/terms")!) {
                        HStack {
                            Text(appState.L("terms_of_service"))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://freshguard.app/privacy")!) {
                        HStack {
                            Text(appState.L("privacy_policy"))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(appState.L("settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(appState.L("done")) {
                        viewModel.rescheduleNotifications()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showSubscription) { SubscriptionView() }
            .sheet(isPresented: $showAddLight) { AddTrafficLightSheet(viewModel: viewModel) }
        }
    }
    
    private func formatTZ(_ id: String) -> String {
        let tz = TimeZone(identifier: id) ?? .current
        let h = tz.secondsFromGMT() / 3600
        let m = abs(tz.secondsFromGMT() % 3600) / 60
        let sign = h >= 0 ? "+" : ""
        let offset = m > 0 ? String(format: "UTC%@%d:%02d", sign, h, m) : "UTC\(sign)\(h)"
        let name = id.replacingOccurrences(of: "_", with: " ").components(separatedBy: "/").last ?? id
        return "\(name) (\(offset))"
    }
}

// MARK: - Traffic Light Row
struct TrafficLightRow: View {
    @Binding var light: TrafficLight
    @EnvironmentObject var appState: AppState
    @State private var daysText = ""
    
    var body: some View {
        HStack(spacing: 14) {
            // Glow dot
            Circle()
                .fill(light.color)
                .frame(width: 22, height: 22)
                .shadow(color: light.color.opacity(0.6), radius: 5)
            
            // Threshold
            HStack(spacing: 4) {
                Text("≤")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
                
                TextField("", text: $daysText)
                    .keyboardType(.numberPad)
                    .frame(width: 44)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemBackground))
                    )
                    .onChange(of: daysText) { val in
                        if let d = Int(val), d > 0 { light.daysThreshold = d }
                    }
                
                Text(appState.L("days"))
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            
            Spacer()
            
            // Speaker toggle
            Button {
                HapticManager.selection()
                light.notificationEnabled.toggle()
            } label: {
                Image(systemName: light.notificationEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 17))
                    .foregroundColor(light.notificationEnabled ? .accentColor : .secondary.opacity(0.35))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
        }
        .onAppear { daysText = "\(light.daysThreshold)" }
    }
}

// MARK: - Add Traffic Light Sheet
struct AddTrafficLightSheet: View {
    @ObservedObject var viewModel: SpaceViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedColor = Color.purple
    @State private var days = "7"
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(appState.L("light_color"))) {
                    ColorPicker(appState.L("choose_color"), selection: $selectedColor, supportsOpacity: false)
                }
                Section(header: Text(appState.L("days_threshold"))) {
                    TextField(appState.L("days"), text: $days)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle(appState.L("add_custom_light"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(appState.L("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(appState.L("confirm")) {
                        if let d = Int(days), d > 0 {
                            let newLight = TrafficLight(
                                colorHex: selectedColor.toHex(),
                                daysThreshold: d,
                                notificationEnabled: true,
                                isCustom: true,
                                sortOrder: appState.trafficLights.count
                            )
                            appState.trafficLights.append(newLight)
                            appState.trafficLights.sort { $0.daysThreshold < $1.daysThreshold }
                            viewModel.rescheduleNotifications()
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Timezone Picker
struct TimezonePickerView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    
    private var allTimezones: [(id: String, display: String)] {
        TimeZone.knownTimeZoneIdentifiers.map { id in
            let tz = TimeZone(identifier: id)!
            let h = tz.secondsFromGMT() / 3600
            let m = abs(tz.secondsFromGMT() % 3600) / 60
            let sign = h >= 0 ? "+" : ""
            let offset = m > 0 ? String(format: "UTC%@%d:%02d", sign, h, m) : "UTC\(sign)\(h)"
            let name = id.replacingOccurrences(of: "_", with: " ")
            return (id: id, display: "\(name)  (\(offset))")
        }.sorted { $0.display < $1.display }
    }
    
    private var filtered: [(id: String, display: String)] {
        searchText.isEmpty ? allTimezones : allTimezones.filter { $0.display.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List(filtered, id: \.id) { tz in
            HStack {
                Text(tz.display).font(.system(size: 14))
                Spacer()
                if appState.selectedTimezoneID == tz.id {
                    Image(systemName: "checkmark").foregroundColor(.accentColor)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                HapticManager.selection()
                appState.selectedTimezoneID = tz.id
            }
        }
        .searchable(text: $searchText, prompt: appState.L("search_timezone"))
        .navigationTitle(appState.L("timezone"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

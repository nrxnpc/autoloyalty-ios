import SwiftUI
import Network
import Dependencies

// MARK: - Network Status Banner
struct NetworkStatusBanner: View {
    @Dependency(\.endpoint) var endpoint: RestEndpoint
    @State private var showBanner = false
    @State private var isConnected = true
    
    var body: some View {
        VStack(spacing: 0) {
            if !isConnected && showBanner {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    
                    Text("Нет подключения к интернету")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Скрыть") {
                        withAnimation {
                            showBanner = false
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                }
                .padding()
                .background(Color.red)
                .transition(.move(edge: .top))
            }
        }
        .animation(.easeInOut, value: showBanner)
        .onChange(of: isConnected) { _, connected in
            if !connected {
                withAnimation {
                    showBanner = true
                }
            } else {
                withAnimation(.easeInOut.delay(1)) {
                    showBanner = false
                }
            }
        }
        .task {
            await checkConnection()
        }
    }
    
    private func checkConnection() async {
        do {
            isConnected = try await endpoint.healthCheck().error == nil
        } catch {
            isConnected = false
        }
    }
}

// MARK: - Connection Settings View
struct ConnectionSettingsView: View {
    @Dependency(\.endpoint) var endpoint: RestEndpoint
    @State private var autoSync = true
    @State private var wifiOnly = false
    @State private var lowDataMode = false
    @State private var isConnected = true
    @State private var isLoading = false
    
    var body: some View {
        List {
            Section("Состояние сети") {
                HStack {
                    Image(systemName: isConnected ? "wifi" : "wifi.slash")
                        .foregroundColor(isConnected ? .green : .red)
                    
                    Text(isConnected ? "Подключено" : "Нет соединения")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
            
            Section("Настройки синхронизации") {
                Toggle("Автоматическая синхронизация", isOn: $autoSync)
                    .tint(AppConstants.Colors.primary)
                
                Toggle("Только по Wi-Fi", isOn: $wifiOnly)
                    .tint(AppConstants.Colors.primary)
                
                Toggle("Режим экономии трафика", isOn: $lowDataMode)
                    .tint(AppConstants.Colors.primary)
            }
            
            Section("Действия") {
                Button("Принудительная синхронизация") {
                    Task {
                        isLoading = true
                        await checkConnection()
                        isLoading = false
                    }
                }
                .disabled(!isConnected || isLoading)
                
                Button("Очистить кеш") {
                    ImageCacheService.shared.clearCache()
                }
                .foregroundColor(.red)
            }
            
            Section("Информация") {
                HStack {
                    Text("Использование данных")
                    Spacer()
                    Text("~2.5 МБ")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Последняя синхронизация")
                    Spacer()
                    Text(UserDefaults.standard.lastSyncDate?.formattedDate() ?? "Никогда")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Подключение")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await checkConnection()
        }
    }
    
    private func checkConnection() async {
        do {
            isConnected = try await endpoint.healthCheck().error == nil
        } catch {
            isConnected = false
        }
    }
}

// MARK: - Network Monitoring Service (Simplified)
class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    @Published var connectionType: String = "wifi"
    
    init() {
        startSimpleMonitoring()
    }
    
    private func startSimpleMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.checkConnection()
        }
    }
    
    private func checkConnection() {
        isConnected = true
        connectionType = "wifi"
    }
}

// MARK: - Sync Status View
struct SyncStatusView: View {
    @State private var lastSyncDate: Date?
    @State private var isConnected = true
    @State private var isLoading = false
    
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Синхронизация...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: isConnected ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(isConnected ? .green : .orange)
                
                if let lastSync = lastSyncDate {
                    Text("Обновлено \(lastSync.timeAgoDisplay())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(isConnected ? "Онлайн" : "Оффлайн")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            lastSyncDate = UserDefaults.standard.lastSyncDate
        }
    }
}

// MARK: - Offline Mode Banner
struct OfflineModeBanner: View {
    @State private var isConnected = true
    
    var body: some View {
        if !isConnected {
            HStack {
                Image(systemName: "airplane")
                    .foregroundColor(.orange)
                
                Text("Работаем в автономном режиме")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(0.1))
        }
    }
}

// MARK: - Data Usage View
struct DataUsageView: View {
    @State private var uploadedData: Int = 1024 * 1024 * 2 // 2 MB
    @State private var downloadedData: Int = 1024 * 1024 * 5 // 5 MB
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            Text("Использование данных")
                .font(.headline)
            
            DataUsageRow(
                title: "Загружено",
                amount: ByteCountFormatter.string(fromByteCount: Int64(uploadedData), countStyle: .file),
                color: .blue
            )
            
            DataUsageRow(
                title: "Скачано",
                amount: ByteCountFormatter.string(fromByteCount: Int64(downloadedData), countStyle: .file),
                color: .green
            )
            
            DataUsageRow(
                title: "Всего",
                amount: ByteCountFormatter.string(fromByteCount: Int64(uploadedData + downloadedData), countStyle: .file),
                color: .primary
            )
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DataUsageRow: View {
    let title: String
    let amount: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(amount)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

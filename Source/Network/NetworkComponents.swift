import SwiftUI
import Network

// MARK: - Network Status Banner
struct NetworkStatusBanner: View {
    @ObservedObject var networkManager = NetworkManager.shared
    @State private var showBanner = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !networkManager.isConnected && showBanner {
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
        .onChange(of: networkManager.isConnected) { _, connected in
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
    }
}

// MARK: - Connection Settings View
struct ConnectionSettingsView: View {
    @ObservedObject var networkManager = NetworkManager.shared
    @State private var autoSync = true
    @State private var wifiOnly = false
    @State private var lowDataMode = false
    
    var body: some View {
        List {
            Section("Состояние сети") {
                HStack {
                    Image(systemName: networkManager.isConnected ? "wifi" : "wifi.slash")
                        .foregroundColor(networkManager.isConnected ? .green : .red)
                    
                    Text(networkManager.isConnected ? "Подключено" : "Нет соединения")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    if networkManager.isLoading {
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
                        // Логика принудительной синхронизации
                    }
                }
                .disabled(!networkManager.isConnected || networkManager.isLoading)
                
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
    }
}

// MARK: - Network Monitoring Service
class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = false
    @Published var connectionType: NWInterface.InterfaceType?
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = NWInterface.InterfaceType.allCases.first(where: path.usesInterfaceType)
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - Sync Status View
struct SyncStatusView: View {
    @ObservedObject var networkManager = NetworkManager.shared
    @State private var lastSyncDate: Date?
    
    var body: some View {
        HStack {
            if networkManager.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Синхронизация...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: networkManager.isConnected ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(networkManager.isConnected ? .green : .orange)
                
                if let lastSync = lastSyncDate {
                    Text("Обновлено \(lastSync.timeAgoDisplay())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(networkManager.isConnected ? "Онлайн" : "Оффлайн")
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
    @ObservedObject var networkManager = NetworkManager.shared
    
    var body: some View {
        if !networkManager.isConnected {
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

// MARK: - Network Settings Extension
extension NetworkManager {
    func testConnection() async -> Bool {
        guard let url = URL(string: baseURL + "/health") else {
            return false
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
    
    func getNetworkStats() -> (uploaded: Int, downloaded: Int) {
        // В реальном приложении это были бы реальные метрики
        return (
            uploaded: UserDefaults.standard.integer(forKey: "uploadedBytes"),
            downloaded: UserDefaults.standard.integer(forKey: "downloadedBytes")
        )
    }
}

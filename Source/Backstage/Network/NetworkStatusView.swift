// NetworkStatusView.swift
// Компоненты для отображения сетевого статуса

import SwiftUI

// MARK: - Network Status Indicator

struct NetworkStatusIndicator: View {
    @ObservedObject private var networkManager = NetworkManager.shared
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(networkManager.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(networkManager.connectionStatusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Network Status Banner

struct NetworkStatusBanner: View {
    @ObservedObject private var networkManager = NetworkManager.shared
    @State private var showBanner = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showBanner && !networkManager.isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    
                    Text("Нет подключения к интернету")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Повторить") {
                        networkManager.checkConnection()
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.red)
                .transition(.move(edge: .top))
            }
        }
        .onChange(of: networkManager.isConnected) { _, isConnected in
            withAnimation(.easeInOut(duration: 0.3)) {
                showBanner = !isConnected
            }
        }
        .onAppear {
            showBanner = !networkManager.isConnected
        }
    }
}

// MARK: - Enhanced QR Scanner with Network Status

struct QRScannerMainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataManager: DataManager
    @State private var showingScanner = false
    @State private var scannedCode: String? = nil
    @State private var scanResult: QRScanResult? = nil
    @State private var showingResult = false
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Network Status Banner
            NetworkStatusBanner()
            
            VStack(spacing: AppConstants.Spacing.extraLarge) {
                Spacer()
                
                // Network status indicator (smaller)
                NetworkStatusIndicator()
                    .padding(.top)
                
                // QR иконка
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 120))
                    .foregroundColor(AppConstants.Colors.primary)
                
                VStack(spacing: AppConstants.Spacing.medium) {
                    Text("Сканирование QR-кодов")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Наведите камеру на QR-код на упаковке автозапчасти для получения баллов")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Показываем статус офлайн режима
                    if !dataManager.isOnline {
                        HStack {
                            Image(systemName: "cloud.slash")
                                .foregroundColor(.orange)
                            Text("Офлайн режим - данные будут синхронизированы позже")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Кнопка сканирования
                Button(action: { showingScanner = true }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "camera.fill")
                        }
                        Text(isProcessing ? "Обработка..." : "Сканировать QR-код")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isProcessing ? Color.secondary : AppConstants.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isProcessing)
                .padding(.horizontal)
                
                // История сканирований
                if !dataManager.qrScansState.items.isEmpty {
                    QRHistorySection()
                } else {
                    Spacer()
                }
            }
            .padding()
        }
        .navigationTitle("Сканер")
        .sheet(isPresented: $showingScanner) {
            QRCodeScannerView(scannedCode: $scannedCode)
        }
        .onChange(of: scannedCode) { _, code in
            if let code = code, let userId = authViewModel.currentUser?.id {
                isProcessing = true
                Task {
                    let result = await dataManager.processQRScan(code: code, userId: userId)
                    if let result = result {
                        await MainActor.run {
                            scanResult = result
                            authViewModel.addPoints(result.pointsEarned)
                            showingResult = true
                        }
                    }
                    await MainActor.run {
                        isProcessing = false
                        scannedCode = nil
                    }
                }
            }
        }
        .alert("QR-код отсканирован!", isPresented: $showingResult) {
            Button("OK") { }
        } message: {
            if let result = scanResult {
                let mode = dataManager.isOnline ? "" : " (офлайн)"
                Text("Вы получили \(result.pointsEarned) баллов за сканирование \(result.productName)\(mode)")
            }
        }
        .task {
            await dataManager.loadDataType(.qrScans)
        }
    }
}

// MARK: - Connection Settings View

struct ConnectionSettingsView: View {
    @ObservedObject private var networkManager = NetworkManager.shared
    @State private var customServerURL = ""
    @State private var showingServerSettings = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Статус подключения") {
                    HStack {
                        Circle()
                            .fill(networkManager.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Статус сети")
                                .font(.subheadline)
                            Text(networkManager.connectionStatusText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Проверить") {
                            networkManager.checkConnection()
                        }
                        .font(.caption)
                        .foregroundColor(AppConstants.Colors.primary)
                    }
                }
                
                Section("Действия") {
                    Button("Проверить подключение") {
                        networkManager.checkConnection()
                    }
                    
                    Button("Настройки сервера") {
                        showingServerSettings = true
                    }
                    .foregroundColor(AppConstants.Colors.primary)
                }
                
                Section("Информация") {
                    HStack {
                        Text("Тип подключения")
                        Spacer()
                        Text(networkManager.connectionStatusText)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Статус API")
                        Spacer()
                        Text(networkManager.isConnected ? "Доступен" : "Недоступен")
                            .foregroundColor(networkManager.isConnected ? .green : .red)
                    }
                }
            }
            .navigationTitle("Сетевые настройки")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingServerSettings) {
                ServerSettingsView()
            }
        }
    }
}

struct ServerSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var serverURL = "http://localhost:8000/api"
    @State private var isTestingConnection = false
    @State private var testResult: String? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppConstants.Spacing.large) {
                VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
                    Text("Адрес сервера")
                        .font(.headline)
                    
                    TextField("http://your-server:8000/api", text: $serverURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    Text("Введите полный адрес API сервера включая протокол и порт")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button("Проверить подключение") {
                    testConnection()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isTestingConnection ? Color.secondary : AppConstants.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(isTestingConnection)
                
                if let testResult = testResult {
                    Text(testResult)
                        .font(.subheadline)
                        .foregroundColor(testResult.contains("успешно") ? .green : .red)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Настройки сервера")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        // TODO: Сохранить настройки сервера
                        dismiss()
                    }
                    .disabled(serverURL.isEmpty)
                }
            }
        }
    }
    
    private func testConnection() {
        isTestingConnection = true
        testResult = nil
        
        guard let url = URL(string: serverURL + "/health") else {
            testResult = "Неверный формат URL"
            isTestingConnection = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isTestingConnection = false
                
                if let error = error {
                    testResult = "Ошибка подключения: \(error.localizedDescription)"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        testResult = "✅ Подключение успешно!"
                    } else {
                        testResult = "❌ Сервер вернул код: \(httpResponse.statusCode)"
                    }
                } else {
                    testResult = "❌ Неверный ответ сервера"
                }
            }
        }.resume()
    }
}

#Preview("Network Status Indicator") {
    NetworkStatusIndicator()
}

#Preview("Network Status Banner") {
    NetworkStatusBanner()
}

#Preview("Connection Settings") {
    ConnectionSettingsView()
}

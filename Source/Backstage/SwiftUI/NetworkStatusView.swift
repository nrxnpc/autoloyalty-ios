// NetworkStatusView.swift
// Компоненты для отображения сетевого статуса

import SwiftUI

// MARK: - Network Status Indicator

struct NetworkStatusIndicator: View {
    // @ObservedObject private var networkManager = NetworkManager.shared
    
    var body: some View {
        EmptyView()
        // HStack(spacing: 4) {
        //     Circle()
        //         .fill(networkManager.isConnected ? Color.green : Color.red)
        //         .frame(width: 8, height: 8)
        //
        //     Text(networkManager.connectionStatusText)
        //         .font(.caption)
        //         .foregroundColor(.secondary)
        // }
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

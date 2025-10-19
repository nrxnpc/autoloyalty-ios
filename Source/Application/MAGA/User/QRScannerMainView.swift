import SwiftUI

struct QRScannerMainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataManager: DataManager
    @State private var showingScanner = false
    @State private var scannedCode: String? = nil
    @State private var scanResult: QRScanResult? = nil
    @State private var showingResult = false
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.extraLarge) {
            Spacer()
            
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
            }
            
            // Кнопка сканирования
            Button(action: { showingScanner = true }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Сканировать QR-код")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppConstants.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // История сканирований
            if !dataManager.qrScansState.items.isEmpty {
                QRHistorySection()
            } else {
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Сканер")
        .sheet(isPresented: $showingScanner) {
            QRCodeScannerView(scannedCode: $scannedCode)
        }
        .onChange(of: scannedCode) { _, code in
            if let code = code, let userId = authViewModel.currentUser?.id {
                Task {
                    let result = await dataManager.processQRScan(code: code, userId: userId)
                    if let result = result {
                        await MainActor.run {
                            scanResult = result
                            authViewModel.addPoints(result.pointsEarned)
                            dataManager.addQRScan(result)
                            dataManager.addPointTransaction(
                                userId: userId,
                                type: .earned,
                                amount: result.pointsEarned,
                                description: "Сканирование QR-кода (\(result.productName))",
                                relatedId: result.id
                            )
                            showingResult = true
                        }
                    }
                    scannedCode = nil
                }
            }
        }
        .alert("QR-код отсканирован!", isPresented: $showingResult) {
            Button("OK") { }
        } message: {
            if let result = scanResult {
                Text("Вы получили \(result.pointsEarned) баллов за сканирование \(result.productName)")
            }
        }
        .task {
            await dataManager.loadDataType(.qrScans)
        }
    }
}

struct QRHistorySection: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var recentScans: [QRScanResult] {
        dataManager.qrScansState.items
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack {
                Text("История сканирований")
                    .font(.headline)
                Spacer()
                NavigationLink("Все", destination: QRScanHistoryView())
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.primary)
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: AppConstants.Spacing.small) {
                    ForEach(recentScans, id: \.id) { scan in
                        QRScanHistoryRow(scan: scan)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct QRScanHistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List {
            ForEach(dataManager.qrScansState.items.sorted { $0.timestamp > $1.timestamp }, id: \.id) { scan in
                QRScanHistoryRow(scan: scan)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("История сканирований")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await dataManager.loadDataType(.qrScans)
        }
    }
}

struct QRScanHistoryRow: View {
    let scan: QRScanResult
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.productName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(scan.productCategory)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(scan.timestamp.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(scan.pointsEarned)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("баллов")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    NavigationStack {
        QRScannerMainView()
            .environmentObject(AuthViewModel())
            .environmentObject(DataManager())
    }
}

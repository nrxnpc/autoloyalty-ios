import SwiftUI

struct QRScanHistoryView: View {
    // MARK: - Dependencies
    
    @Environment(\.dismiss) private var dismiss
    @Environment(Main.Router.self) var router
    
    @FetchRequest var scans: FetchedResults<ScanItem>
    
    // MARK: - Initialization
    
    init() {
        _scans = FetchRequest(fetchRequest: ScanItem.allScans(), animation: .smooth)
    }
    
    
    // MARK: -
    
    var body: some View {
        Group {
            if scans.isEmpty {
                makeEmptyState()
            } else {
                makeScansList()
            }
        }
        .navigationTitle("Scan History")
        .toolbar(content: makeToolbar)
    }
}

extension QRScanHistoryView {
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    Image(systemName: "qrcode")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Text("Your history will appear here once you start scanning QR codes to earn points")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(.regularMaterial)
            }
            .padding()
        }
    }
    
    @ViewBuilder func makeScansList() -> some View {
        List(scans, id: \.id) { scan in
            makeRow(with: scan)
        }
    }
    
    @ViewBuilder func makeRow(with scan: ScanItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "qrcode.viewfinder")
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                BalanceLabel(points: scan.pointsEarned)
                    .font(.headline)
                
                Text(scan.productName)
                    .font(.callout)
                    .foregroundStyle(.primary)
                
                Text(scan.productCategory)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack {
                Text(DateFormatters.shared.day.string(from: scan.createdAt))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    @ToolbarContentBuilder func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
    }
}


#Preview {
    NavigationView {
        QRScanHistoryView()
    }
}

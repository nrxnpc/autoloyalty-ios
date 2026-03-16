import SwiftUI
import SwiftUIComponents

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
    @ViewBuilder static func makeEmptyState() -> some View {
        VStack(spacing: 24) {
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundStyle(.green)
                .symbolEffect(.bounce, options: .repeat(1))
            Text("Your history will appear here once you start scanning QR codes to earn points")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
    
    @ViewBuilder func makeEmptyState() -> some View {
        ScrollView {
            QRScanHistoryView.makeEmptyState()
                .modifier(DefaultBackgroundStyle())
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
                .foregroundStyle(.blue, .secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.productName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(scan.productCategory)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                BalanceLabel(points: scan.pointsEarned)
                    .font(.caption)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


#Preview {
    NavigationView {
        QRScanHistoryView()
    }
}

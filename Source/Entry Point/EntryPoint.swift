import SwiftUI
import Nuke

@main
struct EntryPoint: App {
    init() {
        EntryPoint.configureNukeCache()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

extension EntryPoint {
    static func configureNukeCache() {
        // 1. Create a custom DataCache
        let dataCache = try? DataCache(name: "prototype.nsp.imagecache")
        dataCache?.sizeLimit = 500 * 1024 * 1024 // 500 MB
        
        // 2. Start with a default configuration
        var configuration = ImagePipeline.Configuration.withDataCache
        configuration.dataCache = dataCache
        
        // 3. Set the Data Cache Policy
        // .automatic (default) stores original data.
        // .storeEncodedImages stores the final processed (resized) images.
        configuration.dataCachePolicy = .storeEncodedImages
        
        // 4. Set the Encoder for saving to disk
        // In the latest Nuke versions, this is a closure property on Configuration
        configuration.makeImageEncoder = { _ in
            ImageEncoders.ImageIO(type: .heic, compressionRatio: 0.8)
        }
        
        // 5. Set the custom pipeline as the shared instance
        ImagePipeline.shared = ImagePipeline(configuration: configuration)
    }
}

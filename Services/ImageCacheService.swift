import UIKit
import Combine
import SwiftUI

class ImageCacheService: ObservableObject {
    static let shared = ImageCacheService()
    
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let diskCache: URL
    private let cacheQueue = DispatchQueue(label: "image.cache", qos: .utility, attributes: .concurrent)
    
    private init() {
        // Настройка memory cache
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Создание disk cache
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCache = cacheDir.appendingPathComponent("ImageCache")
        
        try? FileManager.default.createDirectory(at: diskCache, withIntermediateDirectories: true)
        
        // Очистка старых файлов при запуске
        cleanupDiskCache()
    }
    
    func image(for url: URL) -> AnyPublisher<UIImage?, Never> {
        // Проверяем кеш
        if let cachedImage = memoryCache.object(forKey: url as NSURL) {
            return Just(cachedImage).eraseToAnyPublisher()
        }
        
        // Загружаем асинхронно
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] image in
                if let image = image {
                    self?.memoryCache.setObject(image, forKey: url as NSURL)
                }
            })
            .subscribe(on: cacheQueue)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func image(for url: URL) async -> UIImage? {
        // 1. Проверяем memory cache
        if let cachedImage = memoryCache.object(forKey: url as NSURL) {
            return cachedImage
        }
        
        // 2. Проверяем disk cache
        if let diskImage = await loadFromDisk(url: url) {
            memoryCache.setObject(diskImage, forKey: url as NSURL)
            return diskImage
        }
        
        // 3. Загружаем из сети
        return await downloadAndCache(url: url)
    }
    
    private func loadFromDisk(url: URL) async -> UIImage? {
        return await withUnsafeContinuation { continuation in
            cacheQueue.async {
                let filename = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
                let fileURL = self.diskCache.appendingPathComponent(filename)
                
                guard let data = try? Data(contentsOf: fileURL),
                      let image = UIImage(data: data) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: image)
            }
        }
    }
    
    private func downloadAndCache(url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            // Кешируем в memory
            memoryCache.setObject(image, forKey: url as NSURL)
            
            // Кешируем на диск асинхронно
            Task.detached(priority: .utility) {
                await self.saveToDisk(data: data, url: url)
            }
            
            return image
        } catch {
            return nil
        }
    }
    
    private func saveToDisk(data: Data, url: URL) async {
        await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
            cacheQueue.async {
                let filename = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
                let fileURL = self.diskCache.appendingPathComponent(filename)
                
                try? data.write(to: fileURL)
                continuation.resume()
            }
        }
    }
    
    private func cleanupDiskCache() {
        cacheQueue.async {
            let fileManager = FileManager.default
            let now = Date()
            let maxAge: TimeInterval = 7 * 24 * 60 * 60 // 7 дней
            
            guard let enumerator = fileManager.enumerator(at: self.diskCache, includingPropertiesForKeys: [.contentModificationDateKey]) else { return }
            
            for case let fileURL as URL in enumerator {
                guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                      let modificationDate = attributes[.modificationDate] as? Date else { continue }
                
                if now.timeIntervalSince(modificationDate) > maxAge {
                    try? fileManager.removeItem(at: fileURL)
                }
            }
        }
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        
        cacheQueue.async {
            try? FileManager.default.removeItem(at: self.diskCache)
            try? FileManager.default.createDirectory(at: self.diskCache, withIntermediateDirectories: true)
        }
    }
}

// MARK: - AsyncImageView Component

struct AsyncImageView: View {
    let url: URL?
    let placeholder: Image
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    init(url: URL?, placeholder: Image = Image(systemName: "photo")) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                placeholder
                    .foregroundColor(.gray)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    )
            } else {
                placeholder
                    .foregroundColor(.gray)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else {
            isLoading = false
            return
        }
        
        let loadedImage = await ImageCacheService.shared.image(for: url)
        
        await MainActor.run {
            self.image = loadedImage
            self.isLoading = false
        }
    }
}

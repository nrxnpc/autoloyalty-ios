import SwiftUI
import PhotosUI
import UIKit
import AVFoundation

// MARK: - Public API

/// Provides a complete, encapsulated workflow for picking an image from the photo library,
/// cropping it to a square, and receiving the final image data.
///
/// This is the single entry point for this feature.
///
/// ### Usage
///
/// 1. Add a `@State` variable for the `PhotosPickerItem` to your view.
/// 2. Attach the `PhotosPicker` to a button or label in your view hierarchy, binding it to your state variable.
/// 3. Apply the `.photosPickerItemCropper(...)` modifier to the `PhotosPicker`.
/// 4. Provide a completion handler to receive the final `Data` of the cropped image.
///
/// ```swift
/// struct MyProfileView: View {
///     @State private var profilePickerItem: PhotosPickerItem?
///
///     var body: some View {
///         PhotosPicker(selection: $profilePickerItem, matching: .images) {
///             Text("Change Picture")
///         }
///         .photosPickerItemCropper(pickerItem: $profilePickerItem) { imageData in
///             // Use the final cropped image data to update your model or upload.
///             viewModel.updateProfileImage(with: imageData)
///         }
///     }
/// }
/// ```
public extension View {
    /// Attaches a photos picker and cropper workflow to a view.
    ///
    /// When a user selects an image via the associated `PhotosPicker`, this modifier
    /// automatically presents a full-screen cropping interface. Once the user saves the crop,
    /// the `onCompletion` closure is called with the resulting image data.
    ///
    /// - Parameters:
    ///   - pickerItem: A `Binding` to the `PhotosPickerItem?` that the `PhotosPicker` will update.
    ///   - onCompletion: A closure that receives the final, cropped image as `Data`.
    func photosPickerItemCropper(
        pickerItem: Binding<PhotosPickerItem?>,
        onCompletion: @escaping (Data) -> Void
    ) -> some View {
        self.modifier(
            PhotosPickerItemCropperModifier(
                pickerItem: pickerItem,
                onCompletion: onCompletion
            )
        )
    }
}

// MARK: - Private Implementation

/// A private `ViewModifier` that orchestrates the entire image picking and cropping flow.
///
/// This modifier is the "engine" behind the public API. It observes the `PhotosPickerItem`,
/// loads its data, presents the `ImageCropperView`, and calls the completion handler.
/// It is not intended to be used directly from outside this file.
fileprivate struct PhotosPickerItemCropperModifier: ViewModifier {
    
    @Binding var pickerItem: PhotosPickerItem?
    let onCompletion: (Data) -> Void
    
    @State private var loadedImageData: Data?
    @State private var isCropperPresented: Bool = false
    
    func body(content: Content) -> some View {
        content
            .task(id: pickerItem) {
                // This task runs automatically when `pickerItem` changes.
                await processPickerItem()
            }
            .fullScreenCover(isPresented: $isCropperPresented) {
                // Using fullScreenCover for a more immersive cropping experience.
                if let data = loadedImageData, let uiImage = UIImage(data: data) {
                    ImageCropperView(inputImage: uiImage) { croppedImage in
                        handleCroppingCompletion(image: croppedImage)
                    }
                }
            }
    }
    
    /// Asynchronously loads transferable data from the selected `PhotosPickerItem`.
    /// If successful, it updates the state to present the cropper view.
    private func processPickerItem() async {
        guard let newItem = pickerItem else { return }
        
        do {
            guard let imageData = try await newItem.loadTransferable(type: Data.self) else {
                // This case handles when the user selects an image format that cannot be
                // represented as Data (e.g., some RAW formats on macOS).
                resetState()
                return
            }
            
            // State updates must be on the main actor.
            await MainActor.run {
                self.loadedImageData = imageData
                self.isCropperPresented = true
            }
        } catch {
            resetState()
        }
    }
    
    /// Handles the result from `ImageCropperView`.
    /// - Parameter image: The optional `UIImage` returned from the cropper. Nil if the user cancelled.
    private func handleCroppingCompletion(image: UIImage?) {
        /// Start from HEIC, do `image.jpegData(compressionQuality: 0.8)` later
        if let image, let data = image.heicData()  {
            onCompletion(data)
        }
        
        // Always reset state after completion or cancellation.
        Task {
            resetState()
        }
    }
    
    /// Resets all internal state on the main actor to prepare for the next selection.
    @MainActor
    private func resetState() {
        pickerItem = nil
        loadedImageData = nil
        isCropperPresented = false
    }
}

// MARK: - Build-In Image Cropper Implementation

/// A view that allows the user to pan and zoom an image to crop it into a square.
///
/// This view provides an interactive interface for selecting a square region of a larger image.
/// It correctly handles all transformations (pan, zoom) using affine transforms for pixel-perfect cropping
/// and performs all image processing asynchronously to keep the UI responsive.
struct ImageCropperView: View {
    
    // MARK: - Properties
    
    let inputImage: UIImage
    let onComplete: (UIImage?) -> Void
    
    private let targetSize = CGSize(width: 512, height: 512)
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var viewSize: CGSize = .zero
    @State private var isProcessing: Bool = false
    
    // MARK: - Computed Geometry
    
    private var cropSize: CGFloat {
        min(viewSize.width, viewSize.height)
    }
    
    private var initialScale: CGFloat {
        guard !viewSize.equalTo(.zero), inputImage.size.width > 0, inputImage.size.height > 0 else { return 1.0 }
        let imageRect = AVMakeRect(aspectRatio: inputImage.size, insideRect: CGRect(origin: .zero, size: viewSize))
        return max(cropSize / imageRect.width, cropSize / imageRect.height)
    }
    
    private var cropAreaRect: CGRect {
        CGRect(
            x: (viewSize.width - cropSize) / 2,
            y: (viewSize.height - cropSize) / 2,
            width: cropSize,
            height: cropSize
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // The interactive image view
            Image(uiImage: inputImage)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(combinedGesture)
            
            // The semi-transparent overlay with a cutout for the crop area
            cropperOverlay
                .allowsHitTesting(false)
            
            // UI Controls
            VStack {
                Spacer()
                buttonStack
            }
            .padding()
        }
        .overlay(
            // Capture the available size of the view for calculations
            GeometryReader { proxy in
                Color.clear.onAppear {
                    self.viewSize = proxy.size
                    self.scale = initialScale
                    self.lastOffset = .zero // Ensure offset is reset
                }
            }
        )
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - UI Components
    
    private var cropperOverlay: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.6))
                .mask(
                    HoleShape(rect: cropAreaRect)
                        .fill(style: FillStyle(eoFill: true))
                )
            
            RoundedRectangle(cornerRadius: cropAreaRect.width / 2, style: .continuous)
                .stroke(Color.white, lineWidth: 1)
                .frame(width: cropSize, height: cropSize)
        }
    }
    
    private var buttonStack: some View {
        HStack(alignment: .center) {
            // Cancel Button
            Button {
                onComplete(nil)
                dismiss()
            } label: {
                Image(systemName: "chevron.backward.circle")
                    .resizable()
                    .fontWeight(.thin)
                    .frame(width: 28, height: 28)
            }
            .disabled(isProcessing)
            
            Spacer()
            
            // Save Button
            Button {
                // Perform the crop operation asynchronously
                Task {
                    isProcessing = true
                    let croppedImage = await performCropAsync()
                    onComplete(croppedImage)
                    dismiss()
                }
            } label: {
                if isProcessing {
                    ProgressView().tint(.white)
                } else {
                    Text("Save")
                }
            }
            .disabled(isProcessing)
        }
        .padding(.bottom, 32)
        .padding(.horizontal)
        .foregroundColor(.white)
        .animation(.default, value: isProcessing)
    }
    
    // MARK: - Gesture Logic
    
    private var combinedGesture: some Gesture {
        // A combined gesture for panning (Drag) and zooming (Magnification)
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in clampStateWithAnimation() }
            .simultaneously(with: MagnificationGesture()
                .onChanged { value in
                    let delta = value / lastScale
                    scale *= delta
                    lastScale = value
                }
                .onEnded { _ in clampStateWithAnimation() }
            )
    }
    
    // MARK: - Cropping and Boundary Logic
    
    /// Ensures the image does not pan or zoom outside of reasonable bounds.
    private func clampStateWithAnimation() {
        let maxZoom: CGFloat = 3.0
        let newScale = max(initialScale, min(scale, maxZoom * initialScale))
        
        let imageRect = AVMakeRect(aspectRatio: inputImage.size, insideRect: CGRect(origin: .zero, size: viewSize))
        let scaledImageSize = CGSize(width: imageRect.width * newScale, height: imageRect.height * newScale)
        
        let maxOffsetX = (scaledImageSize.width - cropSize) / 2
        let maxOffsetY = (scaledImageSize.height - cropSize) / 2
        
        var newOffset = offset
        newOffset.width = max(-maxOffsetX, min(maxOffsetX, newOffset.width))
        newOffset.height = max(-maxOffsetY, min(maxOffsetY, newOffset.height))
        
        withAnimation(.interpolatingSpring) {
            scale = newScale
            offset = newOffset
        }
        
        lastScale = 1.0
        lastOffset = newOffset
    }
    
    /// This function precisely calculates the crop rectangle in the source image's pixel space by
    /// determining the geometric relationship between the on-screen crop area and the transformed image.
    /// It correctly reverses the user's pan (`offset`) and zoom (`scale`) operations to find the
    /// corresponding pixel region in the original image.
    ///
    /// - Returns: The final cropped and resized `UIImage` or `nil` if an error occurs.
    private func performCropAsync() async -> UIImage? {
        // Capture all state properties on the MainActor before entering the detached task
        // to prevent data races. This ensures the values are stable during processing.
        let localScale = self.scale
        let localOffset = self.offset
        let localViewSize = self.viewSize
        let localCropRect = self.cropAreaRect
        let sourceImage = self.inputImage
        
        return await Task.detached(priority: .userInitiated) {
            // Step 1: Establish the baseline geometry.
            // `fittedImageRectInView` is the frame of the image after being scaled to fit the view,
            // but *before* any user interaction (pan or zoom).
            let imagePixelSize = sourceImage.size
            let viewRect = CGRect(origin: .zero, size: localViewSize)
            let fittedImageRectInView = AVMakeRect(aspectRatio: imagePixelSize, insideRect: viewRect)
            
            // Step 2: Calculate the pixel density ratio.
            // This tells us how many image pixels correspond to a single point in the fitted view.
            let pixelsPerPoint = imagePixelSize.width / fittedImageRectInView.width
            
            // Step 3: Calculate the size of the final crop rectangle in pixels.
            // This is the on-screen crop size, adjusted for the user's zoom level, then converted to pixels.
            let cropRectPixelSize = CGSize(
                width: localCropRect.width / localScale * pixelsPerPoint,
                height: localCropRect.height / localScale * pixelsPerPoint
            )
            
            // Step 4: Calculate the center of the crop rectangle in pixels. This is the most critical step.
            
            // 4a. Find the center of the on-screen crop box.
            let cropRectCenterInView = CGPoint(x: localCropRect.midX, y: localCropRect.midY)
            
            // 4b. Find the center of the image *as it currently appears on screen* (after pan and zoom).
            let imageCenterInView = CGPoint(x: fittedImageRectInView.midX + localOffset.width, y: fittedImageRectInView.midY + localOffset.height)
            
            // 4c. Find the vector from the panned image's center to the crop box's center. This is in view points.
            let deltaFromImageCenter = CGPoint(
                x: cropRectCenterInView.x - imageCenterInView.x,
                y: cropRectCenterInView.y - imageCenterInView.y
            )
            
            // 4d. "Un-zoom" this vector to find its length in the non-scaled coordinate space, then convert to pixels.
            // This correctly accounts for the fact that a pan of 10 points on a 2x zoomed image corresponds
            // to a smaller pixel distance in the source image.
            let deltaInPixels = CGPoint(
                x: (deltaFromImageCenter.x / localScale) * pixelsPerPoint,
                y: (deltaFromImageCenter.y / localScale) * pixelsPerPoint
            )
            
            // 4e. The center of the source image in pixels is its geometric center.
            let sourceImageCenterInPixels = CGPoint(x: imagePixelSize.width / 2.0, y: imagePixelSize.height / 2.0)
            
            // 4f. Add the calculated pixel delta to the source image's center to find the final crop center in pixels.
            let cropRectCenterInPixels = CGPoint(
                x: sourceImageCenterInPixels.x + deltaInPixels.x,
                y: sourceImageCenterInPixels.y + deltaInPixels.y
            )
            
            // Step 5: Construct the final crop rectangle from its center and size in pixels.
            let finalCropRectInPixels = CGRect(
                x: cropRectCenterInPixels.x - (cropRectPixelSize.width / 2.0),
                y: cropRectCenterInPixels.y - (cropRectPixelSize.height / 2.0),
                width: cropRectPixelSize.width,
                height: cropRectPixelSize.height
            )
            
            // Step 6: Use the calculated pixel-perfect rectangle to process the image.
            let finalImage = ImageProcessor.process(image: sourceImage)
                .crop(to: finalCropRectInPixels)
                .resize(to: targetSize)
                .result
            
            return finalImage
        }.value
    }
}

// MARK: - Helper Shape

private struct HoleShape: Shape {
    let rect: CGRect
    func path(in rect: CGRect) -> Path {
        var path = Rectangle().path(in: rect)
        let maskShape = RoundedRectangle(cornerRadius: rect.size.width / 2, style: .continuous)
        path.addPath(maskShape.path(in: self.rect))
        return path
    }
}

/// A utility for performing chained image transformations using a fluent interface.
struct ImageProcessor {
    private var image: UIImage
    
    /// The resulting image after all transformations have been applied.
    var result: UIImage {
        image
    }
    
    /// Initializes the processor with a source image.
    /// - Parameter image: The `UIImage` to be processed.
    private init(image: UIImage) {
        self.image = image
    }
    
    /// Factory method to start a processing pipeline.
    /// - Parameter image: The source `UIImage`.
    /// - Returns: An `ImageProcessor` instance ready for chaining operations.
    static func process(image: UIImage) -> ImageProcessor {
        return ImageProcessor(image: image)
    }
    
    /// Crops the image to a specified rectangle.
    /// The rectangle is in the coordinate space of the original, un-oriented image.
    /// - Parameter rect: The `CGRect` to crop.
    /// - Returns: A new `ImageProcessor` instance with the cropped image.
    func crop(to rect: CGRect) -> ImageProcessor {
        guard let cgImage = image.cgImage,
              let croppedCgImage = cgImage.cropping(to: rect)
        else {
            // Return self to allow chaining to continue, even though the operation failed.
            // The original image will be preserved.
            return self
        }
        
        let croppedImage = UIImage(
            cgImage: croppedCgImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )
        return ImageProcessor(image: croppedImage)
    }
    
    /// Resizes the image to a target size using high-quality resampling.
    /// - Parameter size: The target `CGSize` for the output image.
    /// - Returns: A new `ImageProcessor` instance with the resized image.
    func resize(to size: CGSize) -> ImageProcessor {
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return ImageProcessor(image: resizedImage)
    }
}


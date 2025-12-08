import Dependencies
import SwiftUI
import ScopeGraph

struct AttachmentImage: View {
    @Dependency(\.scope) private var scope
    @State private var attachment: FetchedObject<Attachment>?
    @State private var image: UIImage?
    
    let attachmentID: String
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .frame(width: 50, height: 50)
            }
        }
        .animation(.smooth, value: image == nil)
        .task(id: attachmentID) {
            self.attachment = .init(Attachment.byID(attachmentID), context: scope.coreDataContext)
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let attachment = attachment else { return }
        
        // if let data = attachment.native {
        //     image = UIImage(data: data)
        // } else if data = attachment.raw {
        //     image = UIImage(data: data)
        // }
    }
}

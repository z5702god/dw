import UIKit
import FirebaseStorage

final class StorageRepository {
    static let shared = StorageRepository()

    private let storage = Storage.storage()
    private let maxDimension: CGFloat = 1200
    private let compressionQuality: CGFloat = 0.7

    private init() {}

    func uploadPhotos(_ images: [UIImage], mealId: String) async throws -> [String] {
        var urls: [String] = []

        for (index, image) in images.enumerated() {
            let resized = resizeImage(image)
            guard let data = resized.jpegData(compressionQuality: compressionQuality) else { continue }

            let path = "couples/\(FirebaseConfig.coupleId)/meals/\(mealId)/photo_\(index).jpg"
            let ref = storage.reference(withPath: path)

            _ = try await ref.putDataAsync(data)
            let url = try await ref.downloadURL()
            urls.append(url.absoluteString)
        }

        return urls
    }

    private func resizeImage(_ image: UIImage) -> UIImage {
        let size = image.size
        let maxSide = max(size.width, size.height)

        guard maxSide > maxDimension else { return image }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

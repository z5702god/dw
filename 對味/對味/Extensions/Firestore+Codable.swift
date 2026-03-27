import FirebaseFirestore

extension CollectionReference {
    func addDocument<T: Encodable>(from value: T) async throws {
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(value)
        try await addDocument(data: data)
    }
}

import FirebaseFirestore

extension CollectionReference {
    func addDocument<T: Encodable>(from value: T) throws {
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(value)
        addDocument(data: data)
    }
}

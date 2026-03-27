import FirebaseFirestore

enum FirebaseConfig {
    static let coupleId = "couple_001"

    private static var coupleDocument: DocumentReference {
        Firestore.firestore().collection("couples").document(coupleId)
    }

    static var mealsCollection: CollectionReference {
        coupleDocument.collection("meals")
    }

    static var rewardsCollection: CollectionReference {
        coupleDocument.collection("rewards")
    }

    static var usersCollection: CollectionReference {
        Firestore.firestore().collection("users")
    }

    static func userDocument(_ userId: String) -> DocumentReference {
        usersCollection.document(userId)
    }
}

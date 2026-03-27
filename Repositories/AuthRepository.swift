import FirebaseAuth
import FirebaseFirestore

@Observable
final class AuthRepository {
    static let shared = AuthRepository()

    var currentUser: FirebaseAuth.User? = Auth.auth().currentUser
    var appUser: AppUser?
    var isSignedIn: Bool { currentUser != nil }

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?

    private init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            if let uid = user?.uid {
                self?.listenToUserDocument(uid: uid)
            } else {
                self?.userListener?.remove()
                self?.appUser = nil
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    private func listenToUserDocument(uid: String) {
        userListener?.remove()
        userListener = FirebaseConfig.userDocument(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot, snapshot.exists else { return }
                self?.appUser = try? snapshot.data(as: AppUser.self)
            }
    }

    var currentUserId: String? {
        currentUser?.uid
    }

    var partnerName: String {
        appUser?.displayName ?? "對方"
    }
}

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
                self?.partnerListener?.remove()
                self?.appUser = nil
                self?.partnerUser = nil
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        guard let uid = currentUser?.uid else { return }
        // 刪除 Firestore 使用者文件
        try await FirebaseConfig.userDocument(uid).delete()
        // 刪除 Firebase Auth 帳號（auth state listener 會自動清理）
        try await Auth.auth().currentUser?.delete()
    }

    private func listenToUserDocument(uid: String) {
        userListener?.remove()
        userListener = FirebaseConfig.userDocument(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    #if DEBUG
                    print("[AuthRepository] Firestore listener error: \(error.localizedDescription)")
                    #endif
                    return
                }
                guard let snapshot, snapshot.exists else {
                    #if DEBUG
                    print("[AuthRepository] No user document found for \(uid), creating one...")
                    #endif
                    self?.createUserDocument(uid: uid)
                    return
                }
                do {
                    self?.appUser = try snapshot.data(as: AppUser.self)
                    #if DEBUG
                    print("[AuthRepository] Loaded user: \(self?.appUser?.displayName ?? "?"), role: \(self?.appUser?.role.rawValue ?? "?"), isKathy: \(self?.appUser?.isKathy ?? false)")
                    #endif
                    // 載入對方的資料
                    if let coupleId = self?.appUser?.coupleId {
                        self?.listenToPartner(coupleId: coupleId, myUid: uid)
                    }
                    // 一次性修正：Firestore 資料存反了
                    var fieldsToFix: [String: Any] = [:]
                    if let expectedName = Self.expectedDisplayName(for: uid),
                       self?.appUser?.displayName != expectedName {
                        fieldsToFix["displayName"] = expectedName
                        #if DEBUG
                        print("[AuthRepository] Fixing displayName: '\(self?.appUser?.displayName ?? "?")' → '\(expectedName)'")
                        #endif
                    }
                    // 同步 email：以 Firebase Auth 為準
                    if let authEmail = self?.currentUser?.email,
                       self?.appUser?.email != authEmail {
                        fieldsToFix["email"] = authEmail
                        #if DEBUG
                        print("[AuthRepository] Fixing email: '\(self?.appUser?.email ?? "?")' → '\(authEmail)'")
                        #endif
                    }
                    if !fieldsToFix.isEmpty {
                        Task {
                            try? await FirebaseConfig.userDocument(uid).updateData(fieldsToFix)
                        }
                    }
                    // 補寫缺失的 role 欄位
                    if self?.appUser?.roleRawValue == nil {
                        let role = Self.inferRole(for: uid)
                        if let role {
                            Task {
                                try? await FirebaseConfig.userDocument(uid).updateData(["role": role])
                                #if DEBUG
                                print("[AuthRepository] Backfilled role '\(role)' for user \(uid)")
                                #endif
                            }
                        }
                    }
                } catch {
                    #if DEBUG
                    print("[AuthRepository] Failed to decode AppUser: \(error)")
                    #endif
                    self?.appUser = nil
                }
            }
    }

    private func createUserDocument(uid: String) {
        guard let firebaseUser = currentUser else { return }
        let displayName = firebaseUser.displayName
            ?? firebaseUser.email?.components(separatedBy: "@").first
            ?? "User"
        let role = Self.inferRole(for: uid)
        let newUser = AppUser(
            email: firebaseUser.email ?? "",
            displayName: displayName,
            coupleId: "couple_001",
            totalPoints: 0,
            roleRawValue: role
        )
        Task {
            do {
                try FirebaseConfig.userDocument(uid).setData(from: newUser)
                #if DEBUG
                print("[AuthRepository] Created user document for \(displayName) (role: \(role ?? "none"))")
                #endif
            } catch {
                #if DEBUG
                print("[AuthRepository] Failed to create user document: \(error)")
                #endif
            }
        }
    }

    private static func inferRole(for uid: String) -> String? {
        switch uid {
        case "cdQV8F8j9NYyfI1Y4kKNV1hWrPB2": return CoupleRole.pointsEarner.rawValue
        case "M0143zxobBXxZ6vAAgX6jq8ll1g2": return CoupleRole.rewardFulfiller.rawValue
        default: return nil
        }
    }

    private static func expectedDisplayName(for uid: String) -> String? {
        switch uid {
        case "cdQV8F8j9NYyfI1Y4kKNV1hWrPB2": return "Kathy"
        case "M0143zxobBXxZ6vAAgX6jq8ll1g2": return "Luke"
        default: return nil
        }
    }

    var currentUserId: String? {
        currentUser?.uid
    }

    var partnerName: String {
        partnerUser?.displayName ?? "對方"
    }

    // MARK: - Partner

    var partnerUser: AppUser?
    private var partnerListener: ListenerRegistration?

    private func listenToPartner(coupleId: String, myUid: String) {
        partnerListener?.remove()
        partnerListener = FirebaseConfig.usersCollection
            .whereField("coupleId", isEqualTo: coupleId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self?.partnerUser = documents.compactMap { doc in
                    let user = try? doc.data(as: AppUser.self)
                    return user?.id != myUid ? user : nil
                }.first
            }
    }
}

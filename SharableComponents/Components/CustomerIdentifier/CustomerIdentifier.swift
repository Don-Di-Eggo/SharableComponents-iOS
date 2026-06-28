import Foundation

/// Generates and persists a stable anonymous identifier for this app install.
/// The UUID is created once on first access and stored in UserDefaults.
/// Use `CustomerIdentifier.shared.id` anywhere, or pass the suite name that
/// matches your other components so the ID lives in the same UserDefaults group.
public final class CustomerIdentifier {

    public static let shared = CustomerIdentifier()

    // MARK: - Public

    /// The stable UUID string for this install. Created on first access, never changes.
    public let id: String

    // MARK: - Init

    public init(suiteName: String? = nil) {
        let defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
        if let existing = defaults.string(forKey: Self.key) {
            id = existing
        } else {
            let fresh = UUID().uuidString
            defaults.set(fresh, forKey: Self.key)
            id = fresh
        }
    }

    // MARK: - Private

    private static let key = "ci_customerID"
}

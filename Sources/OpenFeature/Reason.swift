import Foundation

public enum Reason: String {
    /// The resolved value was the result of the flag being disabled in the management system.
    case disabled
    /// The resolved value was the result of pseudorandom assignment.
    case split
    /// The resolved value was the result of a dynamic evaluation, such as a rule or specific user-targeting.
    case targetingMatch
    /// The resolved value was configured statically, or otherwise fell back to a pre-configured value.
    case defaultReason
    /// The reason for the resolved value could not be determined.
    case unknown
    /// The resolved value was the result of an error.
    case error
}

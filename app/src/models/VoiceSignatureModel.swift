import Foundation

/// Represents a single voice signature record.
/// This model is used for transferring data between the database service and the view model,
/// and potentially for UI display if needed.
struct VoiceSignatureModel: Identifiable, Equatable {
    /// A unique identifier for the voice signature.
    let id: UUID
    /// The date and time when the voice signature was recorded.
    let timestamp: Date
    /// The raw data of the calculated Mel Frequency Cepstral Coefficients (MFCCs) or other features.
    /// This is typically serialized data (e.g., JSON or a custom binary format of `[[Double]]`).
    let mfccData: Data
    /// An optional path to the original audio file from which the signature was derived.
    /// This might be useful for debugging or re-processing but could be nil if the original audio is not stored.
    let originalFilePath: String?

    // MARK: - Equatable Conformance
    /// Checks if two `VoiceSignatureModel` instances are equal based on all their properties.
    static func == (lhs: VoiceSignatureModel, rhs: VoiceSignatureModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.timestamp == rhs.timestamp &&
               lhs.mfccData == rhs.mfccData &&
               lhs.originalFilePath == rhs.originalFilePath
    }
}

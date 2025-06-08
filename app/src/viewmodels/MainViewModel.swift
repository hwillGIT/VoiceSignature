import Foundation
import Combine // For @Published

// Assuming these protocols and models are defined elsewhere and accessible:
// protocol AudioServicing { ... } from AudioService.swift
// protocol CepstrumServicing { ... } and typealias MFCCResult from CepstrumService.swift
// protocol DatabaseServicing { ... } from DatabaseService.swift
// struct VoiceSignatureModel { ... } from VoiceSignatureModel.swift
// enum AudioServicingError: Error { ... }
// enum CepstrumServicingError: Error { ... }
// enum DatabaseServicingError: Error { ... }


/// `MainViewModel` is an `ObservableObject` that manages the state and logic for the main voice recording view (`ContentView`).
/// It coordinates interactions between the UI and various services (audio, cepstrum, database).
class MainViewModel: ObservableObject {
    // MARK: - Published Properties for UI State
    /// The primary message displayed to the user, indicating current status or errors.
    @Published var statusMessage: String = "Press Record to Start"
    /// The title displayed on the main action button (e.g., "Record", "Recording...", "Try Again").
    @Published var recordButtonTitle: String = "Record Voice Signature"
    /// Boolean indicating if audio recording is currently active, used for UI cues like microphone icon animation.
    @Published var isRecordingActive: Bool = false
    /// Boolean indicating if a background task (like MFCC processing or saving) is in progress, used to show a loading indicator.
    @Published var isLoading: Bool = false
    /// Boolean controlling whether the main action button is enabled or disabled.
    @Published var isButtonEnabled: Bool = true

    // Optional properties for more complex alert/dialog presentation:
    // @Published var showAlert: Bool = false
    // @Published var alertMessage: String = ""

    // MARK: - Dependencies
    /// Service responsible for audio recording functionalities.
    private let audioService: AudioServicing
    /// Service responsible for Mel Cepstrum (MFCC) calculation.
    private let cepstrumService: CepstrumServicing
    /// Service responsible for database operations (saving/fetching signatures).
    private let databaseService: DatabaseServicing

    /// A set to store Combine cancellables for any subscriptions made by this ViewModel.
    private var cancellables = Set<AnyCancellable>()

    /// Initializes the ViewModel with its required service dependencies.
    /// - Parameters:
    ///   - audioService: An object conforming to `AudioServicing`.
    ///   - cepstrumService: An object conforming to `CepstrumServicing`.
    ///   - databaseService: An object conforming to `DatabaseServicing`.
    init(audioService: AudioServicing, cepstrumService: CepstrumServicing, databaseService: DatabaseServicing) {
        self.audioService = audioService
        self.cepstrumService = cepstrumService
        self.databaseService = databaseService

        // Example of an action that could be taken upon initialization, e.g., from View's .onAppear()
        // self.checkInitialPermissions()
    }

    // /// Example method to check for initial microphone permissions when the view appears.
    // func checkInitialPermissions() {
    //     audioService.requestPermission { [weak self] granted in
    //         DispatchQueue.main.async {
    //             if !granted {
    //                 self?.statusMessage = "Microphone permission is required to use this app."
    //                 self?.recordButtonTitle = "Permission Needed"
    //                 // self?.isButtonEnabled = false; // Optionally disable if permission is crucial initially
    //             }
    //         }
    //     }
    // }

    // MARK: - Public Methods (triggered by View interactions)

    /// Handles the primary action when the record button is tapped by the user.
    /// This function orchestrates the permission request and subsequent recording process.
    func handleRecordButtonTap() {
        // Immediately update UI to reflect that an action is starting.
        DispatchQueue.main.async {
            self.isButtonEnabled = false // Disable button during this operation.
            self.recordButtonTitle = "Checking Permission..."
            self.statusMessage = "Requesting microphone access..."
        }

        // Request microphone permission from the audio service.
        audioService.requestPermission { [weak self] granted in
            guard let self = self else { return } // Ensure self is still available.

            if granted {
                // Permission granted, proceed to start the recording process.
                self.startRecordingProcess()
            } else {
                // Permission denied, update UI to inform the user.
                DispatchQueue.main.async {
                    self.statusMessage = "Error: Microphone permission denied. Please enable it in Settings."
                    self.recordButtonTitle = "Permission Denied"
                    self.isButtonEnabled = true // Re-enable button to allow another attempt or guide to settings.
                    // Optionally, trigger an alert for more detailed guidance:
                    // self.showAlert = true; self.alertMessage = "Microphone permission is required to record audio. Please go to Settings > Privacy > Microphone to enable it for this app."
                }
            }
        }
    }

    /// Initiates the audio recording sequence after permissions are confirmed.
    /// Updates UI state for recording and calls the audio service.
    private func startRecordingProcess() {
        DispatchQueue.main.async {
            self.statusMessage = "Recording..."
            self.recordButtonTitle = "Recording..." // Button is already disabled from handleRecordButtonTap
            self.isRecordingActive = true // For visual cues like mic icon
            self.isLoading = false // Not loading yet, just recording
        }

        // Call the audio service to record audio for a fixed duration (e.g., 2.0 seconds).
        audioService.recordAudio(duration: 2.0) { [weak self] result in
            guard let self = self else { return }

            // Update UI immediately after recording attempt finishes.
            DispatchQueue.main.async {
                self.isRecordingActive = false // Turn off recording visual cue.
            }

            switch result {
            case .success(let audioURL):
                // Recording successful, proceed to process the audio file.
                self.processAudioFile(url: audioURL)
            case .failure(let error):
                // Recording failed, update UI with error message.
                DispatchQueue.main.async {
                    print("ERROR: Audio recording failed: \(error.localizedDescription)")
                    self.statusMessage = "Error: Recording failed. \(error.localizedDescription)"
                    self.resetToIdleState(buttonTitle: "Try Again Recording")
                }
            }
        }
    }

    /// Processes the recorded audio file to extract MFCC features.
    /// Updates UI for processing state and calls the cepstrum service.
    /// - Parameter url: The `URL` of the recorded audio file.
    private func processAudioFile(url: URL) {
        DispatchQueue.main.async {
            self.statusMessage = "Processing signature..."
            self.recordButtonTitle = "Processing..." // Button remains disabled.
            self.isLoading = true // Show loading indicator.
        }

        // Call the cepstrum service to calculate MFCCs from the audio file.
        cepstrumService.calculateMFCC(fromAudioURL: url) { [weak self] result in
            guard let self = self else { return }

            // Attempt to clean up the temporary audio file from disk in a background thread.
            // This is important to free up space.
            DispatchQueue.global(qos: .background).async {
                do {
                    try FileManager.default.removeItem(at: url)
                    print("Temporary audio file deleted: \(url.lastPathComponent)")
                } catch {
                    // Log error but don't let it block the main flow if deletion fails.
                    print("WARN: Error deleting temporary audio file \(url.lastPathComponent): \(error.localizedDescription)")
                }
            }

            switch result {
            case .success(let mfccFeatures):
                // MFCC calculation successful, proceed to save the signature.
                self.saveSignature(mfccFeatures: mfccFeatures, originalFilePath: url.path) // Pass original path for reference
            case .failure(let error):
                // MFCC calculation failed, update UI with error.
                DispatchQueue.main.async {
                    print("ERROR: MFCC calculation failed: \(error.localizedDescription)")
                    self.statusMessage = "Error: Processing failed. \(error.localizedDescription)"
                    self.isLoading = false // Hide loading indicator.
                    self.resetToIdleState(buttonTitle: "Try Again Processing")
                }
            }
        }
    }

    /// Saves the processed voice signature (MFCC features) to the database.
    /// - Parameters:
    ///   - mfccFeatures: The calculated `MFCCResult` (array of arrays of Doubles).
    ///   - originalFilePath: Optional path string of the original audio file for reference.
    private func saveSignature(mfccFeatures: MFCCResult, originalFilePath: String?) {
        // Serialize MFCCResult ([[Double]]) to Data using JSONEncoder.
        // For production, a more compact binary format or direct Core Data modeling of arrays might be preferred.
        let encoder = JSONEncoder()
        guard let mfccData = try? encoder.encode(mfccFeatures) else {
            DispatchQueue.main.async {
                print("ERROR: Failed to serialize MFCC features to Data.")
                self.statusMessage = "Error: Internal processing error (serialization)."
                self.isLoading = false // Hide loading indicator.
                self.resetToIdleState(buttonTitle: "Try Again Saving")
            }
            return
        }

        // Create a new VoiceSignatureModel to be saved.
        let newSignature = VoiceSignatureModel(
            id: UUID(), // Generate a unique ID for the new signature.
            timestamp: Date(), // Record the current time.
            mfccData: mfccData, // The serialized MFCC data.
            originalFilePath: originalFilePath // Store path of the temporary audio file for reference.
        )

        // Call the database service to save the new signature.
        databaseService.saveSignature(model: newSignature) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false // Hide loading indicator after save attempt.
                switch result {
                case .success:
                    // Save successful, update UI.
                    self.statusMessage = "Voice signature saved!"
                    self.resetToIdleState(buttonTitle: "Record Another")
                case .failure(let error):
                    // Save failed, update UI with error.
                    print("ERROR: Database save failed: \(error.localizedDescription)")
                    self.statusMessage = "Error: Could not save signature. \(error.localizedDescription)"
                    self.resetToIdleState(buttonTitle: "Try Again Saving")
                }
            }
        }
    }

    /// Resets the UI to an idle state, typically after an operation completes or fails.
    /// All UI updates are performed on the main thread.
    /// - Parameter buttonTitle: The title to set for the record button in the idle state.
    private func resetToIdleState(buttonTitle: String = "Record Voice Signature") {
        DispatchQueue.main.async {
            self.recordButtonTitle = buttonTitle
            self.isRecordingActive = false
            self.isLoading = false
            self.isButtonEnabled = true // Re-enable the button.

            // Conditionally reset statusMessage to avoid overwriting specific success/error messages
            // that should be visible to the user until the next action.
            let lowercasedStatus = self.statusMessage.lowercased()
            if lowercasedStatus.contains("recording") ||
               lowercasedStatus.contains("processing") ||
               lowercasedStatus.contains("initializing") ||
               lowercasedStatus.contains("permission") ||
               (lowercasedStatus.contains("error") && buttonTitle == "Record Another") { // If error but allowing new recording, reset.
                 self.statusMessage = "Press Record to Start"
            }
            // If statusMessage was "Voice signature saved!" or a specific error related to "Try Again",
            // it will persist until the next user interaction that changes it.
        }
    }

    // MARK: - Placeholder for fetching and displaying signatures (for future UI)
    // func fetchAllSignatures() {
    //     // Example: Update a @Published property with fetched signatures
    //     // databaseService.fetchSignatures { [weak self] result in
    //     //     DispatchQueue.main.async {
    //     //         switch result {
    //     //         case .success(let models):
    //     //             self?.signatures = models // Assuming @Published var signatures: [VoiceSignatureModel] = []
    //     //             self?.statusMessage = "Signatures loaded."
    //     //         case .failure(let error):
    //     //             self?.statusMessage = "Error fetching signatures: \(error.localizedDescription)"
    //     //         }
    //     //     }
    //     // }
    // }
}

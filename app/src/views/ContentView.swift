import SwiftUI

// Assume MainViewModel and its dependencies (services, models) are defined
// and accessible as per previous subtasks.
// E.g., MainViewModel from app/src/viewmodels/MainViewModel.swift
// AVFAudioService from app/src/audio/AudioService.swift
// LocalCepstrumService from app/src/processing/CepstrumService.swift
// CoreDataService from app/src/database/DatabaseService.swift

struct ContentView: View {
    // @StateObject ensures that the MainViewModel instance is kept alive
    // for the lifecycle of the ContentView. It's created once when the ContentView is initialized.
    @StateObject private var viewModel: MainViewModel

    // Initializer for ContentView.
    // This setup demonstrates how services (Audio, Cepstrum, Database) are instantiated
    // and then injected into the MainViewModel.
    //
    // For a production application, dependency injection (DI) would typically be managed
    // more robustly, perhaps using a DI container framework or by passing dependencies
    // down from a higher level in the application structure (e.g., from the main App struct).
    //
    // The current approach of initializing concrete service types here is functional for this
    // skeleton project but makes swapping implementations (e.g., for testing or different build targets)
    // less flexible without modifying ContentView directly.
    //
    // **Important Note for CoreDataService**: The `CoreDataService()` initialization will only succeed
    // if the `VoiceSignatureAppModel.xcdatamodeld` file is correctly set up in the Xcode project
    // and included in the application's target.
    init() {
        // Instantiate concrete service implementations.
        let audioService = AVFAudioService()
        let cepstrumService = LocalCepstrumService() // Placeholder service for MFCC.
        let databaseService = CoreDataService()      // Core Data service.

        // Initialize MainViewModel with the instantiated services and wrap it in @StateObject.
        // This establishes the View-ViewModel connection.
        _viewModel = StateObject(wrappedValue: MainViewModel(
            audioService: audioService,
            cepstrumService: cepstrumService,
            databaseService: databaseService
        ))
    }

    // Alternative initializer (commented out) for use in Previews or unit tests.
    // This allows injecting a pre-configured or mock MainViewModel instance,
    // facilitating easier testing of different UI states.
    // To use this, make it public or internal as needed.
    //
    // init(viewModel: MainViewModel) {
    //     _viewModel = StateObject(wrappedValue: viewModel)
    // }

    var body: some View {
        // NavigationView provides a standard iOS navigation bar, useful for titles and potential future navigation.
        NavigationView {
            // VStack arranges its children in a vertical line. `spacing: 20` adds space between elements.
            VStack(spacing: 20) {

                // Status Message Display: Shows feedback to the user from the ViewModel.
                Text(viewModel.statusMessage)
                    .font(.headline) // Slightly larger, bolder text.
                    .multilineTextAlignment(.center) // Center align for multi-line messages.
                    // Dynamically changes text color to red if the status message indicates an error.
                    .foregroundColor(viewModel.statusMessage.lowercased().contains("error") ? .red : .primary)
                    .padding(.horizontal) // Horizontal padding.
                    .frame(minHeight: 60) // Ensures a minimum height for the text area, preventing layout jumps.

                // Record Button: The main action button for the user.
                Button(action: {
                    // When tapped, calls the `handleRecordButtonTap` method on the ViewModel.
                    viewModel.handleRecordButtonTap()
                }) {
                    // HStack arranges the button's icon and text horizontally.
                    HStack {
                        // Conditional icon display based on ViewModel state.
                        if viewModel.isRecordingActive {
                            Image(systemName: "mic.fill") // System icon indicating recording is active.
                                .transition(.opacity.combined(with: .scale)) // Smooth animation for icon change.
                        } else if viewModel.isLoading {
                            // No specific icon shown when loading; button text indicates state.
                        } else {
                            Image(systemName: "waveform.path.ecg") // Default system icon.
                                .transition(.opacity.combined(with: .scale))
                        }
                        // Button title text, driven by the ViewModel.
                        Text(viewModel.recordButtonTitle)
                            .fontWeight(.semibold)
                    }
                    .padding() // Padding inside the button.
                    .frame(minWidth: 0, maxWidth: .infinity) // Makes the button expand to available width.
                    .background(buttonBackgroundColor) // Dynamic background color (see computed property below).
                    .foregroundColor(.white) // Text and icon color.
                    .cornerRadius(12) // Rounded corners for the button.
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2) // Subtle drop shadow.
                }
                .disabled(!viewModel.isButtonEnabled) // Button is disabled based on ViewModel's `isButtonEnabled` state.
                .padding(.horizontal, 40) // External horizontal padding for the button.
                // Animations for changes in ViewModel states affecting the button's appearance.
                .animation(.easeInOut(duration: 0.2), value: viewModel.isRecordingActive)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isButtonEnabled)


                // Loading Indicator (ProgressView): Shown when `viewModel.isLoading` is true.
                if viewModel.isLoading {
                    ProgressView() // Standard circular progress indicator.
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue)) // Optional: custom tint.
                        .scaleEffect(1.5) // Makes the indicator slightly larger.
                        .padding(.top) // Padding above the indicator.
                        .transition(.scale.combined(with: .opacity)) // Animation for appearance/disappearance.
                } else {
                    // Placeholder Spacer to maintain layout stability when ProgressView is hidden.
                    // This prevents other elements from shifting up/down abruptly.
                    // Height is chosen to approximate the space taken by the ProgressView.
                    Spacer().frame(height: 20 * 1.5 + 16) // (scaleFactor * defaultSize) + approx padding
                }

                Spacer() // Pushes all content above it towards the top of the VStack.

                // Optional section for displaying a list of saved signatures (for future development).
                // Group {
                //     Text("Saved Signatures List (TODO)")
                //         .font(.caption)
                //         .foregroundColor(.gray)
                //     // List { /* ForEach(viewModel.signatures) { ... } */ }
                // }
                // .padding(.bottom)

            }
            .padding() // Padding for the entire VStack content.
            .navigationTitle("Voice Recorder") // Sets the title in the navigation bar.
            .navigationBarTitleDisplayMode(.inline) // Style for the navigation title (can be .large).

            // Example of how an alert could be presented, driven by ViewModel state (currently commented out).
            // .alert("Information", isPresented: $viewModel.showAlert, actions: {
            //     Button("OK", role: .cancel) { } // Simple dismiss button.
            // }, message: {
            //     Text(viewModel.alertMessage) // Message from ViewModel.
            // })
        }
        // Example of an action to perform when the view appears (currently commented out).
        // .onAppear {
        //      viewModel.checkInitialPermissions()
        // }
    }

    /// Computed property to determine the background color of the record button.
    /// This keeps the main `body` code cleaner by encapsulating button color logic.
    private var buttonBackgroundColor: Color {
        if !viewModel.isButtonEnabled {
            return .gray // Color for disabled state.
        }
        if viewModel.isRecordingActive {
            return .red.opacity(0.8) // Color when recording is active.
        }
        if viewModel.isLoading { // This state often overlaps with button being disabled.
            return .orange.opacity(0.8) // Color if button were visible during loading.
        }
        return .blue // Default color for active, non-recording state.
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // This preview uses the default `init()` of `ContentView`.
        // The `MainViewModel` and its concrete service dependencies (including placeholders)
        // will be instantiated automatically.
        //
        // **Important for CoreDataService in Previews**:
        // For `CoreDataService` (and thus `MainViewModel`) to initialize correctly
        // without crashing in previews, the `VoiceSignatureAppModel.xcdatamodeld` file
        // must be included in the target that builds for previews (usually the main app target).
        // If the model file is missing or misconfigured, `CoreDataService`'s `persistentContainer`
        // will fail to load, leading to a runtime error.
        ContentView()

        // Example of how to preview with a specifically configured ViewModel (currently commented out).
        // This is useful for testing different UI states directly in previews.
        // To enable this, you would typically:
        // 1. Make the alternative `init(viewModel: MainViewModel)` in `ContentView` public or internal.
        // 2. Define or import mock service implementations (like `MockAudioServicePreview` below).
        // 3. Create an instance of `MainViewModel` with these mocks.
        // 4. Configure the ViewModel's properties to represent the desired state.
        // 5. Pass the configured ViewModel to `ContentView(viewModel: ...)`.
        //
        // static var errorPreview: some View {
        //     // Instantiate mock services for the preview.
        //     let mockAudio = MockAudioServicePreview()
        //     let mockCepstrum = MockCepstrumServicePreview()
        //     let mockDb = MockDatabaseServicePreview()
        //
        //     // Configure a mock service to simulate a specific scenario (e.g., permission denied).
        //     mockAudio.permissionGranted = false
        //
        //     // Create the ViewModel with mocks.
        //     let errorVm = MainViewModel(audioService: mockAudio, cepstrumService: mockCepstrum, databaseService: mockDb)
        //
        //     // Optionally, directly set ViewModel properties to reflect the state for preview.
        //     // errorVm.statusMessage = "Preview: Microphone Permission Denied"
        //     // errorVm.recordButtonTitle = "Permission Needed"
        //     // errorVm.isButtonEnabled = true
        //
        //     return ContentView(viewModel: errorVm) // Assumes `init(viewModel:)` is accessible.
        // }
        //
        // static var recordingPreview: some View {
        //     let mockAudio = MockAudioServicePreview()
        //     mockAudio.isRecording = true // Simulate recording state in mock.
        //     let vm = MainViewModel(audioService: mockAudio, cepstrumService: MockCepstrumServicePreview(), databaseService: MockDatabaseServicePreview())
        //     // Directly set ViewModel properties for the "recording" state.
        //     vm.isRecordingActive = true
        //     vm.recordButtonTitle = "Recording..."
        //     vm.statusMessage = "Recording (1.5s)..."
        //     vm.isButtonEnabled = false
        //     return ContentView(viewModel: vm)
        // }
    }
}

// Example of minimal mock services that could be used for SwiftUI Previews (currently commented out).
// These would typically be defined in a separate file or within a #if DEBUG block.
// They provide stubbed implementations of the service protocols.
//
// #if DEBUG
// fileprivate class MockAudioServicePreview: AudioServicing {
//     var permissionGranted = true
//     var isRecording = false // Custom property for preview state
//     func requestPermission(completion: @escaping (Bool) -> Void) { completion(permissionGranted) }
//     func recordAudio(duration: TimeInterval, completion: @escaping (Result<URL, AudioServicingError>) -> Void) {
//         if isRecording {
//             completion(.success(URL(fileURLWithPath: "dummyPreview.m4a")))
//         } else {
//             completion(.failure(.permissionDenied)) // Default error for preview if not configured
//         }
//     }
// }
//
// fileprivate class MockCepstrumServicePreview: CepstrumServicing {
//     func calculateMFCC(fromAudioURL audioURL: URL, completion: @escaping (Result<MFCCResult, CepstrumServicingError>) -> Void) {
//         completion(.success([[0.1, 0.2]])) // Dummy MFCC data for preview
//     }
// }
//
// fileprivate class MockDatabaseServicePreview: DatabaseServicing {
//     func saveSignature(model: VoiceSignatureModel, completion: @escaping (Result<Void, DatabaseServicingError>) -> Void) { completion(.success(())) }
//     func fetchSignatures(completion: @escaping (Result<[VoiceSignatureModel], DatabaseServicingError>) -> Void) { completion(.success([])) }
//     func deleteSignature(id: UUID, completion: @escaping (Result<Void, DatabaseServicingError>) -> Void) { completion(.success(())) }
// }
// #endif
// fileprivate class MockAudioServicePreview: AudioServicing {
//     var permissionGranted = true
//     var isRecording = false
//     func requestPermission(completion: @escaping (Bool) -> Void) { completion(permissionGranted) }
//     func recordAudio(duration: TimeInterval, completion: @escaping (Result<URL, AudioServicingError>) -> Void) {
//         if isRecording { completion(.success(URL(fileURLWithPath: "dummy.m4a"))) }
//         else { completion(.failure(.permissionDenied)) }
//     }
// }
// fileprivate class MockCepstrumServicePreview: CepstrumServicing {
//     func calculateMFCC(fromAudioURL audioURL: URL, completion: @escaping (Result<MFCCResult, CepstrumServicingError>) -> Void) {
//         completion(.success([[0.0]]))
//     }
// }
// fileprivate class MockDatabaseServicePreview: DatabaseServicing {
//     func saveSignature(model: VoiceSignatureModel, completion: @escaping (Result<Void, DatabaseServicingError>) -> Void) { completion(.success(())) }
//     func fetchSignatures(completion: @escaping (Result<[VoiceSignatureModel], DatabaseServicingError>) -> Void) { completion(.success([])) }
// }
// #endif

import XCTest
import Combine
@testable import VoiceSignatureApp // Replace YourAppName with actual target name

// Unit tests for MainViewModel.
// Requires mocking AudioServicing, CepstrumServicing, and DatabaseServicing.
// These mocks will allow controlling the behavior of dependencies to test various scenarios.

// MARK: - Mock Services (Placeholders - to be fully implemented)

// A more complete mock would allow configuring the result of each method.
class MockAudioService: AudioServicing {
    var permissionGranted: Bool = true
    var recordAudioResult: Result<URL, AudioServicingError>? = .success(URL(fileURLWithPath: "dummy/path.m4a"))

    func requestPermission(completion: @escaping (Bool) -> Void) {
        completion(permissionGranted)
    }

    func recordAudio(duration: TimeInterval, completion: @escaping (Result<URL, AudioServicingError>) -> Void) {
        if let result = recordAudioResult {
            completion(result)
        } else {
            // Default behavior or fatalError if not configured for a test
            fatalError("MockAudioService.recordAudioResult not set for test.")
        }
    }
}

class MockCepstrumService: CepstrumServicing {
    var mfccResult: Result<MFCCResult, CepstrumServicingError>? = .success([[0.1, 0.2], [0.3, 0.4]]) // Dummy MFCC data

    func calculateMFCC(fromAudioURL audioURL: URL, completion: @escaping (Result<MFCCResult, CepstrumServicingError>) -> Void) {
        if let result = mfccResult {
            completion(result)
        } else {
            fatalError("MockCepstrumService.mfccResult not set for test.")
        }
    }
}

class MockDatabaseService: DatabaseServicing {
    var saveSignatureResult: Result<Void, DatabaseServicingError>? = .success(())
    var fetchedSignatures: [VoiceSignatureModel] = [] // For fetch tests

    func saveSignature(model: VoiceSignatureModel, completion: @escaping (Result<Void, DatabaseServicingError>) -> Void) {
        if let result = saveSignatureResult {
            if case .success = result {
                // Optionally store the model if testing fetch after save
                 fetchedSignatures.append(model)
            }
            completion(result)
        } else {
            fatalError("MockDatabaseService.saveSignatureResult not set for test.")
        }
    }

    func fetchSignatures(completion: @escaping (Result<[VoiceSignatureModel], DatabaseServicingError>) -> Void) {
        completion(.success(fetchedSignatures))
    }

    // func deleteSignature(id: UUID, completion: @escaping (Result<Void, DatabaseServicingError>) -> Void) { ... }
}


// MARK: - MainViewModelTests

class MainViewModelTests: XCTestCase {
    var viewModel: MainViewModel!
    var mockAudioService: MockAudioService!
    var mockCepstrumService: MockCepstrumService!
    var mockDatabaseService: MockDatabaseService!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = []

        mockAudioService = MockAudioService()
        mockCepstrumService = MockCepstrumService()
        mockDatabaseService = MockDatabaseService()

        viewModel = MainViewModel(
            audioService: mockAudioService,
            cepstrumService: mockCepstrumService,
            databaseService: mockDatabaseService
        )
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockAudioService = nil
        mockCepstrumService = nil
        mockDatabaseService = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.statusMessage, "Press Record to Start")
        XCTAssertEqual(viewModel.recordButtonTitle, "Record Voice Signature")
        XCTAssertFalse(viewModel.isRecordingActive)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.isButtonEnabled)
    }

    func testHandleRecordButtonTap_WhenPermissionDenied_UpdatesUIForPermissionError() {
        mockAudioService.permissionGranted = false
        let expectation = XCTestExpectation(description: "UI updates for permission denied")

        var finalStatusMessage = ""
        var finalButtonTitle = ""
        var finalIsEnabled = false

        // Listen to multiple publishers if needed or check properties after action
        viewModel.$statusMessage.dropFirst().sink { msg in finalStatusMessage = msg }.store(in: &cancellables)
        viewModel.$recordButtonTitle.dropFirst().sink { title in finalButtonTitle = title }.store(in: &cancellables)
        viewModel.$isButtonEnabled.dropFirst().sink { enabled in finalIsEnabled = enabled; expectation.fulfill() }.store(in: &cancellables)

        viewModel.handleRecordButtonTap()

        wait(for: [expectation], timeout: 1.0) // Wait for async permission check

        XCTAssertTrue(finalStatusMessage.lowercased().contains("permission denied"))
        XCTAssertEqual(finalButtonTitle, "Permission Denied")
        XCTAssertTrue(finalIsEnabled) // Button should be re-enabled
    }

    func testHandleRecordButtonTap_WhenRecordingSucceeds_ThenProcessingSucceeds_ThenSaveSucceeds_UpdatesUIThroughCycle() {
        // Configure mocks for success
        mockAudioService.permissionGranted = true
        let dummyURL = URL(fileURLWithPath: "test/audio.m4a")
        mockAudioService.recordAudioResult = .success(dummyURL)
        mockCepstrumService.mfccResult = .success([[1.0, 2.0]]) // Dummy MFCC
        mockDatabaseService.saveSignatureResult = .success(())

        let statusExpectation = XCTestExpectation(description: "Status message sequence: Recording -> Processing -> Saved")
        let buttonTitleExpectation = XCTestExpectation(description: "Button title sequence")
        let loadingExpectation = XCTestExpectation(description: "Loading state sequence")

        var statusMessages: [String] = []
        var buttonTitles: [String] = []
        var loadingStates: [Bool] = []

        viewModel.$statusMessage.sink { statusMessages.append($0) }.store(in: &cancellables)
        viewModel.$recordButtonTitle.sink { buttonTitles.append($0) }.store(in: &cancellables)
        viewModel.$isLoading.sink { loadingStates.append($0) }.store(in: &cancellables)

        // Fulfill expectations when the final state is reached
        viewModel.$statusMessage
            .filter { $0 == "Voice signature saved!" }
            .sink { _ in statusExpectation.fulfill() }
            .store(in: &cancellables)

        viewModel.$recordButtonTitle
            .filter { $0 == "Record Another" }
            .sink { _ in buttonTitleExpectation.fulfill() }
            .store(in: &cancellables)

        viewModel.$isLoading
            .filter { $0 == false && statusMessages.contains("Voice signature saved!") } // isLoading is false at the end
            .sink { _ in loadingExpectation.fulfill() }
            .store(in: &cancellables)

        viewModel.handleRecordButtonTap()

        wait(for: [statusExpectation, buttonTitleExpectation, loadingExpectation], timeout: 5.0) // Increased timeout for full flow

        // Assertions on the sequence of states (examples)
        XCTAssertTrue(statusMessages.contains(where: { $0.contains("Recording...") }))
        XCTAssertTrue(statusMessages.contains(where: { $0.contains("Processing signature...") }))
        XCTAssertEqual(viewModel.statusMessage, "Voice signature saved!")

        XCTAssertTrue(buttonTitles.contains(where: { $0.contains("Recording...") }))
        XCTAssertTrue(buttonTitles.contains(where: { $0.contains("Processing...") }))
        XCTAssertEqual(viewModel.recordButtonTitle, "Record Another")

        XCTAssertTrue(viewModel.isButtonEnabled)
        XCTAssertFalse(viewModel.isRecordingActive)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testHandleRecordButtonTap_WhenRecordingFails_UpdatesUIForRecordingError() {
        mockAudioService.permissionGranted = true
        mockAudioService.recordAudioResult = .failure(.recordingFailed(nil)) // Simulate recording failure

        let expectation = XCTestExpectation(description: "Status message updates to recording failed")

        viewModel.$statusMessage
            .dropFirst(2) // Initial, "Requesting...", "Recording..."
            .sink { message in
                if message.lowercased().contains("recording failed") {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.handleRecordButtonTap()
        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(viewModel.statusMessage.lowercased().contains("recording failed"))
        XCTAssertEqual(viewModel.recordButtonTitle, "Try Again Recording")
        XCTAssertTrue(viewModel.isButtonEnabled)
        XCTAssertFalse(viewModel.isRecordingActive)
        XCTAssertFalse(viewModel.isLoading)
    }

    // Add more tests for:
    // - MFCC calculation failure
    // - Database save failure
    // - Serialization failure for MFCC data
}

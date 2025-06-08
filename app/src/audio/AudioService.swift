import AVFoundation

/// Errors that can occur during audio servicing operations.
enum AudioServicingError: Error {
    /// The user denied permission to access the microphone.
    case permissionDenied
    /// Recording failed for a reason, possibly with an underlying system error.
    case recordingFailed(Error?)
    /// Failed to set up or configure the `AVAudioSession`.
    case sessionSetupFailed
    /// Failed to create the audio file on disk (though not explicitly used in current recording flow if URL is always valid).
    case fileCreationFailed
}

/// Defines the interface for an audio recording service.
protocol AudioServicing {
    /// Records audio for a specified duration and returns the URL to the recorded file.
    /// - Parameters:
    ///   - duration: The duration for which to record audio, in seconds.
    ///   - completion: A closure called upon completion, returning a `Result` with either the `URL` of the audio file or an `AudioServicingError`.
    func recordAudio(duration: TimeInterval, completion: @escaping (Result<URL, AudioServicingError>) -> Void)

    /// Requests permission from the user to record audio.
    /// - Parameter completion: A closure called with a boolean indicating whether permission was granted.
    func requestPermission(completion: @escaping (Bool) -> Void)
}

/// An implementation of `AudioServicing` using `AVFoundation` for audio recording.
/// This class handles microphone permission, audio session setup, recording, and delegate callbacks.
class AVFAudioService: NSObject, AudioServicing, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordingCompletion: ((Result<URL, AudioServicingError>) -> Void)?
    private var recordTimer: Timer? // Timer to automatically stop recording after a duration.

    /// Configures the shared `AVAudioSession` for recording.
    /// Sets category to `.playAndRecord` and activates the session.
    /// - Parameter completion: A closure called with the result of the session setup.
    private func setupSession(completion: @escaping (Result<Void, AudioServicingError>) -> Void) {
        let session = AVAudioSession.sharedInstance()
        do {
            // .playAndRecord is essential for initiating recording.
            // .defaultToSpeaker ensures audio output goes to speaker if no headphones are connected.
            // .allowBluetoothA2DP allows interaction with Bluetooth audio devices.
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try session.setActive(true)
            print("Audio session setup and activated successfully.")
            completion(.success(()))
        } catch {
            print("ERROR: Failed to set up or activate audio session: \(error.localizedDescription)")
            completion(.failure(.sessionSetupFailed))
        }
    }

    /// Prompts the user for microphone access permission.
    /// The completion handler is called on the main thread.
    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async { // Ensure UI updates or follow-up logic based on permission run on main thread.
                if granted {
                    print("Microphone permission granted.")
                } else {
                    print("WARN: Microphone permission denied by user.")
                }
                completion(granted)
            }
        }
    }

    /// Initiates audio recording for a specified duration.
    /// It first requests permission, then sets up the audio session,
    /// then configures and starts the `AVAudioRecorder`.
    /// A timer is used to stop the recording automatically.
    func recordAudio(duration: TimeInterval, completion: @escaping (Result<URL, AudioServicingError>) -> Void) {
        self.recordingCompletion = completion // Store completion handler to be called later.

        requestPermission { [weak self] granted in
            guard let self = self else { return }
            if !granted {
                self.recordingCompletion?(.failure(.permissionDenied))
                return
            }

            self.setupSession { sessionResult in
                switch sessionResult {
                case .failure(let error):
                    self.recordingCompletion?(.failure(error))
                    return
                case .success:
                    let tempDirectory = FileManager.default.temporaryDirectory
                    let fileName = UUID().uuidString + ".m4a" // Using m4a (AAC) as a common, compressed format.
                    let audioFileURL = tempDirectory.appendingPathComponent(fileName)
                    print("Recording to temporary file: \(audioFileURL.path)")

                    // Define audio settings for recording.
                    // These settings define the format (AAC), sample rate (44.1kHz), channels (mono), and quality.
                    let settings = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100, // CD quality sample rate
                        AVNumberOfChannelsKey: 1, // Mono recording
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue // High quality encoding
                    ]

                    do {
                        self.audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
                        self.audioRecorder?.delegate = self // Self will handle recorder delegate callbacks.

                        if self.audioRecorder?.record() == true {
                            print("Audio recording started successfully for \(duration) seconds.")
                            // Invalidate any existing timer and start a new one to stop recording.
                            self.recordTimer?.invalidate()
                            self.recordTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                                print("Recording timer fired. Stopping recording.")
                                self?.stopRecordingAndFinalize()
                            }
                        } else {
                            // `record()` can return false if it fails to start for some reason (e.g., resource conflict).
                            print("ERROR: AVAudioRecorder failed to start recording (record() returned false).")
                            self.recordingCompletion?(.failure(.recordingFailed(nil)))
                        }
                    } catch {
                        // AVAudioRecorder initialization can throw an error if URL is invalid or settings are not supported.
                        print("ERROR: Failed to initialize AVAudioRecorder: \(error.localizedDescription)")
                        self.recordingCompletion?(.failure(.recordingFailed(error)))
                    }
                }
            }
        }
    }

    /// Stops the current recording. Called by the timer.
    /// The actual result (success/failure) is delivered via the `audioRecorderDidFinishRecording` delegate method.
    private func stopRecordingAndFinalize() {
        guard let recorder = audioRecorder, recorder.isRecording else {
            print("WARN: stopRecordingAndFinalize called but recorder is not recording or nil.")
            return
        }
        print("AVAudioRecorder stop() called.")
        recorder.stop()
        // Note: `audioRecorderDidFinishRecording` will be called by the system after stop() completes.
    }

    // MARK: - AVAudioRecorderDelegate Methods

    /// Called by the system when a recording is finished successfully or unsuccessfully.
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording called. Success: \(flag)")
        recordTimer?.invalidate() // Ensure timer is stopped if recording finishes early or due to error.
        recordTimer = nil

        // It's good practice to deactivate the audio session when not actively using it,
        // allowing other apps to use audio resources.
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("Audio session deactivated.")
        } catch {
            // This is not a fatal error for the recording itself but should be logged.
            print("WARN: Failed to deactivate audio session: \(error.localizedDescription)")
        }

        if flag {
            print("Recording finished successfully. URL: \(recorder.url.path)")
            recordingCompletion?(.success(recorder.url))
        } else {
            // If !flag, an error occurred during recording (e.g., interruption, resource issue).
            // The 'recorder.error' property might contain more specific error information.
            print("ERROR: Recording finished unsuccessfully. Error: \(String(describing: recorder.error?.localizedDescription))")
            recordingCompletion?(.failure(.recordingFailed(recorder.error)))
        }
        self.audioRecorder = nil // Clean up the recorder instance.
    }

    /// Called by the system if an encoding error occurs during recording.
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("ERROR: Audio Recorder Encode Error: \(String(describing: error?.localizedDescription))")
        recordTimer?.invalidate()
        recordTimer = nil

        // Attempt to deactivate session even on encode error.
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("Audio session deactivated after encode error.")
        } catch {
            print("WARN: Failed to deactivate audio session during encode error: \(error.localizedDescription)")
        }

        recordingCompletion?(.failure(.recordingFailed(error)))
        self.audioRecorder = nil // Clean up.
    }
}

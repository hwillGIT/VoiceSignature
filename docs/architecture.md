# iOS/Swift Application Architecture: MVVM

This document outlines the Model-View-ViewModel (MVVM) architecture chosen for the iOS Voice Signature application, implemented in Swift.

## Chosen Architecture: MVVM (Model-View-ViewModel)

MVVM is chosen for its clear separation of concerns, testability, and good fit with SwiftUI's declarative nature.

## Components

### 1. Model

The Model represents the data and business logic of the application.
- **`VoiceSignature.swift`**: A struct or class defining the core data entity.
    - Properties:
        - `id: UUID` (Unique identifier for the signature)
        - `timestamp: Date` (When the signature was recorded)
        - `signatureData: Data` (Or an array of Floats/Doubles if representing MFCCs directly. `Data` is flexible for storing serialized MFCCs or raw processed output.)
        - `filePath: URL?` (Optional: if the raw audio is stored temporarily or permanently)

### 2. View

The View is responsible for the UI, displaying data from the ViewModel and forwarding user interactions to the ViewModel.
- **`ContentView.swift`** (SwiftUI):
    - Contains the UI elements described in `main_screen_layout.txt` (e.g., Record Button, Status Label).
    - Observes an instance of `MainViewModel` for state changes (e.g., `isRecording`, `statusMessage`) and updates the UI accordingly.
    - Forwards user actions (e.g., button taps) to the `MainViewModel`.

### 3. ViewModel

The ViewModel acts as an intermediary between the View and the Model (via Services). It prepares data for the View and handles UI logic.
- **`MainViewModel.swift`**: An `ObservableObject`.
    - **Published Properties (UI State):**
        - `isRecording: Bool` (To update button appearance/state)
        - `statusMessage: String` (To display feedback like "Recording...", "Signature Saved!", "Error...")
        - `recordedSignatures: [VoiceSignature]` (If displaying a list of saved signatures)
    - **Responsibilities:**
        - Contains the core application flow logic (previously in `main_flow.py`).
        - Initiates audio recording via `AudioService`.
        - Initiates Mel Cepstrum calculation via `CepstrumService`.
        - Initiates signature storage via `DatabaseService`.
        - Updates `statusMessage` and other UI state properties based on the outcomes of these operations.
        - Handles errors propagated from services and translates them into user-friendly messages.

### 4. Services (Dependencies for ViewModel)

Services encapsulate specific functionalities like audio handling, data processing, and database interaction. They are typically defined by protocols and injected into the ViewModel for testability and modularity.

- **`AudioService.swift`**:
    - **Protocol:** `AudioServicing`
        - `recordAudio(duration: TimeInterval, completion: @escaping (Result<URL, Error>) -> Void)`: Records audio and returns a URL to the temporary audio file.
        - `stopRecording()` (If manual stop is needed)
        - `checkPermissions(completion: @escaping (Bool) -> Void)`
    - **Concrete Implementation:** `AVFAudioService` (using `AVFoundation`)

- **`CepstrumService.swift`**:
    - **Protocol:** `CepstrumServicing`
        - `calculateMelCepstrum(fromAudioURL audioURL: URL, completion: @escaping (Result<Data, Error>) -> Void)`: Takes an audio file URL, processes it, and returns the Mel Cepstrum data (e.g., as `Data` or a custom struct/array).
    - **Concrete Implementation:** `AccelerateCepstrumService` (or a wrapper around a C/C++ library like Librosa via a bridging header, or a pure Swift implementation if available).

- **`DatabaseService.swift`**:
    - **Protocol:** `DatabaseServicing`
        - `saveSignature(_ signature: VoiceSignature, completion: @escaping (Result<Void, Error>) -> Void)`
        - `fetchSignatures(completion: @escaping (Result<[VoiceSignature], Error>) -> Void)`
        - `deleteSignature(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)`
        - `initializeDatabase(completion: @escaping (Result<Void, Error>) -> Void)` (If explicit setup is needed)
    - **Concrete Implementation:** `CoreDataService` (using Core Data) or `GRDBService` (using GRDB.swift for SQLite).

## Data Flow (Example: Recording a New Signature)

1.  **User Interaction (View):** User taps the "Record Voice Signature" button in `ContentView.swift`.
2.  **Action Forwarded (View -> ViewModel):** `ContentView` calls a method on `MainViewModel`, e.g., `startRecordingProcess()`.
3.  **State Update (ViewModel):** `MainViewModel` sets `isRecording = true` and `statusMessage = "Recording..."`. These changes are published to `ContentView`, which updates the UI.
4.  **Audio Recording (ViewModel -> AudioService):** `MainViewModel` calls `audioService.recordAudio(...)`.
5.  **AudioService Operation:** `AVFAudioService` uses `AVFoundation` to record audio. Upon completion (success or failure), it calls the completion handler.
6.  **Result Handling (AudioService -> ViewModel):**
    - **Success:** The completion handler provides a `URL` to the recorded audio file. `MainViewModel` updates `statusMessage = "Processing..."`.
    - **Failure:** An `Error` is returned. `MainViewModel` updates `statusMessage` with an error message (e.g., "Error: Recording failed") and sets `isRecording = false`. The flow stops.
7.  **Cepstrum Calculation (ViewModel -> CepstrumService):** On successful recording, `MainViewModel` calls `cepstrumService.calculateMelCepstrum(fromAudioURL: audioFileURL, ...)`.
8.  **CepstrumService Operation:** The service processes the audio file. Upon completion, it calls its completion handler.
9.  **Result Handling (CepstrumService -> ViewModel):**
    - **Success:** The completion handler provides the `signatureData` (e.g., MFCCs).
    - **Failure:** An `Error` is returned. `MainViewModel` updates `statusMessage` (e.g., "Error: Could not process audio") and sets `isRecording = false`. The flow stops.
10. **Data Preparation (ViewModel):** `MainViewModel` creates a `VoiceSignature` object using the `signatureData` and current timestamp.
11. **Database Storage (ViewModel -> DatabaseService):** `MainViewModel` calls `databaseService.saveSignature(newSignature, ...)`.
12. **DatabaseService Operation:** The service saves the `VoiceSignature` object to persistent storage (Core Data, SQLite).
13. **Result Handling (DatabaseService -> ViewModel):**
    - **Success:** `MainViewModel` updates `statusMessage = "Signature Saved!"`.
    - **Failure:** An `Error` is returned. `MainViewModel` updates `statusMessage` (e.g., "Error: Failed to save signature").
14. **Final State Update (ViewModel):** `MainViewModel` sets `isRecording = false`.

## Mapping to Placeholder Python Files

The placeholder Python files created earlier map to the iOS/Swift components as follows:

-   `app/src/audio/recorder.py`  ->  **`AudioService.swift`** (specifically the `AVFAudioService` implementation and `AudioServicing` protocol)
-   `app/src/processing/cepstrum.py`  ->  **`CepstrumService.swift`** (specifically the `AccelerateCepstrumService` implementation and `CepstrumServicing` protocol)
-   `app/src/database/db_handler.py`  ->  **`DatabaseService.swift`** (specifically the `CoreDataService` or `GRDBService` implementation and `DatabaseServicing` protocol)
-   Logic within `app/src/main_flow.py`  ->  Primarily resides in **`MainViewModel.swift`**, orchestrating calls to the services.
-   `app/src/ui/main_screen_layout.txt`  ->  Describes the UI elements and states managed by **`ContentView.swift`** and its corresponding `MainViewModel` properties.

## Conceptual Directory Structure (Swift Project)

A typical Swift project structure for this MVVM architecture might look like this:

```
AppName/
├── AppNameApp.swift           # Main app entry point
├── Models/
│   └── VoiceSignature.swift
├── Views/
│   └── ContentView.swift
├── ViewModels/
│   └── MainViewModel.swift
├── Services/
│   ├── Protocols/             # Optional: for service protocols
│   │   ├── AudioServicing.swift
│   │   ├── CepstrumServicing.swift
│   │   └── DatabaseServicing.swift
│   ├── Implementations/       # Optional: for concrete service classes
│   │   ├── AVFAudioService.swift
│   │   ├── AccelerateCepstrumService.swift
│   │   └── CoreDataService.swift # or GRDBService.swift
│   └── AudioService.swift       # Can also be flat if preferred
│   └── CepstrumService.swift
│   └── DatabaseService.swift
├── Utils/                     # Utility/helper functions or extensions
├── Resources/                 # Or SupportingFiles/
│   ├── Assets.xcassets        # Images, colors
│   └── Info.plist
└── Docs/
    └── architecture.md        # This file
```

This structure promotes organization and scalability as the application grows. Service protocols and their implementations can be further organized based on preference.

# Voice Signature App (iOS Skeleton)

## Voice Signature App Overview

This repository contains the skeleton structure for an iOS application designed to record, process, and store voice signatures. Users can record their voice, which is then (conceptually) processed to extract features (like Mel Frequency Cepstral Coefficients - MFCCs), and these features are stored locally on the device using Core Data. The UI is built with SwiftUI.

This project serves as a foundational blueprint, outlining the architecture, basic UI flow, and placeholder implementations for core service modules.

## Features (Current Skeleton)

*   **Audio Recording:** Captures audio from the microphone for a fixed duration (2 seconds).
*   **MFCC Calculation (Placeholder):** Includes a placeholder service for Mel Cepstrum (MFCC) calculation. The actual signal processing logic is **not yet implemented**.
*   **Local Storage:** Saves voice signature data (ID, timestamp, placeholder MFCC data, original audio file path) to a local Core Data store.
*   **User Interface:** A basic SwiftUI view allowing users to initiate recording and view status messages.
*   **MVVM Architecture:** Organized using the Model-View-ViewModel pattern with distinct service layers for audio, processing, and database operations.

## Architecture

The application follows the **MVVM (Model-View-ViewModel)** design pattern:

*   **Model:** `VoiceSignatureModel.swift` (data structure for voice signatures). Core Data entities (`VoiceSignatureEntity`) are used for persistence.
*   **View:** `ContentView.swift` (SwiftUI view for user interaction).
*   **ViewModel:** `MainViewModel.swift` (manages UI state, orchestrates calls to services, handles business logic).
*   **Services:**
    *   `AudioService.swift`: Handles audio recording (`AVFoundation`).
    *   `CepstrumService.swift`: Placeholder for MFCC calculation (intended for `Accelerate` framework or other DSP libraries).
    *   `DatabaseService.swift`: Manages data persistence using Core Data.

## Technologies

*   **Language:** Swift
*   **UI Framework:** SwiftUI
*   **Concurrency:** Combine (for `@Published` properties in ViewModel)
*   **Audio:** AVFoundation
*   **Database:** Core Data (current implementation)
*   **DSP/Signal Processing:** Intended for Accelerate framework (MFCC part is a placeholder).

## Getting Started / Developer Setup

### Prerequisites

*   Xcode (latest stable version recommended)
*   A macOS machine.
*   Basic knowledge of Swift and SwiftUI.

### Cloning the Repository

```bash
git clone <repository_url>
cd <repository_directory>
```

### Critical Step: Create Core Data Model

This project uses Core Data for local storage. The Swift code for `CoreDataService.swift` expects a Core Data Model file to be present in your Xcode project. **You must create this manually.**

1.  Open the `.xcodeproj` or `.xcworkspace` file in Xcode.
2.  In the Project Navigator (left sidebar), right-click on your main app group (usually the folder with your app's name) or a suitable subgroup like `app/src/database/` (though typically models are top-level or in a "Models" group).
3.  Select **"New File..."**.
4.  Under the "iOS" tab, scroll down to the "Core Data" section and select **"Data Model"**. Click "Next".
5.  For the "Save As" name, enter: **`VoiceSignatureAppModel.xcdatamodeld`**. Ensure it's added to your main application target.
6.  Click "Create".
7.  Select the newly created `VoiceSignatureAppModel.xcdatamodeld` file in the Project Navigator.
8.  In the Core Data model editor, click the **"+" button** at the bottom to **"Add Entity"**.
9.  Name the new entity **`VoiceSignatureEntity`**.
10. With `VoiceSignatureEntity` selected, add the following attributes in the "Attributes" section of the Data Model Inspector (right sidebar):
    *   **Attribute:** `id`
        *   **Type:** `UUID`
    *   **Attribute:** `timestamp`
        *   **Type:** `Date`
    *   **Attribute:** `mfccData`
        *   **Type:** `Binary Data`
    *   **Attribute:** `originalFilePath`
        *   **Type:** `String`
        *   **Optional:** Check the "Optional" box.

    (Ensure the "Codegen" option for the entity is set to "Class Definition" or "Category/Extension" if you plan to use generated NSManagedObject subclasses, though the current service uses KVC).

### Info.plist - Microphone Permission

For audio recording to work, you must provide a reason for microphone usage in your app's `Info.plist` file.

1.  In Xcode, open your project's `Info.plist` file.
2.  Add a new key by clicking the "+" button on any existing key.
3.  Search for and select **`Privacy - Microphone Usage Description`** (its raw key is `NSMicrophoneUsageDescription`).
4.  In the "Value" column for this key, provide a user-facing string explaining why your app needs microphone access. For example:
    *   `This app requires microphone access to record your voice signature for authentication and profile creation.`

### Building and Running

1.  Select a simulator or a connected iOS device in Xcode.
2.  Click the "Play" button (or Product > Run) to build and run the application.

## Project Structure

*   **`app/`**: Contains the main source code for the iOS application.
    *   **`src/`**: A subdirectory structure used in this project for organizing Swift files.
        *   `audio/`: Audio recording service (`AudioService.swift`).
        *   `database/`: Core Data service (`DatabaseService.swift`).
        *   `models/`: Data model structures (`VoiceSignatureModel.swift`).
        *   `processing/`: Feature extraction service (`CepstrumService.swift` - placeholder).
        *   `viewmodels/`: ViewModels connecting View and Model/Services (`MainViewModel.swift`).
        *   `views/`: SwiftUI views (`ContentView.swift`).
    *   `VoiceSignatureAppApp.swift`: The main entry point of the SwiftUI application.
*   **`docs/`**: Contains markdown documentation files (architecture, UI flow, project setup).
*   **`tests/`**: Contains placeholder unit test files for the services and ViewModel.

## Key Pending Implementation

*   **MFCC Calculation:** The `LocalCepstrumService.swift` file currently contains only placeholder logic for MFCC calculation. The detailed steps commented within this file need to be implemented using the Accelerate framework or another suitable DSP library. This is a critical component for the app's core functionality.

## Further Information

For more detailed information on specific aspects of the project, refer to the documents in the `docs/` directory:

*   `docs/architecture.md`: Describes the MVVM architecture and component interactions.
*   `docs/ui_flow.md`: Details the user interface flow and screen states.
*   `docs/project_setup.md`: Provides conceptual details for setting up a Swift project for this application.

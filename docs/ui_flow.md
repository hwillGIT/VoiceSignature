# UI Flow and Screen States

This document details the user journey and corresponding screen states for the Voice Signature application's main recording interface, designed with an iOS (SwiftUI) and MVVM architecture in mind.

## User Journey

The primary user journey for recording a voice signature involves the following steps:

1.  **Initial State (Idle):**
    *   The user opens the app or navigates to the main recording screen.
    *   The UI displays a prompt to start recording (e.g., "Press Record to Start").
    *   The record button is active and clearly labeled (e.g., "Record Voice Signature").

2.  **Button Tap (Initiate Recording):**
    *   The user taps the "Record Voice Signature" button.
    *   The application requests microphone permissions if not already granted. If denied, an error state is entered.

3.  **Recording Active:**
    *   The UI visually indicates that recording is in progress (e.g., button text changes to "Recording...", a visual indicator like a microphone icon appears or animates, status message updates to "Recording...").
    *   The record button might be disabled or change its action to "Stop Recording" (though for a fixed duration, it's often disabled).
    *   The app records audio for a predefined duration (e.g., 2 seconds).

4.  **Processing:**
    *   Once recording is complete, the UI indicates that the audio is being processed (e.g., status message changes to "Processing Signature...", a loading indicator/spinner appears).
    *   The record button remains disabled or hidden.

5.  **Signature Saved (Success):**
    *   If processing and saving are successful, the UI confirms this (e.g., status message changes to "Signature Saved!").
    *   The record button might change to "Record Another" or revert to its initial state, ready for a new recording.
    *   The loading indicator is hidden.

6.  **Error State:**
    *   If any step fails (e.g., microphone permission denied, recording error, processing error, saving error), the UI displays an appropriate error message (e.g., "Error: Microphone permission denied", "Error: Could not save signature").
    *   The record button might change to "Try Again" or revert to its initial state.
    *   The loading indicator (if active) is hidden.

## Screen States and ViewModel Properties

These states are managed by `MainViewModel.swift` and reflected in `ContentView.swift`.

### 1. Idle State

*   **Description:** The default state when the screen loads or after a successful/failed operation has been acknowledged and reset.
*   **`MainViewModel` Properties:**
    *   `statusMessage: String` = "Press Record to Start" (or similar)
    *   `recordButtonTitle: String` = "Record Voice Signature"
    *   `isRecordingActive: Bool` = `false`
    *   `isLoading: Bool` = `false`
    *   `isButtonEnabled: Bool` = `true`
*   **Key UI Elements:**
    *   Status label shows the `statusMessage`.
    *   Record button is enabled with `recordButtonTitle`.
    *   No recording indicator.
    *   No loading indicator.
*   **Transitions:**
    *   On record button tap: Moves to **Recording State**.

### 2. Recording State

*   **Description:** Actively recording audio.
*   **`MainViewModel` Properties:**
    *   `statusMessage: String` = "Recording (2s)..." (could include a live timer if implemented)
    *   `recordButtonTitle: String` = "Recording..." (or an icon might be shown, button itself might be styled differently)
    *   `isRecordingActive: Bool` = `true`
    *   `isLoading: Bool` = `false`
    *   `isButtonEnabled: Bool` = `false` (typically, for fixed duration recording)
*   **Key UI Elements:**
    *   Status label shows "Recording...".
    *   Record button text/appearance changes; button is disabled.
    *   Visual recording indicator is active.
    *   No loading indicator.
*   **Transitions:**
    *   On recording completion (timer finishes): Moves to **Processing State**.
    *   On recording error: Moves to **Error State**.

### 3. Processing State

*   **Description:** Audio has been recorded and is being processed (e.g., Mel Cepstrum calculation).
*   **`MainViewModel` Properties:**
    *   `statusMessage: String` = "Processing Signature..."
    *   `recordButtonTitle: String` = "Processing..." (or button might be hidden/still disabled)
    *   `isRecordingActive: Bool` = `false`
    *   `isLoading: Bool` = `true`
    *   `isButtonEnabled: Bool` = `false`
*   **Key UI Elements:**
    *   Status label shows "Processing...".
    *   Loading indicator (e.g., `ProgressView` in SwiftUI) is visible.
    *   Record button is disabled/hidden.
*   **Transitions:**
    *   On successful processing and saving: Moves to **Success State**.
    *   On processing or saving error: Moves to **Error State**.

### 4. Success State

*   **Description:** Voice signature has been successfully processed and saved.
*   **`MainViewModel` Properties:**
    *   `statusMessage: String` = "Signature Saved!"
    *   `recordButtonTitle: String` = "Record Another"
    *   `isRecordingActive: Bool` = `false`
    *   `isLoading: Bool` = `false`
    *   `isButtonEnabled: Bool` = `true`
*   **Key UI Elements:**
    *   Status label shows "Signature Saved!".
    *   Record button is enabled with "Record Another".
    *   Loading indicator is hidden.
*   **Transitions:**
    *   On record button tap: Moves to **Recording State** (for a new signature).
    *   After a timeout or user interaction: Could revert to **Idle State**.

### 5. Error State

*   **Description:** An error occurred at some point in the flow.
*   **`MainViewModel` Properties:**
    *   `statusMessage: String` = "Error: [Specific error message]" (e.g., "Error: Microphone permission denied.")
    *   `recordButtonTitle: String` = "Try Again"
    *   `isRecordingActive: Bool` = `false`
    *   `isLoading: Bool` = `false` (any active loading should stop)
    *   `isButtonEnabled: Bool` = `true`
*   **Key UI Elements:**
    *   Status label displays the specific error message.
    *   Record button is enabled with "Try Again".
    *   Loading indicator (if previously active) is hidden.
*   **Transitions:**
    *   On record button tap ("Try Again"): Typically attempts to restart the process, often moving to **Idle State** or directly to **Recording State** if the error was transient or depends on a retry (e.g., permission request).

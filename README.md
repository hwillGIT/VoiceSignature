# Voice Match / YTIM

Voice Match is the technical identity layer for a permissioned voice-signature and event relationship intelligence product.

The broader commercial concept is currently called **YTIM**: an AI-powered event relationship assistant for high-value events where remembering people, making the right introductions, and proving sponsor ROI matter.

## Current Position

This repository began as an iOS voice signature skeleton. It is now being organized as the working base for productizing the idea.

Current strategic direction:

- **Voice Match** = iOS voice signature, local enrollment, local matching, and identity-confidence layer.
- **YTIM** = commercial event networking / relationship intelligence product concept.
- **GitHub** = active source of truth.
- **GitLab** = mirror of the repository.
- **Default branch** = `initial-project-skeleton`.

## Product Thesis

The strongest wedge is not a generic name-memory app.

The sharper wedge is:

> A permissioned event relationship assistant that helps high-value attendees remember who they meet, helps organizers understand engagement, and helps sponsors prove relationship ROI.

The product should start with a trustworthy, local-first voice signature proof of life, then expand into event profiles, consented identity matching, relationship memory, and organizer/sponsor reporting.

## Current Technical Baseline

This repository contains the skeleton structure for an iOS application designed to record, process, and store voice signatures. Users can record their voice, which is then conceptually processed to extract features such as Mel Frequency Cepstral Coefficients (MFCCs), and those features are stored locally on the device using Core Data. The UI is built with SwiftUI.

This project currently serves as a foundational blueprint, outlining the architecture, basic UI flow, and placeholder implementations for core service modules.

## Features — Current Skeleton

- **Audio Recording:** Captures audio from the microphone for a fixed duration.
- **MFCC Calculation Placeholder:** Includes a placeholder service for Mel Cepstrum / MFCC calculation. The actual signal processing logic is not yet implemented.
- **Local Storage:** Saves voice signature data such as ID, timestamp, placeholder MFCC data, and original audio file path to a local Core Data store.
- **User Interface:** Basic SwiftUI view allowing users to initiate recording and view status messages.
- **MVVM Architecture:** Organized using the Model-View-ViewModel pattern with distinct service layers for audio, processing, and database operations.

## Highest Priority Gap

The core missing implementation is the real voice feature extraction and matching pipeline.

The first technical milestone is complete when:

- A user can record two samples.
- The app extracts features from each sample.
- The app compares them locally.
- The app shows a similarity score and confidence category.
- The app stores enrollment locally.
- Tests cover success, empty audio, short audio, and serialization failure.

## Architecture

The application follows the **MVVM (Model-View-ViewModel)** design pattern:

- **Model:** `VoiceSignatureModel.swift`; Core Data entities are used for persistence.
- **View:** `ContentView.swift`; SwiftUI view for user interaction.
- **ViewModel:** `MainViewModel.swift`; manages UI state, orchestrates calls to services, and handles business logic.
- **Services:**
  - `AudioService.swift`: Handles audio recording using AVFoundation.
  - `CepstrumService.swift`: Placeholder for MFCC calculation, intended for Accelerate or another DSP approach.
  - `DatabaseService.swift`: Manages data persistence using Core Data.

## Technologies

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Concurrency:** Combine for `@Published` ViewModel properties
- **Audio:** AVFoundation
- **Database:** Core Data
- **DSP / Signal Processing:** Intended for Accelerate or another local processing approach

## Documentation Map

| Document | Purpose |
|---|---|
| `AGENTS.md` | Agent team, repo rules, privacy rules, issue/PR format |
| `docs/index.md` | Documentation index and execution stack |
| `docs/productization-roadmap.md` | Broad roadmap from concept to productization |
| `docs/voice-match-roadmap.md` | Condensed roadmap and 90-day plan |
| `docs/product-requirements.md` | MVP requirements, user stories, data model, privacy requirements |
| `docs/technical-roadmap.md` | Engineering workstreams, risks, milestones |
| `docs/customer-discovery-and-pilot-plan.md` | Discovery interviews, pilot design, validation gates |
| `docs/architecture.md` | Existing MVVM/iOS architecture details |
| `docs/ui_flow.md` | Existing UI flow notes |
| `docs/project_setup.md` | Existing project setup notes |

## Getting Started / Developer Setup

### Prerequisites

- Xcode, latest stable version recommended
- macOS machine
- Basic knowledge of Swift and SwiftUI

### Cloning the Repository

```bash
git clone <repository_url>
cd <repository_directory>
```

### Critical Step: Create Core Data Model

This project uses Core Data for local storage. The Swift code for `CoreDataService.swift` expects a Core Data Model file to be present in your Xcode project. You must create this manually unless a generated model is added later.

1. Open the `.xcodeproj` or `.xcworkspace` file in Xcode.
2. In the Project Navigator, right-click on the main app group or a suitable subgroup.
3. Select **New File...**.
4. Under the iOS tab, scroll to Core Data and select **Data Model**.
5. Name it **`VoiceSignatureAppModel.xcdatamodeld`** and add it to the main application target.
6. Add an entity named **`VoiceSignatureEntity`**.
7. Add these attributes:
   - `id` — UUID
   - `timestamp` — Date
   - `mfccData` — Binary Data
   - `originalFilePath` — String, optional

### Info.plist — Microphone Permission

For audio recording to work, add this key to `Info.plist`:

- `Privacy - Microphone Usage Description`

Example value:

```text
This app requires microphone access to record your voice signature for authentication and profile creation.
```

This language should be revised before pilot use so it accurately reflects the consent model and event-specific use case.

## Project Structure

- `app/`: Main source code for the iOS application.
  - `src/audio/`: Audio recording service.
  - `src/database/`: Core Data service.
  - `src/models/`: Data model structures.
  - `src/processing/`: Feature extraction service; currently placeholder.
  - `src/viewmodels/`: ViewModels connecting View and Model/Services.
  - `src/views/`: SwiftUI views.
  - `VoiceSignatureAppApp.swift`: Main SwiftUI entry point.
- `docs/`: Product, architecture, roadmap, and setup documentation.
- `tests/`: Placeholder unit test files for services and ViewModel.

## Product Principles

1. Build the smallest trustworthy thing that proves the relationship-value wedge.
2. Voice signatures are sensitive. Treat them like identity data.
3. No hidden recognition. No hidden location tracking.
4. Consent and deletion are core product features, not paperwork.
5. Do not claim accuracy until it is measured.
6. Do not build the whole platform before the pilot proves demand.

## Immediate Roadmap

### Phase 1 — Technical Proof of Life

- Implement local feature extraction.
- Add local similarity scoring.
- Add confidence bands.
- Add evaluation tests.

### Phase 2 — Event MVP

- Add Event and Attendee models.
- Add consent and profile screens.
- Add recognition result card.
- Add manual correction flow.

### Phase 3 — Pilot Package

- Build pilot one-pager.
- Create attendee onboarding flow.
- Create post-event report template.
- Run customer discovery interviews.

### Phase 4 — Productization

- Add organizer/sponsor dashboard.
- Add aggregate analytics.
- Add CRM/export workflows.
- Add pricing and sales materials.

## Key Pending Implementation

The `CepstrumService.swift` / local cepstrum service currently contains placeholder logic. This is the highest priority implementation target.

Recommended approach:

1. Implement MFCC baseline first.
2. Add local similarity scoring.
3. Measure accuracy in controlled tests.
4. Later evaluate modern speaker embeddings.

## Working Warning

Do not build a creepy recognition tool.

Build a permissioned memory and relationship assistant.

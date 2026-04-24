# Voice Match Technical Roadmap

_Last updated: 2026-04-24_

## 1. Current State

The repository is currently an iOS SwiftUI skeleton for recording, processing, and storing voice signatures.

Current baseline:

- Swift / SwiftUI app structure.
- MVVM architecture.
- AVFoundation recording service.
- Core Data storage pattern.
- Placeholder cepstrum/MFCC service.
- Basic app flow: record → process → save.

The current repository proves the intended shape of the app, but not yet the technical heart of the product. The core missing piece is real speaker feature extraction and matching.

## 2. Architecture Direction

Use a local-first architecture for the first working prototype.

Reasoning:

- Voice signatures are sensitive.
- Local processing reduces early privacy risk.
- A local demo is easier to validate before backend complexity.
- The event platform can be designed as sync-ready without requiring cloud sync on day one.

Initial architecture:

```text
SwiftUI View
   ↓
MainViewModel
   ↓
AudioService → local audio file
   ↓
FeatureExtractionService → feature vector / embedding
   ↓
VoiceMatchService → similarity score + threshold decision
   ↓
LocalDatabaseService → event profile, signature, interaction memory
```

Later architecture:

```text
Mobile App
   ↓
Local privacy-preserving recognition layer
   ↓
Secure sync API
   ↓
Event identity graph
   ↓
Organizer / sponsor dashboard
   ↓
Analytics and CRM exports
```

## 3. Core Technical Workstreams

### Workstream A: Audio Capture Reliability

Goal: Make recording reliable enough for repeated testing.

Tasks:

- Confirm microphone permission flow.
- Handle denied permissions.
- Handle interruptions.
- Normalize recording duration.
- Store test recordings only when explicitly enabled.
- Add audio quality checks: too short, too quiet, clipped, or empty.

Acceptance criteria:

- App records consistently on simulator/device where supported.
- Bad audio states produce clear user messages.
- Test harness can run repeatable audio workflows.

### Workstream B: Feature Extraction

Goal: Replace placeholder cepstrum logic.

Candidate approaches:

1. **MFCC baseline**
   - Pros: understandable, lightweight, educational, easier to implement locally.
   - Cons: may be weaker for robust speaker recognition.

2. **Speaker embedding model**
   - Pros: better identity signal if selected well.
   - Cons: more integration complexity, model size, privacy and licensing questions.

3. **Hybrid approach**
   - Start with MFCC baseline to prove pipeline.
   - Add embedding model once storage, consent, evaluation, and threshold logic exist.

Recommended path:

- Build MFCC baseline first.
- Create feature vector serialization.
- Add similarity scoring.
- Document limitations.
- Then spike a modern speaker embedding approach.

Acceptance criteria:

- A recorded sample produces deterministic feature output.
- Features can be saved and loaded.
- Two recordings can be compared with a similarity score.
- Short/noisy/empty recordings fail gracefully.

### Workstream C: Matching and Thresholds

Goal: Convert feature vectors into practical matching decisions.

Tasks:

- Define similarity metric.
- Define threshold configuration.
- Track false accept and false reject outcomes.
- Add confidence bands: high, medium, low, unknown.
- Require manual correction for low-confidence matches.

Acceptance criteria:

- Match result never presents false certainty.
- User sees uncertainty clearly.
- Match correction can be stored.

### Workstream D: Event Data Layer

Goal: Make the app event-aware.

Tasks:

- Add Event model.
- Add Attendee model.
- Add event-scoped VoiceSignature model.
- Add Interaction model.
- Add Sponsor/Booth model later.
- Support CSV import path.

Acceptance criteria:

- App can represent at least one event with attendees.
- Voice signatures are tied to event-scoped consent.
- Interactions can be recorded manually or by match result.

### Workstream E: Consent and Deletion

Goal: Make trust structural.

Tasks:

- Add consent screen.
- Add event-specific permission model.
- Add delete voice signature flow.
- Add delete event profile flow.
- Add raw-audio retention toggle for testing only.
- Add privacy copy and versioning.

Acceptance criteria:

- No enrollment without opt-in.
- User can delete signature.
- User can understand what is collected.
- Pilot use cannot proceed without consent record.

### Workstream F: Pilot Reporting

Goal: Convert interactions into event business value.

Tasks:

- Generate aggregate engagement counts.
- Generate attendee follow-up list.
- Generate sponsor booth summary.
- Create post-event markdown/PDF report later.

Acceptance criteria:

- Pilot event can produce a simple report without exposing sensitive individual data by default.

## 4. 30-Day Technical Plan

### Week 1: Stabilize Baseline

- Confirm project builds in Xcode.
- Add missing Core Data model instructions or generated model assets.
- Create test plan.
- Add AGENTS.md and product requirements docs.
- Create issue backlog.

### Week 2: Voice Feature Spike

- Implement MFCC baseline or selected feature extraction library.
- Serialize features to Data.
- Add unit tests for output shape and failure cases.
- Add developer diagnostic screen or logs.

### Week 3: Matching Prototype

- Implement similarity scoring.
- Add enroll-and-compare demo.
- Add mock enrolled profiles.
- Add confidence thresholds.
- Add manual correction event.

### Week 4: Event MVP Skeleton

- Add Event and Attendee models.
- Add event profile screens.
- Add consent screen.
- Add recognition result card.
- Write pilot demo script.

## 5. 90-Day Technical Plan

### Days 1–30: Local Proof of Life

Outcome: App can enroll and compare voice samples locally.

### Days 31–60: Event MVP

Outcome: App can import attendees, collect consent, and show recognition/memory cards.

### Days 61–90: Pilot-Ready Build

Outcome: App can support a small controlled event pilot and generate a simple post-event report.

## 6. Engineering Rules

- Never use real attendee or voice data in committed fixtures.
- Use synthetic test data unless a consented private test dataset is separately managed outside the repo.
- Every voice-processing change must include evaluation notes.
- Every identity/location/profile change must include a privacy note.
- Prefer measurable claims over impressive-sounding claims.

## 7. Major Technical Risks

| Risk | Why it matters | Mitigation |
|---|---|---|
| Voice matching accuracy is weak | Product wedge depends on trust | Start with controlled demos, measure, avoid overclaiming |
| False positive match | Could embarrass users or damage trust | Confidence bands, manual correction, opt-in only |
| Privacy concern | Could block pilots | Consent-first design, local processing, deletion flows |
| Event data complexity | Could slow MVP | Start with simple CSV event model |
| Backend overbuild | Could waste time | Local-first, sync-ready, not cloud-first |
| Location tracking creepiness | Could hurt adoption | Make Trails explicitly opt-in and aggregate by default |

## 8. Definition of Done for First Technical Milestone

The first milestone is complete when:

- A user can record two samples.
- The app extracts features from each sample.
- The app compares them.
- The app shows a score and confidence category.
- The app stores enrollment locally.
- The README explains how to run the demo.
- Tests cover at least success, empty audio, short audio, and serialization failure.

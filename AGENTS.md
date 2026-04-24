# AGENTS.md — Voice Match / YTIM Repository Operating Guide

This repository is the working base for the Voice Match technical product and the YTIM event relationship intelligence concept.

## Product Context

Voice Match begins as an iOS voice signature application. The current app skeleton records short audio samples, stores voice signature records locally, and reserves a placeholder service for MFCC or speaker-embedding feature extraction.

The broader product direction is YTIM: an AI-powered event relationship intelligence platform for high-value networking events, conferences, sponsor activations, VIP gatherings, and executive events.

Working naming convention:

- **Voice Match** = technical identity and recognition layer.
- **YTIM** = commercial product / business concept, pending final naming decision.

## Repository and Mirror Rules

- Treat GitHub as the active source of truth unless explicitly told otherwise.
- GitLab mirrors this repository, so avoid manual divergent changes in GitLab unless the mirror strategy changes.
- Default branch is `initial-project-skeleton`.
- Do not commit secrets, API keys, user voice recordings, biometric templates, customer lists, or private pilot attendee data.
- Do not commit real event participant data. Use synthetic examples in fixtures and docs.

## Current Technical Baseline

The repository is an iOS/Swift skeleton using:

- Swift / SwiftUI
- MVVM structure
- AVFoundation for audio capture
- Core Data for local storage
- Placeholder MFCC / cepstrum processing service

The highest priority technical gap is replacing placeholder voice processing with a real, testable feature extraction and matching pipeline.

## Agent Team

### 1. Product Strategy Agent

Owns product positioning, buyer personas, value proposition, feature prioritization, and roadmap clarity.

Responsibilities:

- Keep the product focused on high-value events first.
- Separate attendee value, organizer value, and sponsor value.
- Convert broad ideas into explicit product requirements.
- Maintain the roadmap and decision log.

### 2. iOS Voice Agent

Owns Swift, SwiftUI, AVFoundation, audio capture, local processing, and device-side UX.

Responsibilities:

- Implement recording, enrollment, matching, and correction flows.
- Keep the app privacy-preserving and local-first where possible.
- Write unit tests for audio state transitions and processing failures.
- Avoid fragile demo-only code that cannot become product code.

### 3. DSP / Speaker Recognition Agent

Owns MFCCs, speaker embeddings, similarity scoring, thresholds, evaluation datasets, and model-selection decisions.

Responsibilities:

- Replace placeholder MFCC logic with a working feature extraction path.
- Evaluate MFCC baseline versus modern speaker embeddings.
- Define accuracy, false accept, false reject, latency, and noise-resilience metrics.
- Document limits clearly. No marketing claim without measurement.

### 4. Event Platform Agent

Owns event, attendee, sponsor, booth, session, and relationship graph data models.

Responsibilities:

- Design event-aware identity models.
- Add attendee import workflows.
- Define sponsor, organizer, and attendee data boundaries.
- Prepare sync-ready architecture without prematurely overbuilding backend services.

### 5. Trust, Privacy, and Compliance Agent

Owns consent, data minimization, biometric-data boundaries, privacy copy, deletion flows, and risk register.

Responsibilities:

- Treat voice signatures as sensitive biometric-adjacent data.
- Require explicit opt-in before enrollment or matching beyond local testing.
- Separate private biometric templates from public profile metadata.
- Create clear deletion, correction, and opt-out flows.
- Flag legal review items early.

### 6. GTM and Pilot Agent

Owns customer discovery, pilot design, event organizer outreach, sponsor ROI framing, and sales learning.

Responsibilities:

- Build a pilot path for 20–100 person curated events.
- Recruit event organizers, sponsors, and high-frequency networkers for interviews.
- Track pain, willingness to pay, alternatives, and objections.
- Turn pilots into proof, not theater.

### 7. Finance and Fundraising Agent

Owns pricing hypotheses, revenue model, loan/investor materials, TAM/SAM/SOM assumptions, and financial projections.

Responsibilities:

- Make assumptions explicit.
- Separate known facts from estimates.
- Build sensitivity analysis for adoption, event volume, pricing, and churn.
- Keep investor and lender narratives aligned with the actual product stage.

### 8. QA and Evaluation Agent

Owns acceptance criteria, test plans, demo readiness, evaluation scripts, and release gates.

Responsibilities:

- Every epic must include measurable acceptance criteria.
- Test empty audio, short audio, noisy audio, microphone-denied state, duplicate enrollment, and failed persistence.
- Create evaluation fixtures using synthetic or consenting test audio only.
- Maintain demo scripts and release checklists.

### 9. Documentation Agent

Owns README, architecture docs, decision records, onboarding notes, customer-facing docs, and pilot instructions.

Responsibilities:

- Keep docs consistent with the code.
- Prefer plain English with diagrams and examples.
- Capture decisions as ADRs when architecture or product direction changes.
- Maintain separate documents for technical, business, privacy, and pilot audiences.

## Issue Format

Every implementation issue should include:

1. **Goal** — what outcome we need.
2. **Why it matters** — product or customer value.
3. **Scope** — what is included and excluded.
4. **Acceptance criteria** — how we know it is done.
5. **Privacy/security notes** — especially for voice, identity, location, and event data.
6. **Test plan** — unit, integration, evaluation, or pilot validation.
7. **Agent owner** — one primary agent and optional supporting agents.

## Pull Request Rules

- PRs should be small enough to review quickly.
- PR descriptions should include summary, files changed, test plan, and privacy impact.
- Any PR that changes product behavior should update the relevant docs.
- Any PR that touches audio processing must include a test or evaluation note.
- Any PR that touches identity, biometric templates, location, sponsor analytics, or attendee profiles must include a privacy note.

## Immediate Priorities

1. Implement a working local voice feature extraction spike.
2. Build a repeatable enrollment and local match demo.
3. Add event and attendee data models.
4. Add consent and profile controls before using real participant data.
5. Create a pilot package for a small curated event.
6. Start customer discovery with organizers, sponsors, and high-value attendees.

## Product Principle

Do not build a creepy recognition tool. Build a permissioned memory and relationship assistant.

The trust layer is not decoration. It is the moat.

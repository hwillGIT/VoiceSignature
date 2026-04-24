# Voice Match / YTIM Product Requirements

_Last updated: 2026-04-24_

## 1. Product Thesis

Voice Match / YTIM is a permissioned event relationship assistant.

It helps people recognize, remember, and follow up with the right people at high-value events. It also helps organizers and sponsors understand whether the event is creating meaningful engagement.

The first product should not try to be a general social network. It should be a sharp wedge for places where time is scarce, people are valuable, and forgetting a name can cost an opportunity.

## 2. Product Naming

Current working model:

- **Voice Match**: technical identity layer and repository name.
- **YTIM**: commercial/event-intelligence product concept.

Open decision:

- Decide whether to keep both names, merge them, or reserve one for internal use.

## 3. Primary Buyer Personas

### Event Organizer

The organizer wants better attendee engagement, better sponsor value, and better post-event reporting.

Pain points:

- Cannot easily tell who actually connected with whom.
- Cannot prove sponsor ROI beyond attendance and badge scans.
- Cannot identify underserved VIPs or important attendees during the event.
- Has limited real-time visibility into event energy.

### Sponsor / Exhibitor

The sponsor wants better qualified leads, better follow-up, and proof that sponsorship dollars created real conversations.

Pain points:

- Badge scans do not prove relationship value.
- Business-card collection is messy and low-signal.
- Follow-up lists are noisy.
- Sponsor teams struggle to identify the right people in real time.

### High-Value Attendee

The attendee wants to use limited event time wisely.

Pain points:

- Meets many people quickly and forgets names/details.
- Does not know who nearby is most relevant.
- Wants smoother follow-up after an event.
- Wants help without feeling surveilled or exposed.

## 4. MVP Scope

The MVP should prove four things:

1. A user can enroll a voice signature locally.
2. A user can recognize or match a consenting person in a controlled environment.
3. The app can connect recognition to an event attendee profile.
4. A pilot event can produce useful post-event relationship insights without violating trust.

## 5. Core MVP User Stories

### Attendee Stories

- As an attendee, I can create a profile for one event.
- As an attendee, I can explicitly opt in to voice-based recognition for that event.
- As an attendee, I can record a short enrollment phrase.
- As an attendee, I can see whether my enrollment succeeded.
- As an attendee, I can recognize another opted-in attendee in a controlled demo flow.
- As an attendee, I can manually correct a match.
- As an attendee, I can see where/when I met someone and add a private note.
- As an attendee, I can delete my voice signature and event profile data.

### Organizer Stories

- As an organizer, I can create an event.
- As an organizer, I can import an attendee list.
- As an organizer, I can mark attendees by role, sponsor tier, VIP status, or category.
- As an organizer, I can see aggregate engagement metrics for the pilot.
- As an organizer, I can export a post-event summary.

### Sponsor Stories

- As a sponsor, I can see aggregate traffic and engagement with my booth or activation.
- As a sponsor, I can receive permissioned follow-up leads.
- As a sponsor, I can compare sponsor engagement to goals.

## 6. Non-Goals for MVP

Do not build these first:

- General-purpose social network.
- Secret background identification.
- Large-scale facial recognition.
- Continuous location tracking without explicit opt-in.
- Production biometric authentication for security-sensitive use cases.
- Full CRM integration before pilot evidence exists.
- Complex gamification before core trust and recognition work.

## 7. Product Modules

### Module A: Voice Signature Core

Capabilities:

- Capture audio.
- Extract features.
- Store local signature template.
- Compare two samples.
- Return similarity score and threshold decision.
- Handle failure states.

Acceptance metrics:

- Enrollment completes within a tolerable user flow.
- Short/noisy/empty audio fails gracefully.
- Similarity score is stable enough for a controlled demo.
- False match risk is clearly measured before any pilot.

### Module B: Consent and Trust

Capabilities:

- Clear opt-in before voice enrollment.
- Event-scoped permissions.
- Profile visibility settings.
- Delete data flow.
- Manual correction flow.

Acceptance metrics:

- User can understand what is collected and why.
- User can opt out without losing basic event access.
- User can delete data.
- No real pilot uses hidden biometric or location collection.

### Module C: Event Identity Graph

Capabilities:

- Event model.
- Attendee model.
- Sponsor model.
- Booth/session model.
- Relationship memory model.

Acceptance metrics:

- Attendee import works from CSV.
- Profiles can be linked to event roles.
- Relationships can be created, corrected, and exported.

### Module D: Event Companion UI

Capabilities:

- Recognition result card.
- Memory recall card.
- Conversation notes.
- Relevant-person suggestion list.
- Post-event follow-up list.

Acceptance metrics:

- User sees a match result clearly.
- User sees confidence/uncertainty rather than false certainty.
- User can correct errors.
- User can follow up after event.

### Module E: Organizer / Sponsor Reporting

Capabilities:

- Aggregate engagement dashboard.
- Sponsor traffic summary.
- VIP engagement summary.
- Post-event report.

Acceptance metrics:

- No individual-sensitive data exposed without consent.
- Sponsor report uses aggregate metrics by default.
- Pilot report can support a sales conversation.

## 8. Data Model Draft

### Event

- id
- name
- date range
- venue
- organizer
- visibility rules
- consent policy version

### Attendee

- id
- event id
- name
- company
- title
- role/category
- public profile fields
- consent status
- deletion status

### Voice Signature

- id
- attendee id
- event id
- template data
- algorithm version
- enrollment timestamp
- local/private storage flag
- deletion timestamp

### Interaction

- id
- event id
- attendee A
- attendee B
- timestamp
- source: manual, voice match, QR, check-in, or other
- confidence score if machine-generated
- correction status

### Sponsor Activation

- id
- event id
- sponsor id
- location or booth id
- engagement metric type
- aggregate counts

## 9. Privacy and Safety Requirements

- Voice signatures must be treated as sensitive identity data.
- Consent must be explicit and event-scoped.
- Voice recognition must not run secretly in the background.
- Users must be able to opt out, correct, and delete data.
- Raw audio should not be retained longer than needed unless explicitly required for a consented test dataset.
- Analytics should default to aggregate reporting.
- Any claim of recognition accuracy requires measured evidence.

## 10. Roadmap Summary

### Phase 1: Technical Proof of Life

Build working voice enrollment and local matching.

### Phase 2: Event MVP

Add event profile, attendee import, consent, and recognition result flow.

### Phase 3: Pilot Package

Run a small curated pilot and produce organizer/sponsor reporting.

### Phase 4: Platform Expansion

Add dashboard, sponsor modules, Trails/geopresence, exports, and integrations.

## 11. Open Decisions

1. Product name: Voice Match, YTIM, or two-layer naming.
2. Voice approach: MFCC baseline, speaker embedding, or hybrid.
3. Storage policy: local-only for MVP versus sync-enabled backend.
4. Pilot focus: business conference, private donor event, association gathering, or sponsored networking event.
5. Pricing: per-event, organizer subscription, sponsor data package, or hybrid.

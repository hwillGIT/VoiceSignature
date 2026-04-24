# Voice Match Product Roadmap

_Last updated: 2026-04-24_

## Current Direction

Voice Match is an iOS-first event relationship assistant. The product starts with local voice signature capture and grows into an opt-in event networking platform for conferences, executive events, sponsor activations, and high-value gatherings.

The strongest wedge is not simple name recall. The stronger wedge is helping busy attendees recognize people, use their time well, and turn event conversations into measurable relationship value.

## Target Buyers

- Event organizers
- Conference owners
- Sponsor and exhibitor teams
- Enterprise event marketing teams
- VIP event operators

## Target Users

- Executives
- Sales and business development leaders
- Sponsors and exhibitors
- High-value attendees who meet many people quickly
- Event hosts and VIP relationship managers

## Product Pillars

### 1. Voice Signature Core

Build a reliable local capture, feature extraction, storage, and matching flow.

Key work:
- Implement real audio feature extraction.
- Replace placeholder MFCC logic.
- Add enrollment and local match flows.
- Add repeatable test data and quality checks.

### 2. Consent and Trusted Profiles

Make trust a product feature.

Key work:
- Add clear opt-in screens.
- Define event-level sharing rules.
- Separate private identity data from shared business profile data.
- Give users controls over what is visible.

### 3. Event Identity Graph

Connect attendees, companies, roles, sponsor tiers, and event-specific tags.

Key work:
- Add event and attendee models.
- Support attendee import from CSV or API.
- Add profile fields for name, title, company, role, and event permissions.
- Support common-name disambiguation.

### 4. Event Companion Experience

Turn recognition into useful action.

Key work:
- Show a recognition result card.
- Show where and when a person was met.
- Add conversation starter suggestions.
- Add priority reminders near the end of an event.

### 5. Trails and Gamification

Create opt-in engagement loops for attendees, organizers, and sponsors.

Key work:
- Add check-ins and booth visits.
- Add points, badges, leaderboards, and sponsor rewards.
- Add private event history for the user.

### 6. Organizer and Sponsor Dashboard

Convert activity into business value.

Key work:
- Build live engagement dashboard.
- Track sponsor traffic and follow-up opportunities.
- Build post-event reports.
- Add CRM export path.

## 90-Day Roadmap

### Days 1-15: Foundation

- Align repo naming and product naming.
- Implement voice feature extraction spike.
- Add product requirements document.
- Create customer discovery script.
- Create pilot event hypothesis.

### Days 16-30: Technical Proof of Life

- Record, process, save, and compare voice signatures locally.
- Add automated tests for audio and processing services.
- Add basic enrollment flow.
- Add local match demo.

### Days 31-60: Event MVP

- Add event and attendee models.
- Add profile import.
- Add consent and sharing settings.
- Add recognition result UI.
- Add manual correction flow.

### Days 61-90: Pilot Package

- Build small-event pilot workflow.
- Build sponsor reporting template.
- Build organizer dashboard prototype.
- Conduct customer discovery interviews.
- Prepare investor memo, pitch deck, and financial model assumptions.

## Agent Operating Model

- Product Strategy Agent: owns positioning, buyer personas, pricing, and roadmap decisions.
- Technical Architect Agent: owns architecture, data model, repo structure, and integration decisions.
- iOS Voice Agent: owns SwiftUI, AVFoundation, local storage, and audio feature extraction.
- Trust and Privacy Agent: owns consent, permissions, data boundaries, and policy language.
- GTM Agent: owns customer discovery, pilot pipeline, outreach, and sponsor value story.
- Investor Materials Agent: owns business plan, pitch deck, financial model, and investor narrative.
- QA Agent: owns test plans, acceptance criteria, and release readiness.

## Immediate Backlog

1. Implement MFCC or speaker-embedding spike.
2. Add event and attendee models.
3. Add opt-in profile and consent screens.
4. Create recognition result card.
5. Add attendee import prototype.
6. Define pilot event workflow.
7. Create organizer and sponsor dashboard wireframe.
8. Create customer discovery script.
9. Create investor memo outline.
10. Create pricing hypothesis.

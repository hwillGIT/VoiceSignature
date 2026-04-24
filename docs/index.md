# Voice Match / YTIM Documentation Index

_Last updated: 2026-04-24_

## Repository Role

This repository is now organized as the working base for both:

1. **Voice Match** — the iOS technical identity / voice signature layer.
2. **YTIM** — the broader event relationship intelligence product concept.

GitHub is the active source of truth. GitLab mirrors the repository.

## Core Product Documents

| Document | Purpose |
|---|---|
| `docs/productization-roadmap.md` | Broad productization roadmap from idea to pilots and sales |
| `docs/voice-match-roadmap.md` | Condensed product roadmap and 90-day plan |
| `docs/product-requirements.md` | Product requirements, user stories, MVP scope, privacy requirements |
| `docs/technical-roadmap.md` | Engineering roadmap, workstreams, architecture direction, risks |
| `docs/customer-discovery-and-pilot-plan.md` | Interview plan, pilot design, metrics, and validation gates |
| `docs/architecture.md` | Existing MVVM / iOS application architecture |
| `docs/ui_flow.md` | Existing app UI flow documentation |
| `docs/project_setup.md` | Existing project setup notes |

## Agent Operating Document

| Document | Purpose |
|---|---|
| `AGENTS.md` | Defines the agent team, responsibilities, repo rules, PR rules, and immediate priorities |

## Current Product Direction

The strongest direction is no longer a generic name-memory app. The sharper wedge is:

> A permissioned event relationship assistant for high-value events where time, memory, introductions, and sponsor ROI matter.

This means the project should be built in this order:

1. Local voice signature proof of life.
2. Consent and trust layer.
3. Event attendee/profile layer.
4. Recognition/memory user experience.
5. Pilot package.
6. Organizer/sponsor reporting.
7. Platform expansion.

## Current Technical Gap

The main technical gap is still the placeholder voice feature extraction service. The current app skeleton has the right shape, but the product cannot be proved until the placeholder MFCC / cepstrum implementation is replaced with a real, measurable feature extraction and matching pipeline.

## Current Business Gap

The main business gap is customer evidence. The next 25–30 discovery conversations should validate whether event organizers, sponsors, and high-value attendees care enough to pilot or pay.

## Immediate Execution Stack

### Product

- Finalize MVP scope.
- Decide naming architecture: Voice Match vs YTIM.
- Create pilot one-pager.

### Engineering

- Implement local feature extraction spike.
- Add similarity scoring.
- Add event and attendee models.
- Add consent and deletion flows.

### GTM

- Build target interview list.
- Run organizer/sponsor/attendee interviews.
- Select first pilot event category.

### Governance

- Define voice-data retention policy.
- Define pilot consent language.
- Define privacy risk register.

## Working Principle

Build the smallest trustworthy thing that proves the relationship-value wedge.

Do not overbuild the platform before proving the pilot.

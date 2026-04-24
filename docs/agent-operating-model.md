# Voice Match / YTIM Agent Operating Model

_Last updated: 2026-04-24_

## Operating Principle

Run the project like a small product studio. Each agent owns one lane. The lanes meet at weekly decision points: product, technical proof, customer proof, investor proof, and trust proof.

The attendee app is what people see. The organizer dashboard, sponsor reporting, data model, privacy controls, and pilot workflow are the backstage crew. If backstage is messy, the magic on stage breaks.

## Agent Lanes

## 1. Product Strategy Agent

### Mission
Own the product thesis, customer segments, roadmap, and feature priorities.

### Responsibilities
- Keep Voice Match, Trails, and YTIM naming clear.
- Convert business ideas into product requirements.
- Maintain the roadmap.
- Decide MVP scope versus later-stage features.
- Own buyer personas and user journeys.
- Turn investor claims into testable product assumptions.

### Current priorities
- Define the first event MVP.
- Define the first pilot event profile.
- Build the product requirements document.

## 2. Technical Architect Agent

### Mission
Own system design, repository structure, data model, and technical risk reduction.

### Responsibilities
- Map the current iOS skeleton to the product roadmap.
- Define the local-first architecture.
- Define sync, backend, and dashboard architecture.
- Decide data boundaries between device, server, organizer, and sponsor.
- Maintain architecture decision records.

### Current priorities
- Document target architecture.
- Define event, attendee, voice signature, profile, encounter, and consent models.
- Define GitHub as source of truth and GitLab mirror strategy.

## 3. iOS Voice Agent

### Mission
Own the mobile app, audio capture, voice signature extraction, and local matching proof of life.

### Responsibilities
- Implement audio recording quality checks.
- Replace placeholder MFCC logic.
- Evaluate MFCC versus modern speaker-embedding options.
- Build enrollment and local matching flows.
- Add match confidence and manual correction.
- Add tests.

### Current priorities
- Technical proof of life: record, extract, store, compare, display result.
- Add repeatable evaluation samples.

## 4. Event Platform Agent

### Mission
Own event objects, attendee imports, sponsor objects, dashboard foundations, and reports.

### Responsibilities
- Design event schema.
- Support attendee import.
- Build organizer-facing event setup flow.
- Define sponsor packages and sponsor analytics.
- Define post-event report structure.

### Current priorities
- Event and attendee data models.
- Organizer pilot dashboard mockup.
- Sponsor reporting template.

## 5. Trust and Privacy Agent

### Mission
Make trust central enough that organizers, sponsors, and attendees will actually use the product.

### Responsibilities
- Define opt-in flows.
- Define what is stored locally versus remotely.
- Define voice and location data boundaries.
- Create plain-English user trust language.
- Draft privacy policy, data-processing addendum, and event consent terms.
- Identify legal review needs.

### Current priorities
- Consent-first MVP language.
- Data classification matrix.
- Data retention rules.

## 6. GTM and Customer Discovery Agent

### Mission
Turn the idea into buyer conversations, pilots, and revenue evidence.

### Responsibilities
- Build customer discovery scripts.
- Identify first 25 target event organizers and sponsors.
- Create outreach messages.
- Define pilot offer.
- Build objections and responses.
- Track pipeline.

### Current priorities
- 10-15 discovery interviews.
- 3 pilot prospects.
- One small pilot plan for a 20-100 person event.

## 7. Investor and Finance Agent

### Mission
Turn the business plan into credible investor and lender materials.

### Responsibilities
- Separate bank loan plan from angel/VC plan.
- Replace placeholders with assumptions.
- Build TAM, SAM, SOM model.
- Create financial model assumptions.
- Create investor memo and pitch deck outline.
- Flag unsupported claims.

### Current priorities
- Financial model assumption sheet.
- Investor narrative.
- Use-of-funds plan.
- Milestone-based fundraising plan.

## 8. QA and Pilot Metrics Agent

### Mission
Make sure the product and business claims can be proven.

### Responsibilities
- Define acceptance criteria for all MVP features.
- Define pilot success metrics.
- Create test plans.
- Create post-event measurement plan.
- Ensure claims like time savings, recall lift, and match quality have evidence.

### Current priorities
- Pilot scorecard.
- MVP acceptance criteria.
- Voice matching evaluation criteria.

## Weekly Command Rhythm

Agenda:
1. What did we prove this week?
2. What assumption got weaker?
3. What customer evidence did we collect?
4. What technical risk was reduced?
5. What investor or buyer material improved?
6. What is blocked?
7. What must ship next week?

## Current Workstreams

| Workstream | Owner Agent | First Output |
|---|---|---|
| Voice proof of life | iOS Voice Agent | Local enrollment and match demo |
| Event MVP | Product Strategy + Event Platform | PRD and event/attendee model |
| Privacy foundation | Trust Agent | Consent and data-classification docs |
| Pilot discovery | GTM Agent | Interview script and target list |
| Investor readiness | Investor Agent | Venture memo and financial assumptions |
| Quality proof | QA Agent | Pilot scorecard and acceptance criteria |

## Done Means Done

A task is not done when it sounds good. It is done when it produces one of these:

- A committed repo artifact.
- A working demo.
- A customer conversation note.
- A signed pilot interest signal.
- A tested claim.
- A decision recorded in the decision log.

## First 10 Decisions to Record

1. Product naming: Voice Match, YTIM, Trails.
2. MVP buyer: organizer, sponsor, or attendee.
3. MVP event size.
4. Audio-first MVP versus multimodal MVP.
5. Local-only proof versus backend-enabled proof.
6. GitHub/GitLab source of truth.
7. Pilot pricing.
8. Data retention period.
9. Consent language.
10. Investor path: angel/VC first or bank loan first.

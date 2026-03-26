## Learning Debt Policy

### What Is Learning Debt
Every concept I encounter but don't understand is debt. Debt isn't bad —
it's how I ship fast. But it should be tracked and eventually repaid.

### How Debt Is Tracked
Honcho maintains a running understanding of my mastery per concept.
Each concept has an implicit state:

- **No exposure**: never seen it
- **First exposure**: seen in a plan or code, not explained
- **Explained**: had it explained but haven't used it independently
- **Practiced**: used it independently at least once
- **Strong**: used it multiple times, answered quiz correctly, can explain it

### Debt = concepts stuck in "first exposure" or "explained" for too long

### Nudge Escalation (Adaptive, Not Rigid)
The system should feel natural, not mechanical. These are guidelines
for how learning surfaces, not strict timers.

**Passive tracking (always on)**
- Every session, hooks log what concepts were used
- Honcho accumulates this automatically
- No user-visible nudges at this level

**Gentle awareness (when debt starts building)**
- During review/debrief phases, mention: "you've used X a few times
  now but haven't explored it — want to dig in?"
- In code comments or plan notes: brief flags for new concepts
- Frequency: occasional, feels natural

**Active nudging (when debt is significant)**
- Start sessions by suggesting: "you've got some learning debt
  around [concept] — want to spend 10 minutes on it?"
- During brainstorming, lean more heavily into explanations
- Frequency: most sessions, but skippable

**Strong nudging (when debt is heavy + long-standing)**
- Explicitly recommend a learning session before continuing to build
- During implementation, pause slightly more often: "this uses
  [concept] which you've seen 5 times but never written yourself"
- Frame it constructively: this is about making YOU a better
  decision-maker, not about slowing you down
- Frequency: every session, harder to skip

### The Developer Can Always Override
- "Skip learning for now, just build" → respected, debt noted
- "I'll learn this later" → respected, Honcho remembers
- "I don't care about this concept" → respected, concept deprioritized
- Override is NEVER blocked. Debt just stays on the books.

### Debrief Triggers
The end-of-session debrief (via Stop hook) fires after every session.
The accumulated learning report triggers when Honcho detects:
- 5+ concepts in "first exposure" state for 3+ sessions
- Any single concept stuck in "explained" for 5+ sessions
- Pattern of consecutive build-only sessions (3+ with no learning engagement)

The report is a natural language summary from Honcho, not a spreadsheet.
It should feel like a senior dev saying "hey, you might want to review
some things before they become real gaps."

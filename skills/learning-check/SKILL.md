---
name: learning-check
description: Quiz me on a concept from my learning trajectory.
  Use when I ask to be tested, at session end for a quick check,
  or when Honcho indicates high learning debt on a concept.
  Checks Honcho for my current mastery state and picks appropriately.
---

# Learning Check

## Steps

1. Query Honcho: "what concepts has the user been working with
   recently and which ones are uncertain or have learning debt?"

2. Pick ONE concept — don't overwhelm. Prioritize:
   - Concepts with highest debt (seen many times, never practiced)
   - Concepts from the most recent sessions (still fresh)
   - Concepts that are prerequisites for upcoming work (if known)

3. Choose format based on mastery state:
   - **First exposure** → Recognition:
     "Here's some code — what do you think this [concept] does?"
   - **Explained but not practiced** → Decision:
     "You're building [scenario] — would you use [A] or [B]? Why?"
   - **Seen many times, never independent** → Write it:
     "Write a [thing] from scratch that uses [concept]"
   - **Practiced but struggled** → Spot the bug:
     "This code has a subtle issue with [concept] — find it"

4. Wait for my answer. Don't give hints unless I ask.

5. Give honest feedback:
   - Correct → acknowledge, add a nuance I might not know
   - Partially correct → clarify the gap specifically
   - Wrong → explain without judgment, use context from my project

6. Log to Honcho:
   - What concept was tested
   - What format was used
   - Result: answered correctly / partially / needed help / couldn't answer
   - Update mastery state accordingly

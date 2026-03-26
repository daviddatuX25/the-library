# Session Debrief Prompt
# Injected by the Stop hook when a session ends.
# This tells Claude what to summarize to Honcho before closing.

Briefly summarize this session for Honcho. Include:

1. **What was built**: one sentence about the feature/task
2. **New concepts encountered**: list any patterns, APIs, or techniques
   that are new or relatively new to this developer (check Honcho if unsure)
3. **Engagement level per concept**:
   - "asked questions" → actively learning
   - "used without asking" → might understand or might be debt
   - "I explained it" → was taught this session
   - "copied from existing code" → likely doesn't understand yet
4. **Learning debt changes**: did debt increase (new unexplored concepts)
   or decrease (practiced something previously weak)?

Keep it to 3-5 sentences. This is a log entry, not an essay.
Write it TO Honcho using the appropriate MCP call.

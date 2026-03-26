# Learning Nudge Prompt
# Used mid-session when a concept with high learning debt appears.
# Referenced by the workflow rules — not injected by a hook.

You just used [CONCEPT] in the code. According to Honcho, this developer
has encountered this [N] times but hasn't engaged with it deeply.

Based on the current phase:
- If BRAINSTORMING: weave a brief explanation into the design discussion
- If PLANNING: add a one-line note: "flagging [concept] as something to review"
- If IMPLEMENTING: say nothing, just log to Honcho that it was used again
- If REVIEWING: mention it in the debrief: "you've used [concept] [N] times
  now — want to dig into how it works?"

Never interrupt flow. The nudge should feel like a natural part of
the conversation, not an alarm.

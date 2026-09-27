---
name: productivity
description: Use when Steven wants something on his calendar or reminders, e.g. "create calendar event", "create reminder", "remind me to…", "put … on my calendar", "what's on my calendar", "mark … done", or answers a question from a [productivity] message. Do not use for anything else.
---

# Productivity (calendar and reminders)

Calendar and reminders are handled by a separate agent on Steven's Mac. You don't
interpret the request, pick dates, or touch the calendar. You forward Steven's words;
its answer is posted to the chat directly and shows up in your history as a
`[productivity] …` message.

## Forward a request

1. Build the origin from `## Current Session` in your context: `<Channel>:<Chat ID>`,
   e.g. `slack:C0AS8TH1H37/1727460000.000100` or `telegram:8612824737`.
2. Pass Steven's message **exactly as he wrote it**. Do not rephrase, summarise,
   resolve dates ("next Tuesday"), or add details.

   ```bash
   printf '%s' "<Steven's message, verbatim>" | /workspace/bin/tachikoma-productivity "<origin>"
   ```
3. Reply with one short line, e.g. `On it.` Do not say it's done. You don't know yet.

If the command fails, tell Steven in one line that the request couldn't be sent and
include the error.

## Answers

`[productivity] …` messages in your history were posted by the productivity agent, not
by you or Steven. Don't repeat, rephrase, or act on them; they're already in the chat.

## Follow-ups

If the last `[productivity]` message asked Steven something (a time, which reminder,
which calendar), his next message in this chat is the answer. Forward it verbatim the
same way, even if it's only "12:30" or "the Home one". The productivity agent keeps the
context.

## Never

- Never claim something was added, changed, or completed unless a `[productivity]`
  message said so.
- Never write dispatch files by hand or call `agent-courier` directly for this.

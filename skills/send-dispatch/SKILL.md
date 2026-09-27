---
name: send-dispatch
description: Send a dispatch to the user or another agent via agent-courier. Use for notifications, task completions, questions, and routing work to other agents.
---

# Sending Dispatches

Use `agent-courier create` to write dispatch files. The host's agent-courier daemon watches `/dispatches/` and routes them based on `delivery_type`.

## Paths

| Location | What it is |
|----------|------------|
| `/dispatches/` | Shared volume — host agent-courier watches this for `tmux` delivery |
| `/dispatches/tachikoma/` | This agent's inbound folder — container's agent-courier watches for `notify` |

## Send a notification to the user (tmux)

```bash
agent-courier create \
  --to steven \
  --delivery-type tmux \
  --delivery-id "${AGENT_COURIER_NOTIFY_PANE:-claude-work}" \
  --type notification \
  --subject "Task complete" \
  --body "The deployment finished successfully." \
  --dispatch-dir /dispatches
```

## Send a task to picoclaw (AI agent)

```bash
agent-courier create \
  --to picoclaw \
  --delivery-type picoclaw \
  --delivery-id picoclaw-gateway \
  --type task \
  --subject "Run a web search" \
  --body "Search for the latest Go 1.24 release notes and summarize." \
  --reply-via tmux \
  --reply-delivery-id "${AGENT_COURIER_NOTIFY_PANE:-claude-work}" \
  --dispatch-dir /dispatches
```

## Send a notify-type dispatch (relayed by container agent-courier)

For dispatches written to `/dispatches/tachikoma/` that should relay back to the user:

```bash
agent-courier create \
  --to steven \
  --delivery-type notify \
  --delivery-id tachikoma \
  --type notification \
  --subject "Alert" \
  --body "Something happened that you should know about." \
  --dispatch-dir /dispatches/tachikoma
```

The container's agent-courier picks this up and relays it to the configured tmux pane on the host.

## Dispatch schema reference

```yaml
---
id: <uuid>                    # auto-generated
reply_to: <uuid>              # response dispatches only
conversation_id: <uuid>       # logical thread
created_at: 2026-04-12T...
updated_at: 2026-04-12T...
status: unread
delivery_type: tmux           # tmux | picoclaw | notify
delivery_id: claude-work      # pane name (tmux) or container (picoclaw)
type: task                    # task | question | review | approval | notification
from: tachikoma
to: steven
model_class: medium           # small | medium | large (for picoclaw dispatch)
subject: "Subject line"
no_reply: false               # set true for fire-and-forget
---
Message body here.
```

## Key flags for `agent-courier create`

| Flag | Description |
|------|-------------|
| `--to` | Recipient name |
| `--delivery-type` | Routing backend |
| `--delivery-id` | Pane or container name |
| `--type` | Dispatch classification |
| `--subject` | Subject line |
| `--body` | Inline body text |
| `--body-file` | Read body from file |
| `--reply-via` | delivery_type for the reply |
| `--reply-delivery-id` | delivery_id for the reply |
| `--no-reply` | Suppress reply dispatch |
| `--dispatch-dir` | Output directory (default: `$DISPATCH_DIR`) |
| `--conv-id` | Conversation thread ID (UUID) |

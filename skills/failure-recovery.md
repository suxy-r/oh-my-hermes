---
name: failure-recovery
description: Use when cron, gateway, deploy, log scanning, or agent work fails and the founder needs a saved error with recovery steps
version: 1.1.0
tags: [cron, failure, recovery, dead-letter, operations]
---

## When to Use

- A scheduled job fails.
- A long-running agent stops without a useful founder-visible reason.
- The founder asks why an autonomous loop is stuck.

## Prerequisites

- `~/.hermes/scripts/run-cron-safe.sh` installed.
- Notification backend configured for alerts when available.
- Hermes v0.19+ for cron durable audit history.

## Procedure

1. Wrap recurring jobs with:
   ```bash
   ~/.hermes/scripts/run-cron-safe.sh --project myapp --name log-scan -- command args
   ```
2. On failure, first check the Hermes cron audit history (v0.19+ durable audit):
   ```bash
   hermes cron history log-scan          # per-job history with exit codes
   hermes cron history --failed          # all failed jobs across all crons
   ```
3. Then inspect the newest dead-letter file:
   ```bash
   ~/.hermes/oh-my-hermes/dead-letter/myapp/
   ```
4. Redact secrets before summarizing.
5. Create or update a kanban task with the failing command, exit code, likely
   cause, and next recovery action.
6. Notify the founder only for actionable new patterns.

## Pitfalls

- Do not paste full command output if it includes request bodies or credentials.
- Do not retry paid or destructive operations automatically.
- Gateway auto-resume (v0.19+) restarts the gateway on crash — if jobs fail
  repeatedly, the issue is not the gateway but the job itself.

## Verification

- A failed wrapped command creates a `600` dead-letter file.
- `hermes cron history` shows the job's failure with an exit code.
- `/status` or `project-status` reports a non-zero dead-letter count.

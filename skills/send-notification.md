---
name: send-notification
description: Use when a deployment completes, a health check fails, or an important status event needs to be reported to the founder
version: 1.2.0
tags: [notification, slack, telegram, ops, webhook, gateway]
---

## Overview

Sends a structured notification to the founder. The Hermes Gateway (v0.19+) is
the primary delivery path with durable ledger-based recovery. Slack webhook and
Telegram direct API are fallbacks for environments where the Gateway is not
running. Logs delivery to Hermes memory.

## When to Use

- After deployment (called by `post-deploy-followup`)
- After health check failure or recovery
- Approval requests (called by `await-merge-approval`)
- Any ops event that needs human awareness

## Prerequisites

One of:
- Hermes Gateway configured and running (primary — durable delivery in v0.19+)
- `SLACK_WEBHOOK_URL` in environment (fallback)
- `TELEGRAM_BOT_TOKEN` + `TELEGRAM_CHAT_ID` in environment (fallback)

## Procedure

**1. Compose message** — include:
- Event type: Deploy / Health Fail / Health Pass / Approval Request / Update
- Project name
- Environment: production or preview
- URL (if deployment)
- Timestamp
- Brief status note (plain English, no raw logs)

**2. Send via Hermes Gateway** (primary — if Gateway is running):

Use the Hermes messaging toolset to send directly to the founder's configured
platform. The Gateway's durable delivery ledger (v0.19+) ensures messages
survive a gateway crash and are re-delivered on restart.

```
send_message("founder", "[event] [project] → [environment]\n[url]\n[status]\n[timestamp]")
```

If the messaging toolset is unavailable or the Gateway is not running, continue
to the fallback backends.

**3. Send to Slack** (fallback if `SLACK_WEBHOOK_URL` is set):
```bash
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d "{\"text\": \"[event] [project] → [environment]\n[url]\n[status]\n[timestamp]\"}")
```
HTTP 200 = delivered. Anything else = log failure, continue to next backend.

**4. Send to Telegram** (fallback if `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` are set):
```bash
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  -d text="[event] [project] → [environment]%0A[url]%0A[status]%0A[timestamp]" \
  -d parse_mode="HTML")
```
HTTP 200 = delivered.

**5. If no backend available:**
- Print notification content to console (do not fail silently)
- Print: "No notification backend configured. Run: hermes gateway setup"

**6. Save to Hermes memory:** key `notification-log`, append `{ event, timestamp, backend, delivered: true/false }`.

## Pitfalls

- Slack webhook URLs expire or get revoked. Non-200 → verify URL in Slack app settings.
- Keep messages under 4000 characters — Slack truncates, Telegram rejects above 4096.
- Never include env var values or credentials in notification content.
- Telegram `TELEGRAM_CHAT_ID` for a personal chat is your numeric user ID — get it by messaging `@userinfobot`.
- If both fallback backends are configured, a failure on one does not block the other.
- Gateway durable delivery retries on crash. Do not send via fallback AND Gateway at the same time.

## Verification

- Message received in founder's configured platform
- Entry appended to `notification-log` in Hermes memory

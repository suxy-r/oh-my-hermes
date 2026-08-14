# Engine Routing

Choose the smallest capable execution surface by ambiguity, risk, verification
cost, and tool horizon. File count and role name are not routing signals by
themselves.

```text
Product strategy, design direction, orchestration, ops, memory, scheduling
  -> Hermes specialist agent

Native macOS or authenticated GUI with no better interface
  -> Hermes computer-use skill

Bounded implementation with explicit acceptance criteria
  -> the available coding agent with the smallest sufficient model

Ambiguous architecture, long tool horizon, or cross-system migration
  -> a strong reasoning coding agent with independent verification

Launch motion graphics from product evidence
  -> Designer + HyperFrames through creative-production
```

## Hermes

Hermes is the long-lived product operator. It can inspect and edit projects
directly, load skills, use browser/CUA tools, schedule work, manage memory, and
delegate specialized coding when that improves reliability.

Use Hermes directly for product briefs, design contracts, routine project edits,
deployments, monitoring, notifications, research, and orchestration.

## Coding Agents

Use a coding agent for bounded changes with clear outcomes, fast exploration,
and focused fixes. Pass product/design acceptance criteria, exact allowed paths,
required evidence, and verification commands.

For cross-module work, prefer one end-to-end executor that retains ownership
through implementation and verification. Do not split a coherent change merely
because it spans several files. Add a separate reviewer only when independent
inspection improves confidence.

## DeepSeek V4

When Hermes uses DeepSeek V4, route by task shape:

| Work | Model and effort |
|---|---|
| Classification or routing that genuinely needs an LLM | V4 Flash `high` |
| Bounded daily agent work and independent review | V4 Flash `high` |
| Ambiguous implementation, architecture, long tool loop | V4 Pro `high` |
| Rare high-risk conflict or irreversible synthesis | V4 Pro `max` |

Prefer deterministic code over an LLM for pure status or formatting. For the
current V4 API use explicit `high` or `max`: `low` and `medium` map to `high`,
while `xhigh` maps to `max`. Use the provider's canonical model IDs and verify
the resolved endpoint in a protocol A/B test instead of inventing dated aliases.

Thinking tool loops must preserve the assistant's `reasoning_content` on every
subsequent request. Streaming clients must tolerate empty chunks and aggregate
parallel tool-call deltas by tool-call index. Maintain a small protocol
conformance suite for every provider/model pair.

Give each invocation the minimum relevant tool schema. A one-iteration call
must have no tools; otherwise a tool call can consume the only iteration before
the model produces a final answer.

## Computer Use

Computer Use is a capability, not a coding engine. Prefer API, file, terminal,
and browser tools. Use CUA only for native or authenticated GUI workflows, and
retain approval gates for external or destructive actions.

## Designer

The Hermes Designer owns product UX and creative direction. It may consume human
mockups or external design-tool output, but no external design session is
required. It writes `DESIGN.md`, verifies rendered output, and uses HyperFrames
for requested launch video.

## Question Rule

Routing uncertainty should rarely block work. Inspect the task, recommend an
engine, state the assumption, and continue. Ask only if engine choice changes
cost, credentials, irreversible state, or a material product outcome.

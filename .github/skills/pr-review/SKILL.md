---
name: pr-review
description: "Review a pull request from the configured Git server, optionally enriched with issue-tracker and specification context. Use when given a pull request number or URL and asked for a code review."
argument-hint: "pull request number or URL"
---

# Pull Request Review

Produce a written code-review report for a pull request. The Git server is required. Issue-tracker
context is optional.

## Dependencies

Read `.github/copilot/project.json` before delegation or external tool use.

If the manifest is missing or invalid, uses an unsupported schema version, or omits a required
capability block, treat it as unconfigured and run `setup-copilot-project` in the main agent.

### Git Server: Required

- `unconfigured`: stop and run `setup-copilot-project` in the main agent.
- `disabled`: stop and state that `gitServer` must be enabled through `setup-copilot-project`.
- `enabled`: read and follow the referenced Git-server instructions.

### Issue Tracker: Optional

- `enabled`: read its operational instructions and use them when the pull request identifies an issue.
- `unconfigured`: run `setup-copilot-project` before delegation when issue context is relevant.
- `disabled`: continue without issue context and record that it was not configured.

### Review Style: Optional

If the `caveman-review` skill is available, load it and apply its presentation guidance to the review
report. Its absence is not an error and must not trigger `setup-copilot-project`. This skill's report
template, severity model, required content, and output path take precedence over style guidance.

Never infer provider-specific tools, URLs, repository identifiers, or issue-key formats when they are
not established by configuration or pull-request metadata.

## Procedure

### 1. Resolve the Pull Request

Accept a number or full URL. Use the configured repository identity for a number. For a URL, validate
that it belongs to the configured Git server and repository. Ask when the reference is ambiguous.

### 2. Fetch Context

Follow the configured Git-server procedure to fetch pull-request metadata, complete per-file diffs,
and existing feedback. Batch independent reads when possible. Do not duplicate existing feedback. If
authoritative diffs cannot be fetched, stop rather than reviewing an assumed local branch.

### 3. Resolve Optional Issue Context

Find an issue reference only through configured conventions or explicit pull-request metadata. When
the issue tracker is enabled, fetch the issue and its acceptance criteria. When disabled or no issue
is identified, continue and state that issue alignment was not evaluated.

### 4. Find Specifications

Search repository specification locations established by repository instructions and obvious local
conventions, including OpenSpec when present. Read only matches clearly related to the issue, title,
branch, or changed capability. Record `None found` rather than inventing a relationship.

### 5. Review

Review the complete diff for correctness against available requirements, regressions, edge cases,
security, authorization, validation, data safety, performance, repository conventions, and adequate
tests. Raise only issues visible in or caused by the diff. Use `must` for blocking correctness or
safety failures and `should` for material non-blocking risks.

### 6. Write the Report

Fill [assets/review-template.md](./assets/review-template.md) and write it to
`.github/copilot/.artifacts/reviews/PR-<pull-request-id>-review.md`.

### 7. Optional Independent Review

Ask whether to invoke `Independent Reviewer`. If accepted, save exact fetched diffs beside the report
and request a fresh, complete review of the entire diff. Merge only novel findings verified against
the authoritative diff. Keep the diff artifact for auditability.

### 8. Summarize

Report must/should counts, available requirement alignment, whether independent review ran, and the
report path.

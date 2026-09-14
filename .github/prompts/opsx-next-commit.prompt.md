---
description: "Implement the next coherent slice of an OpenSpec change, validate it, optionally review it, and commit it."
argument-hint: "[change name] (optional; inferred from context when omitted)"
agent: "agent"
---

Implement **one commit's worth** of tasks from an OpenSpec change: pick a coherent task group, build it,
validate it, optionally review it, then commit.

This is `/opsx-apply` narrowed to a single commit. Never work the whole change in one pass unless the
change is small enough that all its tasks legitimately form one commit.

Do not continue past an unanswered decision point. Ask the user and resume the workflow after the answer.

## Required Dependency

Before acting, resolve and load the exact `openspec-apply-change` skill. This prompt is intentionally
OpenSpec-specific; the dependency is not configurable. If the skill is unavailable, stop and state
that `opsx-next-commit` requires `openspec-apply-change`. Do not improvise its protocol.

Before any configurable capability is relevant, read `.github/copilot/project.json`. Treat an absent
manifest as unconfigured and run `setup-copilot-project` in the main agent. If the file is invalid or
uses an unsupported schema version, stop and run that skill to repair or migrate it; do not infer
capability state from a malformed manifest.

---

## 1. Select the change and load context

Follow steps 1-5 of the `openspec-apply-change` skill: select the change, run `openspec status`, run
`openspec instructions apply`, read every file
listed in `contextFiles`, and show progress. Honour its store-selection, `context`, and
`operationGuidance` rules verbatim.

Use the change named after the command. Otherwise infer it from conversation context, auto-select when
only one active change exists, and ask when ambiguous. Announce `Using change: <name>`.

Stop here and report if the CLI returns `state: "blocked"`.

If it returns `state: "all_done"`, there is nothing left to implement. Run `git status --porcelain`:
if the working tree is clean, report that the change is fully implemented and committed, then stop.
Otherwise treat the uncommitted work belonging to this change as the slice, skip to **step 4**, and
name the already-ticked tasks it covers when building the commit message.

## 2. Define the commit slice

A slice is the smallest set of remaining tasks that produces a **self-contained commit**: it compiles,
its tests pass, and it reads as one intent to a reviewer.

1. **Honour the change's own grouping.** If the tasks artifact states how it wants to be committed —
   a "Commit grouping" note, section-per-commit convention, or explicit cross-section exceptions —
   that statement is authoritative. Follow it exactly, including its exceptions.
2. **Otherwise derive one.** Prefer a whole section. Fall back to a prefix of a section that stands on
   its own. Never split a task.
3. **Respect dependencies.** Include a prerequisite task from another section when the slice cannot
   compile or be tested without it — and tick that task where it is written, never move it.
4. Small change, few tasks, one coherent intent → the slice may be all remaining tasks.

Present the proposed slice to the user before implementing: list the task IDs and titles, state why
they form one commit, and offer to accept, narrow, or widen it. Wait for the answer. Skip this
confirmation only when the change's own grouping fully determines the slice.

## 3. Implement the slice

Implement **only** the selected tasks. Follow the implementation and guardrail rules from step 6 of
the openspec-apply-change skill: minimal focused changes, mark each `- [ ]` → `- [x]` in the tasks file
immediately on completion, pause on ambiguity, and never silently narrow or defer specified behavior.

Do not start a task outside the slice. If implementing the slice reveals that an out-of-slice task is
required, return to step 2 and re-confirm the widened slice.

## 4. Build and checks

Discover repository instructions and existing build files, then run the builds, static checks, and
tests applicable to the slice. A category that the repository does not define is not applicable, not
a missing dependency. Prefer the narrowest commands that validate the changed behavior, but include
the repository's required commit or CI checks when documented.

If validation fails, fix the reported issues and rerun it. Never proceed to review or commit while an
applicable check is failing. After three failed attempts, stop and ask the user how to proceed.

## 5. Independent review (opt-in)

Ask whether to run an independent review of the slice, offering:

- **Run review** (recommended)
- **Skip review**

On **Run review**, invoke the `Independent Reviewer` subagent on the workspace changes belonging to
this slice, passing the change name, the slice's task IDs, and the relevant task/spec/design excerpts
as context. It returns a TODO list or `OK`.

On `OK` or **Skip review**, go to step 7.

## 6. Handle findings, then loop

The reviewer can be wrong. Triage each finding:

- **Clearly correct** → fix it with the smallest change that resolves it.
- **Contested, or requiring a scope / design / risk judgement** -> read `.github/copilot/project.json`
  and resolve the required `grilling` customization. If configuration is missing or unconfigured,
  run `setup-copilot-project` in the main agent. If disabled or invalid, stop and name the capability.
  Ask the user and wait; never resolve a user's decision on their behalf.
- **Valid but outside the slice** (belongs to a later task) → do **not** fix it. Report it and carry it
  as a candidate for the next slice.

If nothing was changed, go to step 7. If anything was changed, return to **step 4**: re-run the build
and checks, then offer a review again. Loop until a review returns `OK`, or the user declines a review,
or no finding required a change.

## 7. Propose the commit

**Check the index first.** Run `git diff --cached --name-only`. If anything is already staged that
does not belong to this slice, stop and ask the user how to proceed — never fold a pre-existing index
into this commit.

**Stage precisely.** Stage only the files touched by this slice plus the OpenSpec tasks file, with an
explicit `git add <path>...` naming those paths. Never `git add -A` and never stage by directory.
Then run `git status --porcelain` and list any modified-but-unstaged files explicitly so the user
sees what is being left out.

**Build the message.**

- Subject: `[<issue-reference>: ]<what this commit does>`, at most 72 characters, imperative mood.
- When the proposal or change name contains a candidate issue reference, inspect `issueTracker` in
  `.github/copilot/project.json`. If it is unconfigured, run `setup-copilot-project`; if enabled, read
  its instructions and use a validated reference; if disabled, omit the prefix and disclose that
  issue enrichment was skipped. Never infer a provider-specific issue-key format.
- Body: a short prose description of the commit's content, plus the covered OpenSpec tasks as
  range(s) — `Tasks 1.1–1.10, 1b.1–1b.4` — not an exhaustive per-task list.

**Ask the user**, quoting the full proposed message and offering:

- **Commit**
- **Commit + push** — label it with the exact resolved destination, `push → <remote-url> <branch>`
- **Other / do nothing** (freeform)

**Push safety.** Before offering *Commit + push*, resolve the current branch's upstream with
`git rev-parse --abbrev-ref --symbolic-full-name "@{u}"` and read that remote's URL with
`git remote get-url <remote>`. Inspect `gitServer` in `.github/copilot/project.json`: if unconfigured,
run `setup-copilot-project` before constructing the push option; if enabled, read and enforce its
`Push Safety` instructions; if disabled, do not offer *Commit + push* and disclose why. Do not offer
it without an upstream or when configured safety rules reject the destination. Show the exact remote
URL and branch in the option.

Execute the chosen action with `git commit`, then, for *Commit + push* only,
`git push <remote> HEAD:<upstream-branch>` using the remote and branch just verified. Never rely on
a bare `git push`, whose destination depends on `push.default`.

## 8. Archive the change when it is complete

Only reachable after a commit actually succeeded. On *Other / do nothing*, report the current state and
stop.

Re-check the tasks file. If any task is still `- [ ]`, skip to the closing report at the end of step 9.

If **every** task is now `- [x]`, ask whether to archive the change now:

- **Archive** (recommended) — the change is done, its deltas belong in the main specs
- **Skip archive** — leave the change active

On **Archive**, resolve and load the exact `openspec-archive-change` skill. If it is unavailable,
report the missing dependency and leave the change active. Otherwise follow it. Archiving moves the change
and syncs its delta specs into `openspec/specs/`, so it produces its own file changes: commit them as
a **separate, additional commit** using the same rules as step 7 (explicit `git add`, subject
`[<issue-reference>: ]archive OpenSpec change <name>`), and push it too when step 7 pushed.

## 9. PR description

Run this only when step 8 finished — either the change was archived, or the user skipped archiving with
all tasks ticked.

Apply [create-PR-comment.prompt.md](./create-PR-comment.prompt.md): read it and follow its template,
writing rules, and output format exactly — reading and executing it is how one prompt runs another.
Display the result as the single fenced code block it specifies, as the final output of this prompt.

If tasks remain, close instead with the remaining progress (`N/M tasks complete`), the task IDs that
make the likely next slice, and any out-of-slice findings carried forward from step 6.

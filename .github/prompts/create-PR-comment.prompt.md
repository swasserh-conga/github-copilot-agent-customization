---
description: "Generate a pull request description following the team's standard PR template. Use when opening a PR or drafting a PR body."
argument-hint: "Brief summary of what changed (optional — context will be inferred from recent work)"
agent: "agent"
---

Generate a pull request description for the changes in this workspace using the template below.

To fill it in:
1. Inspect recent file changes (`#get_changed_files` or git diff) to understand what was modified.
2. If an OpenSpec change was involved, check `openspec/changes/` (or `openspec/changes/archive/`) for the proposal and tasks.
3. Derive the What / Why / How from the code changes and any spec/task files found.

Output the result as a **single fenced code block** (` ``` ` with no language tag) so the user can copy-paste the raw Markdown directly into the PR editor without any rendering or formatting interference. Do not add any text outside the code block.

**Writing style:**
- Keep each section to 2–4 sentences maximum.
- Use short sentences. Avoid semicolon-heavy run-ons.
- Write as if explaining to a teammate in a code review, not a specification document.
- Prefer bullet points in **How?** over long prose when listing multiple decisions.

Use this exact template — preserve all headings, checkboxes, and placeholder text for sections the user must fill in manually:

---

### What?
{A short bullet list describing the net change in plain terms.
What was added, removed, or modified? What does it look like from the outside?

Example: "Moves notification preferences out of the profile payload into a dedicated setting.
It is now exposed consistently by the create, update, and read endpoints."}

### Why?
{A short bullet list on the motivation — business need or engineering pain.
Why does this matter? What problem does it solve?

Example: "Profile validation and notification delivery serve different purposes and were coupled.
Separating them makes ownership, testing, and future changes simpler."}

### How?
{A short bullet list of the key implementation decisions. Not a full walkthrough — just the choices worth highlighting.

Example:
- Added a dedicated notification-preference model
- Kept profile validation focused on profile fields
- Added mapping at the service boundary
- Exposed preferences through the existing settings endpoint}

#### OpenSpec
Was OpenSpec used to implement this feature: **YES** or **NO**

{If YES: one sentence naming the change and a link to the archived proposal.
Example: "Change `add-user-auth`, archived at `openspec/changes/archive/YYYY-MM-DD-add-user-auth/proposal.md`."
If NO: one sentence explaining why OpenSpec was not used.}

### Testing?
- [X] {Action used to verify, e.g. "Run focused tests: `npm test -- notifications`"}
- [X] {Any additional manual or automated step worth calling out}
- [ ] {Any validation item that was not performed but worth noting}}
- ...
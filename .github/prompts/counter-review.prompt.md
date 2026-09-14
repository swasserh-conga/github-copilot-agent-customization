---
name: counter-review
description: "Run an iterative two-model counter-review from the current session, an attached document, or a specified file"
argument-hint: "[source file, attachment, or omit for current session]"
agent: "Counter Review Owner"
---

Run the complete counter-review workflow.

Use the source named after `/counter-review`. If no source is named, use attached content when
present; otherwise use the relevant information in the current conversation.

Continue until a reviewer returns `OK`. Ask the user and wait whenever a human decision is needed;
do not continue past an unanswered decision or review-iteration choice.

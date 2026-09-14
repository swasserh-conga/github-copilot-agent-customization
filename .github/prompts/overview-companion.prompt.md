---
description: "Write a plain-language overview companion document that explains a dense technical artifact — design review, RFC, ADR, spec, or the current chat session — to a reader with no background. Use when asked to explain something for newcomers, summarize the big picture, produce an overview or explainer, onboard someone to a decision, or make a document readable by non-experts. Produces problems-and-decisions narrative with Mermaid diagrams, not an exhaustive action list."
name: "Overview companion"
argument-hint: "Optional: path to the source document, and/or the intended audience"
agent: "agent"
tools: ["search", "edit"]
---

Write a **companion document** that lets someone who knows nothing about this subject understand the decisions, the direction, and what is being put in place.

## 1. Establish the source

Work from whichever applies, in this order:

1. A document the user named or attached.
2. A document clearly under discussion in this session.
3. **The session itself** — the reasoning, decisions, and rejected options produced in this conversation. This is a valid source; do not ask for a file if the conversation already contains the material.

If the source is a document, read **all** of it before writing. Do not work from its headings.

## 2. Know who you are writing for

Assume a competent reader with **no context**: no familiarity with the codebase, the ticket, the vocabulary, or the history. They want to understand *why* things were decided, not to implement them.

The companion is not a summary and not an abridgement. It is the **explanation the source document does not stop to give** because its own readers already know it.

## 3. Find the spine before writing a word

This is the step that decides whether the document is worth reading.

- **Look for the single difficulty from which the problems follow.** Most designs have one — a constraint, a physical limit, an impossibility. Lead with it. A reader who understands one root cause can follow five consequences; a reader given five independent problems remembers none.
- **Pair each problem with its decision**, problem first. State the decision as a *principle*, then the mechanism — "stop inventing an order, borrow the one the database already has," before the column names.
- **Say what is elegant or counter-intuitive.** If a decision is clever, explain why; that insight is usually what makes everything after it legible.
- **Prefer a concrete failing scenario to an abstract description.** "Two events for one node, handled at the same time, one says completed and one says failed" beats "concurrency hazards exist."

## 4. Structure

Adapt these; do not follow them mechanically. Drop any that the source does not support.

1. **The setting** — what the system does, in a paragraph, using no term the reader must already know.
2. **What is changing, and why** — the honest reason, including what it costs.
3. **The root difficulty** — section 3's spine.
4. **Each problem, and the decision it produced** — the core of the document.
5. **What is being built** — the new pieces, and what each is *for*.
6. **The promise and where it stops** — the guarantee, stated with its boundary. A guarantee with an unstated exception is worse than a smaller one stated exactly.
7. **How we will know it works** — observability, in operational terms.
8. **What was rejected, and why** — one line each. This gives the reader the shape of the design space, and stops settled arguments from being reopened.
9. **How it is sequenced** — the delivery stages and the rule that decides what goes where.

## 5. Use diagrams where they earn their place

Illustrate when a picture is faster than the paragraph. Mermaid is preferred since it renders in place.

| Use | For |
| --- | --- |
| `sequenceDiagram` | A race, an interleaving, a failure that depends on ordering. The highest-value diagram — a two-actor sequence explains in seconds what prose takes a paragraph to set up |
| `flowchart` | Before/after architecture; a decision or resolution rule |
| `stateDiagram-v2` | A lifecycle with named states and the transitions between them |
| `erDiagram` / table | Data shapes, key structures, who writes what |

Rules:

- **A diagram that restates the adjacent prose is noise.** Every diagram must carry something the text does not.
- Label the actors with real names from the system, not `A` and `B`.
- Draw the **failure**, not just the happy path. The happy path is rarely what needs explaining.
- Keep each one small enough to read without scrolling. Two focused diagrams beat one that shows everything.
- Verify the syntax is valid Mermaid before writing it.

## 6. Rules

- **Do not restate the source's action lists.** The companion explains; the source specifies.
- **Point, do not duplicate.** Reference the source by its own identifiers — item IDs, section names, anchors — so a reader can go deeper without you re-explaining the detail here.
- **Assert nothing the source does not support.** If a rationale is missing, say the source does not give one; do not invent a plausible reason.
- **No history of the writing.** Explain the design as it stands, not the order in which it was figured out — unless the abandoned attempts themselves teach something, in which case give them one short section at the end.
- **Define each term at first use**, in the sentence itself rather than a glossary.
- **Length is a feature.** Aim for something read in one sitting. If a section can be cut without the reader losing the thread, cut it.

## 7. Output

Create a **new file** beside the source, named to mark it as the companion (`<source>-overview.md`, `<source>-explained.md`, or similar). Never edit the source.

Match the source's language unless the user asks otherwise.

When finished, state in one or two sentences what organizing choice you made — the spine you picked and why — so the user can challenge it.
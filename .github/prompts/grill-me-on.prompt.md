---
name: "grill-me-on"
description: "Interview the user relentlessly about a subject until a shared understanding is reached, exploring the codebase when possible"
argument-hint: "subject to interrogate"
agent: "agent"
---

Interview me relentlessly about every aspect of ${input:source:subject} until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time. Provide an approximate number of remaining questions as you go.

If a question can be answered by exploring the codebase, explore the codebase instead.

Write and update all information in **session** memory as you go.
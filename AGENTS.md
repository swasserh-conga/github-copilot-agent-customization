# AGENTS.md

Before starting work in this repo (creating, modifying, or reviewing an
instructions, prompt, skill, or agent file), read the **agent-customization**
skill first. It describes the conventions to follow (YAML frontmatter,
`applyTo`, the structure of `.instructions.md`, `.prompt.md`, `.agent.md`,
`SKILL.md` files, etc.).

If its content isn't already present in context, load it with the file-reading
tool before taking any other action.

## Customization Structure

In consumer customizations, group intrinsic and configurable prerequisites
under a `Dependencies` section near the top, before behavioral procedures and
output contracts.

Store disposable workspace artifacts under `.github/copilot/.artifacts/`.

## Language

All content in this repository (instructions, prompts, agents, skills,
README, AGENTS.md) must be written in US English.

## Updating README.md

On every change to this repo (adding, modifying, or removing an instruction,
prompt, agent, or skill), update the README.md accordingly. On each update,
"compress" its content: keep only the essentials a human user would expect to
find in a README (repo purpose, folder structure, how to contribute). Do not
add a changelog or superfluous details.


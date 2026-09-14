# github-copilot-agent-customization

Repository of GitHub Copilot customizations: reusable instructions, prompts,
agents, skills, and lifecycle hooks. Copy `.github/` into a repository, then run
`/setup-copilot-project` before using integrations that need repository-specific
information.

## Structure

- `.github/instructions/` - coding rules by language or context
- `.github/prompts/` - reusable prompts
- `.github/agents/` - specialized agents
- `.github/skills/` - reusable workflows, including project setup
- `.github/hooks/` - non-blocking session configuration checks
- `.github/copilot/` - committed per-repository configuration

## Configuration

`.github/copilot/project.json` records capability state and short metadata.
Enabled integrations use provider-specific operational Markdown in the same
directory, such as `issue-tracker.md` and `git-server.md`. Configuration is
optional per capability and must never contain secrets.

Consumers declare capabilities as required or optional. Missing, invalid, or
unconfigured capabilities trigger setup when relevant. Disabled optional
capabilities are skipped; disabled required capabilities stop the workflow. The
`SessionStart` hook only injects guidance and never interrupts unrelated work or
opens an interactive prompt.

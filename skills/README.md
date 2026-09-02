# skills/

Empty on purpose. `conventions/` covers *standards* (how to write Python, how
Django models should look). Put *workflows* here instead — multi-step
procedures an agent should follow for a recurring task, e.g. "add a new REST
endpoint following our conventions" or "cut a release."

Each skill is a folder with a `SKILL.md` (YAML frontmatter: `name` +
one-line `description`, then instructions in the body). This is Claude's
native Agent Skills format — only the name and description load by default;
the full body loads when Claude judges it relevant to the task. If you reuse
skills across projects the same way as `conventions/`, they travel with this
submodule for free.

Not filled in yet — add skills here as you notice agents repeating the same
multi-step task across projects.

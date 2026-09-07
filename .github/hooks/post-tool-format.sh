#!/usr/bin/env bash
#
# PostToolUse hook (GitHub Copilot agent mode, VS Code): format/lint
# whatever file the agent just wrote or edited.
#
# This is kept as a SEPARATE, native config from the Claude Code hook at
# .claude/hooks/post-tool-format.sh -- this repo treats each agent's
# hook config as its own thing so either can be edited/removed
# independently.
#
# This repo is a "standards" repo (multiple language conventions, no
# single toolchain installed) so this script is just a
# placeholder. Copy this repo's conventions into a real project and put
# actual formatter/linter logic here (e.g. ruff, eslint, prettier,
# biome — whichever conventions/*.md names for the file type at hand).
#
# Never blocks the tool call -- always reports continue.

echo "post-tool-format hook ran"
echo '{"continue":true}'
exit 0

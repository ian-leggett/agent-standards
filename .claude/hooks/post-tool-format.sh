#!/usr/bin/env bash
#
# PostToolUse hook: format/lint whatever file Claude just wrote or edited.
#
# This is a "standards" repo — it documents conventions for several
# languages (see conventions/*.md) but has no single toolchain installed
# itself. So this script is just a placeholder. Copy this
# repo's conventions into a real project and put actual formatter/linter
# logic here (e.g. ruff, eslint, prettier, biome — whichever
# conventions/*.md names for the file type at hand).
#
# Reads the PostToolUse hook JSON payload on stdin and never fails the
# tool call (always exits 0) — formatting is a nice-to-have, not a gate.

echo "post-tool-format hook ran"
exit 0

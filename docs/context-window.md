# Managing the context window

An agent's context window is the working memory it has for the *entire*
task: your instructions, `AGENTS.md`/`CLAUDE.md`, every file it reads, every
tool result, and its own prior output. It's finite, and unlike a human
skimming a codebase, an agent pays for — and is measurably affected by —
everything that's in it.

## Why a smaller context window matters

More context isn't free, and it isn't neutral. As the window fills up:

- **Relevant details get harder to find.** The agent has to weigh a growing
  pile of tokens against each other, and instructions given early can get
  crowded out or diluted by everything that came after.
- **Attention degrades.** Models are demonstrably less accurate at using
  information buried in a long context than the same information given
  concisely — this holds even well before the hard token limit is reached.
- **Irrelevant content becomes noise, not just weight.** A stray file, an
  old tool result, or a verbose log doesn't just cost tokens — it competes
  for attention with the things that actually matter to the current step.
- **Errors compound.** A bad assumption or stale fact that enters the
  context early tends to get referenced again later, amplifying its effect
  the longer the session runs.

The practical implication: keep the context window **small and relevant**,
not just under the hard limit. "Fits" is not the same as "efficient."

## How to use tokens efficiently

- **Prefer targeted reads over dumping whole files.** Read the specific
  function, section, or line range you need rather than an entire large
  file when only a fragment is relevant.
- **Use progressive disclosure.** Keep always-on instructions
  (`AGENTS.md`/`CLAUDE.md`) short, and link out to detail files
  (`conventions/*.md`, skills) that only get pulled into context when
  they're actually relevant to the task at hand. This repo is built around
  exactly that pattern — see [What is an AGENTS.md file?](./agents-md.md).
- **Summarize instead of forwarding raw output.** When a subagent, search,
  or tool call produces a lot of output, extract the few facts that matter
  rather than passing the whole result forward.
- **Offload exploratory work.** For research or wide searches whose
  intermediate output you won't need again, delegate to a subagent (or a
  forked one) so that noise stays out of the main context — only the
  distilled result comes back.
- **Don't re-read what you already know.** Avoid re-fetching a file or
  re-deriving a fact that's already established earlier in the
  conversation.
- **Close loops instead of leaving them open.** Finish and discard
  intermediate scratch content (temp files, draft notes) rather than
  letting it accumulate as context across many turns.
- **Trim tool output at the source.** Prefer commands and tool calls that
  return exactly what's needed (a specific field, a filtered log, a line
  range) over ones that return everything and rely on the agent to ignore
  the rest.

## Skills and MCP servers change the baseline

Skills and MCP servers aren't free just because they're not files you opened
yourself — both add to the context window before the agent does anything
useful.

- **MCP tool definitions load up front.** Every connected MCP server
  registers its tool schemas (names, descriptions, parameters) into context
  at session start, whether or not any of those tools get called. A handful
  of MCP servers can add up to a meaningful chunk of the window before the
  first user turn — connect only the servers a given task actually needs, not
  every one available.
- **Verbose tool results compound the cost.** An MCP tool that returns a full
  API payload (a whole Jira issue, a whole page tree) instead of the fields
  actually needed pushes the same "irrelevant content is noise, not just
  weight" problem from raw file reads into every call — see [How to use
  tokens efficiently](#how-to-use-tokens-efficiently).
- **Skills are metadata-cheap, body-expensive.** A skill's name and one-line
  description sit in context so the agent can decide whether it's relevant,
  but that's a small, fixed cost across many skills. The skill's actual
  instructions only load when it's invoked — so a repo can define many
  skills without taxing every conversation, as long as each skill's body
  stays focused on the task it covers rather than growing into a catch-all.
- **Prefer fewer, targeted connections over broad ones.** A narrowly-scoped
  MCP server or skill is easier for the agent to reason about and cheaper to
  keep connected than a broad one where most of the surface area is unused
  in any given task — the same progressive-disclosure principle that governs
  `AGENTS.md`/`CLAUDE.md` applies to tool and skill surface area.

## The rule of thumb

Every token in the context window should be there because the current step
needs it. If it doesn't earn its place, it's not just wasted budget — it's
actively working against the agent's ability to focus on what does matter.

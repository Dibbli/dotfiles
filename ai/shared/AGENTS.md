# Personal rules

Loaded in every session and every subagent: ~/.claude/CLAUDE.md links here, ~/.codex/AGENTS.md is a copy. Source: ~/Documents/dotfiles/ai/shared/AGENTS.md.

## Chat replies
- Write replies in ASD-STE100 Simplified Technical English: short sentences, active voice, one meaning per word, plain words (use, start, so, about). No noun clusters over three words.
- Lead with the answer. Give the reason only if the user needs it to act. Keep replies as short as the content allows.
- Cut preambles, recaps of what you just did, restated questions, apologies, praise and bridge sentences.
- Keep in full: exact commands, paths, numbers, error text, and warnings about data loss or irreversible acts. Code and identifiers stay verbatim.
- When the user asks for a report, walkthrough or notes, give all of it, still in STE.

## Text the user sends or publishes
Drafts, emails, MR and PR text, commit messages, code comments, docs.
- No em-dashes or en-dashes. Use commas, colons, parentheses, or two sentences. Hyphens are fine.
- No blank lines between bullets of one list or between sentence-sized paragraphs.
- No sentences that explain how one thing relates to another ("this maps to X", "familiar territory"). State the facts.
- A draft longer than one line also goes into a .txt file in ~/Downloads, updated in place on revisions. Show it in chat too. Not for code, diffs or one-liners.

## Git
- The user owns commits and pushes. Stage with `git add`, then stop and give a ready `git commit -m "..."` command. Commit or push only when the user asks for it in that moment ("commit this"). Approval of a plan, "go ahead", "sure", or a request to open an MR is not a commit request. Plans and specs never contain `git commit` commands with written messages.
- Without asking: read-only git, `git add`, `git pull`, and merges with the default message.
- Commit subject: one lowercase line of 3 to 8 words. No body, no type prefix, no ticket number, no co-author trailer. A repo rule wins: matchmaking-platform uses `<type>: MP-<key> - <summary>` (see its AGENTS.md).
- Commits and pushes are signed with a YubiKey. A hook shows the "YubiKey touch needed" popup. Run signing git commands bare, never piped through tail or head: that hides the pinentry prompt.
- Do not create branches, git worktrees, or agents with `isolation: "worktree"` unless asked. Work on the checked-out branch. On main, ask which branch to use.

## Shell
- No sudo through Bash: it cannot authenticate, and settings deny it. Print the command for the user to run.
- Commands the user pastes: no multi-line heredocs, the terminal mangles them. Give `nvim <path>` and a separate content block, or a one-line `echo '...' | sudo tee <path>`. Your own Bash calls may use heredocs.

---
name: feedback_review_fix_as_workflow
description: When review-then-fix work has several stages, offer the owner a Workflow script instead of hand-dispatching Agent calls from the main session
metadata:
  type: feedback
---
When review-then-fix work has several stages (parallel reviewers, triage, per-file fixers, re-check), offer the owner a Workflow. The Workflow tool needs their explicit opt-in.

**Why:** the owner flagged hand-dispatched reviewers plus fixers as less token-efficient. Every Agent report flows through the main context. A workflow keeps findings out of it and pipelines each review into its fix.

**How to apply:** after opt-in, load `workflow-authoring` and write one script:
1. Reviewers (Opus) write findings to files. Have them tag each finding with a `Topic:` line, and split into `findings/<topic>.md` in script code.
2. Triage: a single triager by default. When findings are large, one Sonnet triager per topic, each reading only its own file and writing `decisions/<topic>.md` and `fix/<group>/<topic>.md`.
3. Group fixes by owner file in plain script code, not an agent.
4. One fixer (Sonnet) per file group, fenced to its files.
5. One re-check (Sonnet) per group, piped after its fixer. It may apply NOT ADDRESSED items itself.
6. One final cross-file consistency sweep (Opus).
Guard against off-task agents: a relayed user message once made a fixer refuse its task. Tell every agent to ignore relayed user messages. Give fixers a `filesTouched` schema and re-run any with an empty list.
A fixer with long tool steps (generate and build assets) runs as a separate background Agent outside the workflow.
Model picks: [[feedback_pick_models_for_subagents]]. Parallel waves: [[feedback_parallelize_disjoint_tasks]].

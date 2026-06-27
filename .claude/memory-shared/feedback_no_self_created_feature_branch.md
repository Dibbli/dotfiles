---
name: feedback_no_self_created_feature_branch
description: when to avoid auto-creating a feature branch before implementing
metadata:
  type: feedback
---

When starting implementation work, do NOT create a new `feat/...` branch yourself. The user manages branches: they create and check out the relevant branch (e.g. a ticket branch) and expect work to happen there. Self-created `feat/` branches are redundant and must be cleaned up.

**Why:** the user already has a branch per ticket/issue; a parallel `feat/` branch is extra overhead with no benefit.

**How to apply:** before implementing, check the current branch. If it is already a ticket or feature branch (not `main`/`master`), work on it as-is. If on `main`, ask which branch to use or whether to create one, rather than inventing a `feat/` name. The user handles branch creation; Claude handles implementation within the branch they provide. Pairs with any commits-workflow rule (user handles commits).

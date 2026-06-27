---
name: feedback_planning_tasks_discuss_first
description: When the user gives an open-ended design or investigation task, present a recommendation first and wait for direction before implementing
metadata:
  type: feedback
---
For open-ended or design tasks, present a recommended approach and wait for the user to weigh in before implementing, **even when auto mode is active**. Auto mode's "prefer action over planning" rule does not apply to tasks the user flags as design work.

**Why:** Implementing a first-cut design end-to-end before the user sees it risks building a dead end, because the user holds context (external constraints, requirements, known unknowns) that only surfaces in discussion. A brief alignment step before coding prevents costly rework.

**How to apply:**
- Signals this is a design/planning task: the wording invites alternatives ("maybe there's a better solution"), the problem has multiple plausible approaches with different tradeoffs, or the user says anything like "investigate", "think about", or "research".
- When you have a recommendation, state it clearly with the tradeoff, then stop. Let the user say "go" or redirect.
- Implementation details that fall out of an approved approach can proceed autonomously. This rule is about the direction, not every step.
- **Do not silently refine an agreed plan.** If the user stated a literal design, implement exactly that. Do not add extras that seem like improvements. Any refinement beyond the stated plan is itself a design decision that needs alignment.
- **Take exclusions at face value.** When the user says "cut all X out", do not carve out a permissible subset of X. The intent is no X, not a narrower flavor of X. Literal beats clever.

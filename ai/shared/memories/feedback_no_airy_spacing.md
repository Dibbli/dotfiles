---
name: feedback_no_airy_spacing
description: When writing bullets, short paragraphs, code comments, or any deliverable the user will send or publish
metadata:
  type: feedback
---
Do not pad output with blank lines between every bullet or every short paragraph. This applies to written deliverables (emails, copy, PR descriptions, commit messages, code comments, docstrings) and to any text the user will send or publish. Airy vertical spacing is a tell that text was AI-generated.

**Why:** The user flagged "too many spaces between lines, obvious AI" on a written draft. The issue was blank lines between each bullet and between every short paragraph, giving the output a padded, templated feel.

**How to apply:** Bullets in the same list: no blank lines between them. Keep standard single-blank-line spacing between genuine paragraphs, not between every sentence-sized chunk. If a section is only two or three lines, let it flow as one block instead of three padded ones.

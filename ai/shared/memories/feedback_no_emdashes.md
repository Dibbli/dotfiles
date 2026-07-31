---
name: feedback_no_emdashes
description: When writing any text output — prose, code, docs, or messages — never use em-dashes; use commas, colons, parentheses, or periods instead
metadata:
  type: feedback
---
Never use em-dashes (—) or en-dashes (–) in any output the user will read, share, or send. This covers all output types: prose, code comments, docstrings, commit messages, PR descriptions, Markdown headings, document titles, changelog bullets, emails, and working drafts.
**Why:** Em-dashes are a common AI-writing tell. The user does not use them, and their presence in any output signals machine generation even when everything else reads naturally. The user has flagged this repeatedly across contexts.
**How to apply:** Before producing any text, avoid writing `—` or `–` in the first place. For parenthetical asides, use commas or parentheses. For "title — explanation" patterns, use a colon. For interrupted sentences, restructure into two sentences or use commas. If em-dashes appear in text the user pasted in, do not preserve them when rewriting or editing. Hyphens (-) are fine. En-dashes in date ranges ("2020-2021") are acceptable but a hyphen is always the safer default.

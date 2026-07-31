---
name: feedback_long_output_to_downloads
description: When to save drafted content to a .txt file in ~/Downloads instead of (or in addition to) printing in chat
metadata:
  type: feedback
---
When the user asks to draft or write something longer than a single line (emails, messages, copy, notes, longer text snippets), save it to a `.txt` file in `~/Downloads/` rather than relying on chat output for copying.
**Why:** Terminal/chat rendering mangles formatting, making clean copy-paste painful. A plain .txt file in ~/Downloads lets the user grab the text exactly as written.
**How to apply:**
- For new drafts: create a descriptive filename (e.g. `draft.txt`, `intro_email.txt`).
- For revisions on the same piece: update the existing file rather than creating a new one.
- Still show the content in chat so the user can review without opening the file; the file is for clean copying.
- Applies to drafted prose/copy. Does NOT apply to code snippets, diffs, or short one-liners.

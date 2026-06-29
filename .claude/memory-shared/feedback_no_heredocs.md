---
name: feedback_no_heredocs
description: when about to suggest a multi-line heredoc (cat <<EOF / tee <<'EOF') to create or edit a file
metadata:
  type: feedback
---
Do not use `cat <<EOF ... EOF` or `sudo tee file <<'EOF' ... EOF` snippets to create or edit files. Some terminals mangle multi-line heredoc pastes (leading whitespace, line-wrap corruption).
**Why:** Multi-line heredocs break silently when pasted into certain terminal emulators and multiplexers.
**How to apply:** Give an editor command (e.g. `nvim <path>`) followed by the file contents as a clean, separate copy-paste block. For true one-liners only, `echo '...' | sudo tee <path>` is acceptable. Never use multi-line heredocs.

---
name: feedback_extract_dont_peek
description: When working with archives (tar.gz, zip) and disk space allows, extract directly instead of listing contents first
metadata:
  type: feedback
---

For inspecting large archives (tar.gz, zip), skip the listing-peek step (`tar -tzf`, `unzip -l`) and extract directly when disk space allows.
**Why:** Listing a compressed archive is nearly as slow as extracting it (gzip must be streamed end-to-end either way), so peeking then extracting is double the I/O wait for no gain.
**How to apply:** When there is confirmed free disk space for the uncompressed size, extract immediately and inspect the on-disk tree with `du`/`find`. Only peek-list when extraction would risk filling the disk.

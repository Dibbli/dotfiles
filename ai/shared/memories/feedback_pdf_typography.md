---
name: feedback_pdf_typography
description: Every PDF deliverable uses Lilex Nerd Font Mono on a white page, built with typst, verified with pdffonts and pdfinfo
metadata:
  type: feedback
---

**Font.** Any PDF deliverable (report, one-pager, summary) uses **Lilex Nerd Font Mono** (the user's terminal font, NixOS package `nerd-fonts.lilex`) on a white page.

**Build.** Use typst unless the user names another tool:

```
typst compile doc.typ ~/Downloads/<name>.pdf
```

Keep the `.typ` file in the session scratchpad. Never put it in `~/Downloads`. Never put it in a project repo.

**Font check.** Typst defaults `raw` to DejaVu Sans Mono. The `show raw:` rule must set the font too, or two fonts embed. Verify with `pdffonts <out>.pdf`. Only `LilexNFM-*` may appear.

**Page count.** Verify with `pdfinfo`. If the user asked for one page, deliver one page.

**Fallback.** Where typst is absent, use LibreOffice HTML:

```
font-family: "Lilex Nerd Font Mono", monospace; font-size: 10pt; line-height: 1.5; @page { margin: 2.5cm }
```

then:

```
libreoffice --headless --convert-to pdf <source>.html --outdir ~/Downloads
```

**Filenames.** Short, lowercase, hyphen- or underscore-separated, doc type included. Name it how a developer would, not how an AI describes it. Good: `weekly-status.pdf`, `db-migration-plan.pdf`. Bad: `report-on-the-weekly-status-update-final.pdf`.

Related: [[feedback_gruvbox_palette]] for colours.

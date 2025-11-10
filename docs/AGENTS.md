---
layout: default
title: AGENTS
description: ABAP development notes and examples for AGENTS
---

# Repository Guidelines

## Project Structure & Organization
- Notes live in this folder; each topic is a standalone `*.md` file (e.g., `Overview.md`, `ABAP CDS Overview.md`).
- All images/PDFs go under `attachments/` (e.g., `attachments/Pasted image … .png`). Prefer descriptive names like `cds-views-example-2025-11-02.png`.
- Keep related examples and small diagrams embedded in the same note to preserve context.

## Authoring Conventions
- File names: Title Case with spaces, `.md` suffix (match existing pattern).
- Headings: exactly one `#` H1 (title), then `##`/`###` for sections.
- Links: use Obsidian wikilinks `[[Overview]]` and embed assets `![[attachments/filename.png]]`.
- Code: fenced blocks with language hint, e.g. ```abap … ``` for ABAP. Keep keywords UPPERCASE; use `"` for inline comments.
- Tags: add focused tags at top (e.g., `#abap #sap-learning #cds`).

## Local Tools & Checks
- Search quickly: `rg -n "TODO|FIXME|REVISIT"` and `rg -n "SELECT|LOOP|CLASS" *.md`.
- Optional lint: `markdownlint "**/*.md"` if installed; fix headings, lists, fenced blocks.
- Optional format: `prettier -w "**/*.md"` if present. Avoid mass reflows that harm diff clarity.

## Commit & Pull Request Guidelines
- Commit messages: `<type>: <summary>` where type ∈ {docs, content, fix, chore}. Examples: `docs: clarify CDS annotations`, `content: add ABAP runtime analysis notes`.
- Scope small and topical; prefer incremental commits over large reorganizations.
- PRs: include a brief description, screenshots of changed diagrams/renders, and link related issues or notes (`[[Note Name]]`).
- Avoid renaming existing notes unless necessary; if renaming, update all wikilinks in the PR.

## Security & Configuration
- Do not include credentials, system IDs, or customer data. Use placeholders like `MANDT 000` and `USER DEMO`.
- Avoid committing private Obsidian workspace files unless intended; keep assets in `attachments/` only.

## Agent-Specific Instructions
- Respect existing naming and folder layout; place new assets in `attachments/`.
- Prefer minimal diffs; do not mass-reformat unrelated notes.
- When generating code samples, ensure they compile conceptually and are idiomatic ABAP.

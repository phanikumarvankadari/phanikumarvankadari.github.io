# Code Repository

A comprehensive collection of ABAP programming notes, examples, and best practices for SAP developers.

## View Online

This documentation is published as GitHub Pages at: **[Your GitHub Pages URL will be here]**

## What's Inside

- **Advanced ABAP**: Object-oriented programming, formatting, conversions
- **Tables & ALV**: Internal table handling, ALV implementations
- **Modern ABAP**: Expressions, constructors, and functional programming patterns
- **CDS & RAP**: Core Data Services and RESTful ABAP Programming
- **Integration**: ALE, IDocs, RFC, BAPI, BDC, and more
- **Quick Recipes**: Ready-to-use code templates and patterns
- **Error Handling**: Best practices for robust applications

## Structure

```
├── docs/                    # GitHub Pages content
├── *.md                    # Original notes (Obsidian format)
├── attachments/            # Images and assets
└── .github/workflows/      # Automation
```

## Automatic Publishing

This repository uses GitHub Actions to automatically deploy updates to GitHub Pages whenever changes are pushed to the `main` branch.

## Contributing

1. Edit the markdown files in the root directory
2. Commit and push changes to the `main` branch
3. GitHub Actions will automatically update the published site

## Local Development

To work with these notes locally:

1. Clone the repository
2. Open with any markdown editor (Obsidian recommended)
3. Edit files and commit changes

## Adding New Content (SOP)

### Step 1: Create New Markdown File
1. Create a new `.md` file in the root directory (not in `/docs/`)
2. Use **Title Case with spaces** for filename: `New Topic Name.md`
3. Add YAML front matter at the top:
   ```yaml
   ---
   layout: default
   title: "New Topic Name"
   ---
   ```

### Step 2: Write Content
1. Use exactly **one H1 heading** (`# Topic Name`)
2. Use `##` and `###` for subsections
3. Add focused tags at top: `#abap #new-topic #specific-area`
4. Use ABAP code blocks with syntax highlighting:
   ````markdown
   ```abap
   DATA: lv_variable TYPE string.
   ```
   ````

### Step 3: Update Homepage Navigation
1. Edit `docs/index.md`
2. Add your new page link in the appropriate section:
   ```markdown
   - [New Topic Name](New Topic Name.html)
   ```
3. Choose the right section:
   - **Advanced ABAP**: Complex features, OOP, performance
   - **CDS & RAP**: Views, annotations, behavior
   - **Integration**: External interfaces, data exchange
   - **Quick Recipes**: Templates, patterns, utilities

### Step 4: Sync and Deploy
1. Run sync script: `./sync-docs.sh`
2. Test locally: `cd docs && bundle exec jekyll serve`
3. Preview at `http://127.0.0.1:4000`
4. Commit and push:
   ```bash
   git add .
   git commit -m "docs: add new topic name"
   git push
   ```

### Step 5: Verify Deployment
1. Check GitHub Actions completed successfully
2. Visit your GitHub Pages site to confirm the new content appears

### Content Guidelines
- **Keep it practical**: Include working code examples
- **Use placeholders**: `MANDT 000`, `USER DEMO` (no real data)
- **Follow patterns**: Look at existing files for style consistency
- **Add context**: Explain when and why to use each technique

## Tags

`#abap` `#sap-learning` `#cds` `#rap` `#alv` `#oop` `#integration`

---

*This toolkit is maintained as a learning resource for the ABAP development community.*
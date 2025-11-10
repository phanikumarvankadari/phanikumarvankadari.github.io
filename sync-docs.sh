#!/bin/bash
# sync-docs.sh - Script to sync Obsidian notes to docs folder for GitHub Pages

set -e

NOTES_DIR="/Users/phani/lcoal_ws/obsidian/vault_2025/vault_2025/2 - Resources/SAP Learning/ABAP Learning/notes"
DOCS_DIR="$NOTES_DIR/docs"

echo "Syncing Code Repository to docs folder..."

# Function to add front matter to a markdown file
add_front_matter() {
    local file="$1"
    local title="$2"
    local description="$3"
    
    # Check if file already has front matter
    if head -1 "$file" | grep -q "^---$"; then
        echo "  File $file already has front matter"
        return
    fi
    
    # Create temporary file with front matter
    cat > "$file.tmp" << EOF
---
layout: default
title: $title
description: $description
---

EOF
    
    # Append original content
    cat "$file" >> "$file.tmp"
    
    # Replace original file
    mv "$file.tmp" "$file"
    
    echo "  Added front matter to $file"
}

# Copy all markdown files
echo "📋 Copying markdown files..."
rsync -av --include="*.md" --exclude="*" "$NOTES_DIR/" "$DOCS_DIR/"

# Copy attachments
echo "📎 Copying attachments..."
rsync -av "$NOTES_DIR/attachments/" "$DOCS_DIR/attachments/"

# Add front matter to key files
echo "📝 Adding front matter to markdown files..."

# Core ABAP files
if [ -f "$DOCS_DIR/Object Oriented ABAP.md" ]; then
    add_front_matter "$DOCS_DIR/Object Oriented ABAP.md" "Object Oriented ABAP" "Core OOP concepts, classes, interfaces, inheritance, and design patterns in ABAP"
fi

if [ -f "$DOCS_DIR/ABAP CDS Overview.md" ]; then
    add_front_matter "$DOCS_DIR/ABAP CDS Overview.md" "ABAP CDS Overview" "Introduction to ABAP Core Data Services and data modeling concepts"
fi

if [ -f "$DOCS_DIR/CDS Basics Cookbook.md" ]; then
    add_front_matter "$DOCS_DIR/CDS Basics Cookbook.md" "CDS Basics Cookbook" "Practical CDS examples and patterns for common scenarios"
fi

if [ -f "$DOCS_DIR/ABAP Error Handling.md" ]; then
    add_front_matter "$DOCS_DIR/ABAP Error Handling.md" "ABAP Error Handling" "Exception handling patterns and best practices in ABAP"
fi

if [ -f "$DOCS_DIR/ALV Grid.md" ]; then
    add_front_matter "$DOCS_DIR/ALV Grid.md" "ALV Grid" "ALV Grid implementation patterns and examples"
fi

if [ -f "$DOCS_DIR/Dynamic SELECT.md" ]; then
    add_front_matter "$DOCS_DIR/Dynamic SELECT.md" "Dynamic SELECT" "Dynamic Open SQL patterns and best practices"
fi

# Process all remaining .md files
find "$DOCS_DIR" -name "*.md" -type f | while read file; do
    filename=$(basename "$file" .md)
    
    # Skip if already processed
    if head -1 "$file" | grep -q "^---$"; then
        continue
    fi
    
    # Generate title and description
    title="$filename"
    description="ABAP development notes and examples for $filename"
    
    add_front_matter "$file" "$title" "$description"
done

echo "✅ Sync complete!"
echo ""
echo "🚀 Next steps:"
echo "1. Review changes: cd '$DOCS_DIR' && git diff"
echo "2. Commit changes: git add . && git commit -m 'Update ABAP documentation'"
echo "3. Deploy to GitHub: git push"
echo ""
echo "🌐 Your site will be available at: https://phanikumarvankadari.github.io"
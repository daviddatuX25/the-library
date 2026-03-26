#!/bin/bash
# bootstrap.sh — Full dev OS restore for any new machine
#
# Usage:
#   ./bootstrap.sh              # Full setup (CLAUDE.md + hooks)
#   ./bootstrap.sh --agents-only  # Regenerate CLAUDE.md only
#   ./bootstrap.sh --hooks-only   # Re-merge hooks only
#
# Prerequisites:
#   - Git (to have cloned this repo)
#   - Node.js (for hooks merge into settings.json)
#   - Claude Code (for MCP registration)

set -e

LIBRARY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
DATE=$(date +%Y-%m-%d)

echo ""
echo "╔══════════════════════════════════════╗"
echo "║     the-library bootstrap            ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Library: $LIBRARY_DIR"
echo "Target:  $CLAUDE_DIR"
echo ""

# ── 1. Ensure directories exist ──
mkdir -p "$CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/skills"

# ── 2. Verify the-library is in the right location ──
EXPECTED_PATH="$CLAUDE_DIR/skills/library"
if [ -L "$EXPECTED_PATH" ] || [ -d "$EXPECTED_PATH" ]; then
    REAL_LIB=$(realpath "$LIBRARY_DIR" 2>/dev/null || echo "$LIBRARY_DIR")
    REAL_EXP=$(realpath "$EXPECTED_PATH" 2>/dev/null || echo "$EXPECTED_PATH")
    if [ "$REAL_LIB" = "$REAL_EXP" ]; then
        echo "✓ the-library is at $EXPECTED_PATH"
    else
        echo "⚠  the-library exists at $EXPECTED_PATH but points elsewhere"
        echo "   Expected: $LIBRARY_DIR"
        echo "   Found:    $REAL_EXP"
        echo "   Re-linking..."
        rm -f "$EXPECTED_PATH"
        ln -sf "$LIBRARY_DIR" "$EXPECTED_PATH"
        echo "   ✓ Re-linked"
    fi
else
    ln -sf "$LIBRARY_DIR" "$EXPECTED_PATH"
    echo "✓ Symlinked the-library → $EXPECTED_PATH"
fi

# ── 3. Generate CLAUDE.md from rules/ via template ──
if [ "$1" != "--hooks-only" ]; then
    echo ""
    echo "── Generating CLAUDE.md ──"

    TEMPLATE_FILE="$LIBRARY_DIR/templates/claude.md.template"

    if [ ! -f "$TEMPLATE_FILE" ]; then
        echo "⚠  Template not found: $TEMPLATE_FILE"
        echo "   Skipping CLAUDE.md generation."
    else
        OUTPUT=$(cat "$TEMPLATE_FILE")

        # Replace {{DATE}}
        OUTPUT="${OUTPUT//\{\{DATE\}\}/$DATE}"

        # Replace {{INCLUDE rules/identity.md}}
        if [ -f "$LIBRARY_DIR/rules/identity.md" ]; then
            IDENTITY=$(cat "$LIBRARY_DIR/rules/identity.md")
            OUTPUT="${OUTPUT//\{\{INCLUDE rules\/identity.md\}\}/$IDENTITY}"
        else
            OUTPUT="${OUTPUT//\{\{INCLUDE rules\/identity.md\}\}/# (identity.md not found)}"
        fi

        # Replace {{INCLUDE rules/workflow.md}}
        if [ -f "$LIBRARY_DIR/rules/workflow.md" ]; then
            WORKFLOW=$(cat "$LIBRARY_DIR/rules/workflow.md")
            OUTPUT="${OUTPUT//\{\{INCLUDE rules\/workflow.md\}\}/$WORKFLOW}"
        else
            OUTPUT="${OUTPUT//\{\{INCLUDE rules\/workflow.md\}\}/# (workflow.md not found)}"
        fi

        # Replace {{INCLUDE rules/learning-debt-policy.md}}
        if [ -f "$LIBRARY_DIR/rules/learning-debt-policy.md" ]; then
            DEBT=$(cat "$LIBRARY_DIR/rules/learning-debt-policy.md")
            OUTPUT="${OUTPUT//\{\{INCLUDE rules\/learning-debt-policy.md\}\}/$DEBT}"
        else
            OUTPUT="${OUTPUT//\{\{INCLUDE rules\/learning-debt-policy.md\}\}/# (learning-debt-policy.md not found)}"
        fi

        echo "$OUTPUT" > "$CLAUDE_DIR/CLAUDE.md"
        echo "✓ Generated ~/.claude/CLAUDE.md"
    fi
fi

# ── 4. Merge hooks into settings.json ──
if [ "$1" != "--agents-only" ]; then
    echo ""
    echo "── Merging hooks ──"

    HOOKS_JSON="$LIBRARY_DIR/hooks/hooks.json"
    SETTINGS="$CLAUDE_DIR/settings.json"

    if [ ! -f "$HOOKS_JSON" ]; then
        echo "⚠  No hooks/hooks.json found. Skipping."
    else
        # Create settings.json if it doesn't exist
        if [ ! -f "$SETTINGS" ]; then
            echo '{}' > "$SETTINGS"
            echo "   Created empty settings.json"
        fi

        # Merge hooks into settings.json using Node.js
        if command -v node &>/dev/null; then
            node -e "
                const fs = require('fs');
                const settingsPath = '$SETTINGS';
                const hooksPath = '$HOOKS_JSON';
                try {
                    const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
                    const newHooks = JSON.parse(fs.readFileSync(hooksPath, 'utf8'));
                    // Merge: new hooks override existing hooks per event type
                    settings.hooks = { ...(settings.hooks || {}), ...newHooks };
                    fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
                    console.log('✓ Merged hooks into settings.json');
                } catch(e) {
                    console.error('✗ Error merging hooks:', e.message);
                    process.exit(1);
                }
            "
        else
            echo "⚠  Node.js not found. Cannot auto-merge hooks."
            echo "   Manually copy contents of hooks/hooks.json into"
            echo "   ~/.claude/settings.json under the 'hooks' key."
        fi
    fi

    # Make hook scripts executable
    chmod +x "$LIBRARY_DIR/hooks/"*.sh 2>/dev/null
    echo "✓ Hook scripts marked executable"
fi

# ── 5. Check Honcho MCP ──
echo ""
echo "── Checking Honcho MCP ──"
if command -v claude &>/dev/null; then
    if claude mcp list 2>/dev/null | grep -q honcho; then
        echo "✓ Honcho MCP registered"
    else
        echo "⚠  Honcho MCP not found."
        echo ""
        echo "   Register it with:"
        echo ""
        echo "   claude mcp add-json honcho '{"
        echo "     \"command\": \"npx\","
        echo "     \"args\": [\"mcp-remote\", \"https://mcp.honcho.dev\","
        echo "       \"--header\", \"Authorization:\${AUTH_HEADER}\","
        echo "       \"--header\", \"X-Honcho-User-Name:\${USER_NAME}\"],"
        echo "     \"env\": {"
        echo "       \"AUTH_HEADER\": \"Bearer YOUR_HONCHO_API_KEY\","
        echo "       \"USER_NAME\": \"your-name\""
        echo "     }"
        echo "   }' --scope user"
    fi
else
    echo "⚠  Claude Code CLI not found in PATH."
    echo "   Install Claude Code first, then re-run bootstrap."
fi

# ── 6. Check Superpowers ──
echo ""
echo "── Superpowers plugin ──"
echo "   If not installed yet, run in Claude Code:"
echo "   /plugin marketplace add obra/superpowers-marketplace"
echo "   /plugin install superpowers@superpowers-marketplace"

# ── 7. Summary ──
echo ""
echo "╔══════════════════════════════════════╗"
echo "║     Bootstrap complete               ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Check what was done
HAS_CLAUDE_MD="$([ -f "$CLAUDE_DIR/CLAUDE.md" ] && echo "✓" || echo " ")"
HAS_SETTINGS="$([ -f "$CLAUDE_DIR/settings.json" ] && echo "✓" || echo " ")"
HAS_LINK="$([ -L "$EXPECTED_PATH" ] || [ -d "$EXPECTED_PATH" ] && echo "✓" || echo " ")"

echo "  [$HAS_LINK] the-library linked"
echo "  [$HAS_CLAUDE_MD] CLAUDE.md generated"
echo "  [$HAS_SETTINGS] Hooks merged into settings.json"
echo "  [ ] Honcho API key configured (manual step)"
echo "  [ ] Superpowers installed (manual step)"
echo ""
echo "Quick commands:"
echo "  Update rules only:  ./scripts/bootstrap.sh --agents-only"
echo "  Update hooks only:  ./scripts/bootstrap.sh --hooks-only"
echo "  Full re-bootstrap:  ./scripts/bootstrap.sh"
echo ""
echo "First session checklist:"
echo "  1. Open Claude Code in any project"
echo "  2. Say: 'Check Honcho for my profile'"
echo "  3. If empty, seed it (see docs/setup.md in the-library)"
echo ""

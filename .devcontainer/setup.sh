#!/bin/bash
# TI-DE Codespaces kurulum scripti
# Her Codespace açıldığında otomatik çalışır

echo "🚀 TI-DE ortamı kuruluyor..."

# Claude hafızasını private repodan çek
MEMORY_DIR="$HOME/.claude/projects/$(pwd | sed 's|/|-|g' | sed 's|^-||')/memory"
mkdir -p "$MEMORY_DIR"

# CLAUDE_ENV_TOKEN secret varsa kullan, yoksa anonim dene
if [ -n "$CLAUDE_ENV_TOKEN" ]; then
  REPO_URL="https://${CLAUDE_ENV_TOKEN}@github.com/mazlumbaydar/claude-env.git"
else
  REPO_URL="https://github.com/mazlumbaydar/claude-env.git"
fi

if git ls-remote "$REPO_URL" &>/dev/null 2>&1; then
  git clone --depth=1 "$REPO_URL" /tmp/claude-env-pull
  cp /tmp/claude-env-pull/memory/*.md "$MEMORY_DIR/" 2>/dev/null || true
  rm -rf /tmp/claude-env-pull
  echo "✅ Claude hafızası yüklendi"
else
  echo "⚠️  claude-env reposuna erişilemiyor — CLAUDE_ENV_TOKEN secret'ı kontrol edin"
fi

echo "✅ TI-DE hazır! Claude Code ile çalışmaya başlayabilirsiniz."

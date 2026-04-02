#!/bin/bash
# TI-DE Codespaces kurulum scripti
# Her Codespace açıldığında otomatik çalışır

echo "🚀 TI-DE ortamı kuruluyor..."

# Claude hafızasını private repodan çek
MEMORY_DIR="$HOME/.claude/projects/$(pwd | sed 's|/|-|g' | sed 's|^-||')/memory"
mkdir -p "$MEMORY_DIR"

# claude-env private reposu varsa memory dosyalarını al
if git ls-remote "https://github.com/mazlumbaydar/claude-env.git" &>/dev/null 2>&1; then
  git clone --depth=1 "https://github.com/mazlumbaydar/claude-env.git" /tmp/claude-env-pull
  cp /tmp/claude-env-pull/memory/*.md "$MEMORY_DIR/" 2>/dev/null || true
  rm -rf /tmp/claude-env-pull
  echo "✅ Claude hafızası yüklendi"
else
  echo "⚠️  claude-env reposuna erişilemiyor — GitHub token gerekebilir"
fi

echo "✅ TI-DE hazır! Claude Code ile çalışmaya başlayabilirsiniz."

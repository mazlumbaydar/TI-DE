#!/bin/bash
# TI-DE Codespaces kurulum scripti
# Her Codespace açıldığında otomatik çalışır

echo "🚀 TI-DE ortamı kuruluyor..."

# Claude hafızasını private repodan çek
MEMORY_DIR="$HOME/.claude/projects/workspaces-TI-DE/memory"
mkdir -p "$MEMORY_DIR"

if [ -n "$CLAUDE_ENV_TOKEN" ]; then
  git clone --depth=1 \
    "https://${CLAUDE_ENV_TOKEN}@github.com/mazlumbaydar/claude-env.git" \
    /tmp/claude-env-pull 2>/dev/null
  if [ -d /tmp/claude-env-pull/memory ]; then
    cp /tmp/claude-env-pull/memory/*.md "$MEMORY_DIR/" 2>/dev/null || true
    echo "✅ Claude hafızası yüklendi"
  else
    echo "⚠️  clone başarısız — token veya repo kontrol edin"
  fi
  rm -rf /tmp/claude-env-pull
else
  echo "⚠️  CLAUDE_ENV_TOKEN secret bulunamadı"
fi

echo "✅ TI-DE hazır! Claude Code ile çalışmaya başlayabilirsiniz."

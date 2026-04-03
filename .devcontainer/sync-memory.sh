#!/bin/bash
# Memory'yi claude-env repo'ya geri yazar
# Claude Code Stop hook'u tarafından otomatik çağrılır

MEMORY_DIR="$HOME/.claude/projects/-workspaces-TI-DE/memory"
WORK_DIR="/tmp/claude-env-push"

if [ -z "$CLAUDE_ENV_TOKEN" ]; then
  echo "⚠️  CLAUDE_ENV_TOKEN bulunamadı — memory sync atlandı"
  exit 0
fi

if [ ! -d "$MEMORY_DIR" ] || [ -z "$(ls -A "$MEMORY_DIR" 2>/dev/null)" ]; then
  echo "⚠️  Memory klasörü boş veya yok — sync atlandı"
  exit 0
fi

rm -rf "$WORK_DIR"
git clone --depth=1 \
  "https://${CLAUDE_ENV_TOKEN}@github.com/mazlumbaydar/claude-env.git" \
  "$WORK_DIR" 2>/dev/null

if [ ! -d "$WORK_DIR" ]; then
  echo "⚠️  claude-env clone başarısız"
  exit 1
fi

mkdir -p "$WORK_DIR/memory"
cp "$MEMORY_DIR"/*.md "$WORK_DIR/memory/" 2>/dev/null || true

cd "$WORK_DIR"
git config user.email "claude@codespace"
git config user.name "Claude Code"

if git diff --quiet && git diff --staged --quiet; then
  echo "✅ Memory değişmemiş — push gerekmez"
else
  git add memory/
  git commit -m "memory: $(date '+%Y-%m-%d %H:%M') codespace sync"
  git push origin main 2>/dev/null \
    && echo "✅ Memory claude-env'e push edildi" \
    || echo "⚠️  Push başarısız"
fi

rm -rf "$WORK_DIR"

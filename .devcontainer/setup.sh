#!/bin/bash
# TI-DE Codespaces kurulum scripti
# Her Codespace açıldığında otomatik çalışır

echo "🚀 TI-DE ortamı kuruluyor..."

# Claude hafızasını private repodan çek
MEMORY_DIR="$HOME/.claude/projects/-workspaces-TI-DE/memory"
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

# Claude Skills kur
echo "📦 Claude Skills kuruluyor..."
SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

# awesome-claude-skills
if [ ! -d "$SKILLS_DIR/awesome-claude-skills" ]; then
  git clone --depth=1 \
    "https://github.com/anthropics/awesome-claude-skills.git" \
    "$SKILLS_DIR/awesome-claude-skills" 2>/dev/null \
    && echo "✅ awesome-claude-skills yüklendi" \
    || echo "⚠️  awesome-claude-skills yüklenemedi"
else
  echo "✅ awesome-claude-skills zaten mevcut"
fi

# Claude Code settings.json'a skills dizinini ekle
SETTINGS_DIR="$HOME/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"
mkdir -p "$SETTINGS_DIR"
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{
  "skillsDirectories": ["'"$SKILLS_DIR/awesome-claude-skills"'"]
}' > "$SETTINGS_FILE"
  echo "✅ Claude settings.json oluşturuldu"
fi

# Claude Code kuruluyor
echo "📦 Claude Code kuruluyor..."
npm install -g @anthropic-ai/claude-code 2>/dev/null && echo "✅ Claude Code kuruldu" || echo "⚠️  Claude Code kurulumu başarısız"

echo "✅ TI-DE hazır! Claude Code ile çalışmaya başlayabilirsiniz."

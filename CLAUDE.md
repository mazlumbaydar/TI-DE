# CLAUDE.md — TI-DE Projesi

Bu dosya Claude Code'un TI-DE projesiyle çalışırken uyması gereken kuralları içerir.

## Proje Hakkında

**TI-DE (Threat Intelligence & Detection Engineering)**
- Site: mazlumbaydar.github.io/TI-DE
- Repo: github.com/mazlumbaydar/TI-DE
- Sahip: Mazlum BAYDAR — Sr. Threat Intelligence and Detection Engineer

## Temel Çalışma Kuralları

### Git & Deploy
- Her iş bitiminde otomatik `git add + commit + push` yap
- Push = GitHub Pages otomatik deploy — ayrıca bir işlem gerekmez
- Commit mesajı açıklayıcı olsun, Türkçe veya İngilizce

### İletişim
- Her iş bitiminde hem **TR hem EN** özet ver
- Toplu isteklerde önce plan sun, onay geldikten sonra uygula
- Plan onaylanmadan kod yazma

### Detection Rules — Kural Altın Standartları
1. **Community-first:** Sigma, YARA, EQL, KQL yazmadan önce SigmaHQ → Elastic → bireysel araştırmacılar → bloglar → internet sırasıyla ara
2. **TTP-only:** IP, domain, hash, URL bazlı IOC kuralları YASAK — sadece davranışsal (behavioral) kurallar
3. **Attribution:** Bulunan kural kaynak gösterilerek eklenir (`# Source: [Yazar] — github.com/[repo]`)
4. **Bulunamazsa:** Sıfırdan TI-DE yazar, raporda "TI-DE authored" belirtilir

### Rapor Yapısı (Her Yeni Rapor İçin Standart)
- Detection tabs: Sigma, KQL, EQL, SPL, YARA, XQL, IOA, Threat Hunting
- Video embedding: PoC/demo videosu varsa inline oynatma (yeni sekme yok)
- İki dil desteği: TR/EN toggle
- Copy button tüm rule card'larda zorunlu
- Rule card toggle bug fix uygulanmış olmalı (copyCode stopPropagation)

### Maskot & Tasarım
- Maskot: sadece 3D büyüteç mercek — insan yok
- Animasyonlar: sağa/sola float (6s), ekrana doğru zoom (10s, 2 kez), zoom pikinde göz kırpma (üst+alt kapak)
- Göz bebeği float ile senkron sola/sağa kayar, zoom'da dilatasyon

## Tamamlanan Fazlar
- ✅ Faz -1: GitHub repo + Codespaces devcontainer + memory altyapısı
- ✅ Faz 0: Maskot — sadece 3D büyüteç, insan kaldırıldı
- ✅ Faz 0b: LinkedIn banner maskot + font düzeltmesi
- ✅ Faz 1: IOC kural temizliği — 4 raporda IP/domain/hash bazlı kurallar kaldırıldı
- ✅ Faz 2: litellm-sc kural düzeltme + QRadar behavioral kural eklendi (10 platform)
- ✅ Faz 3: Community kural araştırması — SigmaHQ + Elastic, +8 kural (4 rapor)
- ✅ Faz 4: Video embed CSS altyapısı hazırlandı
- ✅ Faz 5: Maskot göz kırpma — zoom pikinde üst+alt kapak animasyonu

## Memory Konumu
Memory dosyaları: `github.com/mazlumbaydar/claude-env/memory/`
Codespace açılınca setup.sh otomatik çeker.

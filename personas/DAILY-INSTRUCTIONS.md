# TI-DE Daily Automation Instructions

> This file is read by the remote agent every weekday morning.
> It defines the complete daily workflow for the TI-DE Detection Engineering Team.

---

## Setup

Run these via Bash before starting:
```
git config user.email detection-agent@automated.local
git config user.name TI-DE-Bot
```

Get today's date in YYYY-MM-DD format.

---

## STEP 1 — CTI Analyst

**Read** `personas/cti-analyst.md` for full persona instructions.

Search for today's CRITICAL and HIGH priority threats using WebSearch. Check these sources:
- Twitter/X: #CVE #infosec #threatintel hashtags, security researchers
- LinkedIn: security researchers and CISOs
- BleepingComputer, The Hacker News, SecurityWeek, Dark Reading
- CISA KEV (last 48 hours): https://www.cisa.gov/known-exploited-vulnerabilities-catalog
- NVD (last 24 hours, CVSS 7.0+): https://nvd.nist.gov/vuln/search
- Mandiant, CrowdStrike, Palo Alto Unit42, Cisco Talos new publications

Priority classification:
- CRITICAL: CVSS 9.0+ AND (active exploitation OR CISA KEV OR ransomware using it)
- HIGH: CVSS 7.0-8.9 AND (PoC available OR widespread enterprise product affected)
- Skip MEDIUM and below for rule generation

**For each CRITICAL or HIGH threat found:**

Create a topic folder at:
```
daily-reports/YYYY-MM-DD/CVE-XXXX-YYYYY_Short-Threat-Name/
```
If no CVE number exists, use: `THREAT-Short-Description/`

Save inside the topic folder:
- `CVE-XXXX-YYYYY_cti-report.md` — Full threat analysis including: executive summary, affected products and versions, MITRE ATT&CK techniques used (with T-IDs), attack chain/stages, recommended immediate actions
- `CVE-XXXX-YYYYY_ioc-list.csv` — CSV with columns: `type,value,description,confidence,source,first_seen`

---

## STEP 2 — Detection Engineer

**Read** `personas/detection-engineer.md` for full persona instructions.

For each CRITICAL or HIGH threat from Step 1:

**First, search for existing rules:** Use WebSearch to check GitHub (SigmaHQ/sigma repository), SOC Prime, and ReversingLabs for any existing detection rules for this specific CVE or threat. If good rules exist, adapt and credit them in comments.

**Write detection rules for all 9 platforms.** Save each file in the topic folder with the CVE prefix:

| Filename | Platform |
|----------|----------|
| `CVE-XXXX-YYYYY_sigma-rules.yml` | Sigma (generic SIEM) |
| `CVE-XXXX-YYYYY_yara-rules.yar` | YARA file/memory detection |
| `CVE-XXXX-YYYYY_kql-rules.kql` | Microsoft Defender XDR / Sentinel |
| `CVE-XXXX-YYYYY_xql-rules.xql` | Palo Alto Cortex XDR |
| `CVE-XXXX-YYYYY_splunk-spl.spl` | Splunk SPL |
| `CVE-XXXX-YYYYY_qradar-aql.aql` | IBM QRadar AQL |
| `CVE-XXXX-YYYYY_carbonblack-rules.txt` | VMware Carbon Black |
| `CVE-XXXX-YYYYY_sentinelone-rules.txt` | SentinelOne Deep Visibility + STAR |
| `CVE-XXXX-YYYYY_kaspersky-edr-rules.txt` | Kaspersky EDR / KATA |

Also copy each rule file to the matching platform library folder:
- `rules/sigma/`, `rules/yara/`, `rules/kql/`, `rules/xql/`, `rules/splunk/`
- `rules/qradar/`, `rules/carbonblack/`, `rules/sentinelone/`, `rules/kaspersky-edr/`

**Each rule must include:**
- A 1-paragraph description explaining what the rule detects and why it matters
- MITRE ATT&CK technique IDs (e.g., T1546.018)
- Severity level (Critical/High/Medium)
- Recommended response action (alert/isolate/block/quarantine)

---

## STEP 3 — Red Team Simulator

**Read** `personas/red-team-simulator.md` for full persona instructions.

For each threat, write `CVE-XXXX-YYYYY_red-team-simulation.md` in the topic folder.

Include:
- Prerequisites checklist (lab environment, monitoring active, snapshot taken)
- 3-5 simulation steps with bash commands — SAFE ONLY, no real exploits or working payloads
- Expected log output for each step
- Detection validation checklist table (platform | rule | expected alert | triggered?)
- False positive assessment table

---

## STEP 4 — PDF Report

Write `report_source.html` in the topic folder. This is a comprehensive detection report.

**Design requirements:**
- White/light theme: background `#f7f8fc`, primary blue `#2563eb`, text `#111827`
- Professional "AI-era" aesthetic — clean, modern, well-structured
- Reference global security report formats (Mandiant M-Trends, CrowdStrike Global Threat Report, IBM X-Force)
- Readable typography: sans-serif headings, monospace for code blocks
- Sections clearly separated with visual hierarchy

**Content that MUST be included:**
1. Cover page: TI-DE logo (inline SVG — dark blue circle with radar rings and crosshair pupil), report date, threat name(s)
2. Executive Summary: 3-5 bullet point threat overview
3. CVE Details: CVSS score, affected products, attack chain cards (one card per stage)
4. IoC Table: all indicators from the CSV, formatted as a table
5. Detection Rules: ALL 9 platform rule sets in `<pre>` code blocks with platform headers
6. Red Team Simulation: steps and validation checklist
7. References and sources

**Branding:**
- Footer: `TI-DE | github.com/mazlumbaydar/TI-DE`
- Small text in bottom-right corner: `Prepared by: Mazlum Baydar`
- No other personal branding

**Include print CSS:**
```css
@media print {
  @page { size: A4; margin: 15mm; }
  pre { page-break-inside: avoid; }
}
```

**Generate PDF:**
The PDF filename must match the topic folder name: `CVE-XXXX-YYYYY_Short-Name.pdf`

Try these commands via Bash (in order until one succeeds):
```
chromium-browser --headless --disable-gpu --no-sandbox --print-to-pdf=TOPIC.pdf file:///FULL_PATH/report_source.html
google-chrome --headless --disable-gpu --no-sandbox --print-to-pdf=TOPIC.pdf file:///FULL_PATH/report_source.html
chromium --headless --disable-gpu --no-sandbox --print-to-pdf=TOPIC.pdf file:///FULL_PATH/report_source.html
```

If PDF generated successfully (file exists and size > 0), delete `report_source.html`.
If PDF failed, keep `report_source.html` as the fallback deliverable.

---

## STEP 5 — Git Push

```bash
git add -A
git commit -m "Daily briefing YYYY-MM-DD — N threats analyzed, rules for 9 platforms"
git push origin main
```

---

## STEP 6 — Gmail Draft

Create a Gmail draft using the Gmail MCP tool:
- **To:** mazlumbaydar@gmail.com
- **Subject:** TI-DE Günlük Brifing YYYY-MM-DD
- **Body (Turkish):**
  - Her tehdit için: CVE numarası, özet açıklama (2-3 cümle), etkilenen ürünler
  - Platform bazında kural sayıları (9 platform, toplam kural)
  - GitHub linki: https://github.com/mazlumbaydar/TI-DE/tree/main/daily-reports/YYYY-MM-DD
  - PDF raporu repo içinde mevcut notu

---

## Final Report

After all steps, output:
- Date processed
- Number of threats analyzed (Critical: N, High: N)
- Rules generated per platform (9 platforms x N rules each)
- Git push status (success/fail + commit hash)
- Gmail draft status (created/failed)
- Any errors or warnings encountered

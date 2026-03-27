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
- `CVE-XXXX-YYYYY_ioc-list.csv` — CSV with columns: `type,value,description,confidence,source,first_seen,source_url`
  - `source_url` is the direct URL to the article/report/advisory where this IOC was published

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

## Platform Syntax Reference (Verified from Official Documentation)

### Sigma (YAML)
- Field names use **Sigma taxonomy**, NOT raw Windows Event Log fields: `Image` (not ProcessName), `CommandLine`, `ParentImage`, `TargetFilename`, `DestinationIp`, `QueryName`
- Operators use pipe syntax: `field|contains:`, `field|startswith:`, `field|endswith:`, `field|re:` (regex, case-sensitive, use `(?i)` for insensitive)
- Multi-value: `field|contains:` under a list → OR logic. `field|contains|all:` → AND logic
- Condition keywords: `1 of selection_*` (any), `all of selection_*` (all), `not filter`
- Status progression: `experimental` → `test` → `stable`
- Logsource categories: `process_creation`, `file_event`, `network_connection`, `dns_query`, `registry_event`, `image_load`
- Products: `windows`, `linux`, `macos`

### YARA
- String types: `"ascii string"`, `{ 4D 5A hex bytes }`, `/regex/i` (with flags)
- Modifiers (append after string): `nocase`, `wide`, `ascii`, `xor`, `base64`, `fullword`, `private`
- Condition keywords: `any of them`, `all of them`, `2 of ($prefix*)`, `#$str >= 3`, `$str at 0` (offset), `$str in (0..512)` (range)
- Modules: `import "pe"` → `pe.is_pe`, `pe.number_of_sections`; `import "math"` → `math.entropy(0, filesize)`
- Regex uses PCRE-like syntax; NOT anchored by default

### KQL (Defender XDR / Sentinel)
- Main tables: `DeviceProcessEvents`, `DeviceFileEvents`, `DeviceNetworkEvents`, `DeviceRegistryEvents`, `DeviceImageLoadEvents`
- Field names: `FileName`, `FolderPath`, `ProcessCommandLine`, `InitiatingProcessFileName`, `InitiatingProcessCommandLine`, `RemoteIP`, `RemoteUrl`, `RemotePort`, `SHA1`, `MD5`
- Operators: `has` (word match, insensitive), `contains` (substring, insensitive), `has_any(list)`, `in~(list)` (insensitive), `startswith`, `endswith`, `matches regex` (sensitive)
- Time: `where TimeGenerated > ago(7d)` | `between (ago(30d) .. now())`
- Aggregation: `summarize count() by DeviceName` | `dcount(DeviceName)`
- Variables: `let suspProcs = DeviceProcessEvents | where ...;`

### XQL (Cortex XDR)
- Pipeline stages: `dataset = xdr_data | filter ... | fields ... | sort desc ... | limit N`
- Event type constants (UPPERCASE ENUM): `event_type = ENUM.PROCESS`, `event_sub_type = ENUM.PROCESS_START`, `ENUM.FILE`, `ENUM.FILE_CREATE_NEW`, `ENUM.NETWORK`
- Actor fields: `actor_process_image_name`, `actor_process_command_line`, `actor_process_image_path`, `actor_primary_username`
- Action fields: `action_file_name`, `action_file_path`, `action_process_image_name`, `action_process_command_line`
- Network fields: `dst_ip`, `dst_host`, `dst_port`, `src_ip`, `protocol`
- Regex: `regextract(field, "(?P<name>pattern)")` — RE2 engine, no backreferences
- `alter newfield = strlen(field)` to compute derived fields

### Splunk SPL
- Source: `index=windows sourcetype=xmlwineventlog:microsoft-windows-sysmon/operational EventCode=1`
- Sysmon EventCodes: 1=Process Create, 3=Network Connect, 11=FileCreate, 22=DNS Query
- Raw Sysmon fields: `Image`, `CommandLine`, `ParentImage`, `TargetFilename`, `DestinationIp`, `DestinationPort`, `QueryName`
- CIM fields (after rename): `process`, `process_command_line`, `parent_process`, `file_path`, `dest_ip`, `dest_port`
- Core commands: `stats count by field`, `eval newfield=len(field)`, `rex field=X "(?<name>pattern)"`, `where X like "%value%"`
- Time: `earliest=-7d latest=now` | `where _time >= relative_time(now(),"-7d")`
- Regex: PCRE via `rex`/`regex`; use `(?i)` for case-insensitive

### QRadar AQL
- Syntax: SQL-like `SELECT ... FROM events WHERE ... GROUP BY ... HAVING ... ORDER BY ... LIMIT N`
- Case handling: `LIKE '%pattern%'` (case-sensitive, `%` wildcard), `ILIKE '%pattern%'` (insensitive), `MATCHES "regex"` (sensitive), `IMATCHES "regex"` (insensitive)
- Escape dots in regex: `IMATCHES ".*\.exe"` not `".*exe"`
- Useful functions: `QIDNAME(qid)`, `CATEGORYNAME(category)`, `LOGSOURCENAME(logsourceid)`, `DATEFORMAT(devicetime, 'yyyy-MM-dd HH:mm:ss')`
- Time: `WHERE devicetime > CURRENT_TIMESTAMP - 7 DAYS`
- Common fields: `sourceIP`, `destinationIP`, `sourcePort`, `destinationPort`, `username`, `"Message"` (full event text)

### Carbon Black CBC
- Lucene-based syntax: `field:value` with implicit AND
- **All indexed text is lowercase** — regex must be lowercase: `cmdline:/powershell/` not `cmdline:/PowerShell/`
- **Paths use forward slashes**: `c:/windows/system32` (not backslash)
- Wildcard `*` only in single terms, NOT inside quoted phrases
- Range: `netconn_count:[10 TO *]` (not `>=10`)
- Key fields: `process_name`, `cmdline`, `parent_name`, `filemod_name`, `netconn_ipv4`, `netconn_domain`, `netconn_port`, `regmod_name`, `modload_name`, `username`
- NOT: `-field:value` or `NOT field:value`

### SentinelOne Deep Visibility (v2 Enhanced)
- **Dot notation required**: `TgtFile.Path` (NOT legacy `TgtFilePath`)
- EventType strings: `"Process Creation"`, `"File Creation"`, `"File Modification"`, `"DNS Request"`, `"IP Connect"`, `"Module Load"`, `"Registry Key Modification"`
- Operators: `Contains` (case-**insensitive**), `ContainsCIS` (explicit insensitive), `StartsWith` (case-**sensitive**), `EndsWith` (case-**sensitive**), `In` (sensitive), `In Contains` (insensitive list), `Regexp` (sensitive regex)
- Target fields: `TgtProcName`, `TgtProcCmdLine`, `TgtFile.Name`, `TgtFile.Path`, `TgtFile.Extension`, `TgtRegistry.Path`, `TgtRegistry.ValueData`
- Source fields: `SrcProcName`, `SrcProcCmdLine`
- Network: `Dst.IP`, `Dst.Port`, `DnsRequest.Name`, `DnsRequest.Type`
- No aggregation in query; no time functions — use UI time picker

### Kaspersky KEDR Expert / KATA
- **ALL operators UPPERCASE**: `CONTAINS`, `STARTS_WITH`, `ENDS_WITH`, `IN`, `MATCHES`, `AND`, `OR`, `NOT`
- **Dot notation**: `Process.Name`, `Process.CommandLine`, `Process.ParentName`, `Process.MD5`, `File.Path`, `File.Name`, `File.Size`, `Network.DestinationIP`, `Network.DestinationHost`, `Network.DestinationPort`, `Registry.KeyName`, `Registry.ValueData`
- `CONTAINS`, `STARTS_WITH`, `ENDS_WITH`, `IN` are case-**insensitive**
- `MATCHES` uses full PCRE regex (case-**sensitive**)
- String values in double quotes; numeric values without quotes
- **Do NOT use TAA reserved fields**: `IOATechnique`, `IOATactics`, `IOAImportance`, `IOAConfidence`
- Parentheses required for complex boolean logic: `(A OR B) AND C`

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

// ============================================================
// Threat  : Axios npm Supply Chain — Cross-Platform RAT Dropper
// Platform: Palo Alto Cortex XDR
// Format  : BIOC-compatible XQL (add via Incident Response > BIOC)
// TTPs    : T1195.001 / T1059.001 / T1059.004 / T1059.006 / T1036.005 / T1070.004
// Severity: Critical
// Dataset : xdr_data (only dataset supported by BIOC rules)
//
// BIOC vs XQL:
//   XQL  = retrospective hunting in Cortex Data Lake (multi-dataset joins OK)
//   BIOC = real-time sensor-level detection; limited to xdr_data; one event_type
//          per rule; no join/union; single filter chain.
//
// BIOC Rule fields (set in UI when importing):
//   Name, Description, Severity, MITRE Tactic/Technique, Status=ENABLED
//   investigationType = PROCESS / FILE (matches event_type below)
// ============================================================

// ══════════════════════════════════════════════════════════════
// BIOC-1: npm/node Spawning Network or Scripting Tool
// ──────────────────────────────────────────────────────────────
// Detects: npm/node parent executing network fetch utility or Windows scripting
//          engine as a child — the postinstall hook execution vector.
//
// Consolidated: covers both Linux (curl/wget/python3/bash) and
//               Windows (wscript/powershell) in a single BIOC rule.
//
// Behavioral logic: parent must be npm or node AND child must be a
//   network or scripting tool. No specific file/path names hardcoded —
//   attacker cannot evade by renaming the child process.
//
// BIOC UI settings:
//   investigationType: PROCESS
//   Severity: SEV_040_HIGH
//   Tactic: TA0001 (Initial Access) / Technique: T1195.001
// ══════════════════════════════════════════════════════════════
dataset = xdr_data
| filter event_type = ENUM.PROCESS
     and event_sub_type = ENUM.PROCESS_START
     and (actor_process_image_name in ("node", "npm", "node.exe", "npm-cli.js")
          or actor_process_image_path ~= "[\\/](node|npm)(\.exe)?$")
     and action_process_image_name in (
           "curl", "wget", "python3", "python", "bash", "sh", "nc", "ncat",
           "wscript.exe", "cscript.exe", "powershell.exe", "pwsh.exe"
     )
| fields _time, agent_hostname, actor_username,
         actor_process_image_name, actor_process_image_path,
         actor_process_command_line,
         action_process_image_name, action_process_command_line


// ══════════════════════════════════════════════════════════════
// BIOC-2: Node or Scripting Engine Dropping Executable/Script to Staging Path
// ──────────────────────────────────────────────────────────────
// Detects: node.exe, wscript.exe, or powershell.exe writing an executable (.exe)
//          to C:\ProgramData\ (Windows) OR a script (.py/.sh) to /tmp/ (Linux).
//
// Behavioral focus: writer process identity + destination path pattern.
//   We do NOT match specific filenames (e.g., wt.exe, ld.py) — attacker can
//   rename freely. The suspicious signal is the COMBINATION of the writing process
//   and the staging directory, which together are not a normal operation.
//
// BIOC UI settings:
//   investigationType: FILE
//   Severity: SEV_040_HIGH
//   Tactic: TA0005 (Defense Evasion) / Technique: T1036.005
// ══════════════════════════════════════════════════════════════
dataset = xdr_data
| filter event_type = ENUM.FILE
     and event_sub_type = ENUM.FILE_CREATE_NEW
     and actor_process_image_name in ("node", "node.exe", "wscript.exe",
                                       "powershell.exe", "pwsh.exe")
     and (
           (action_file_path ~= "(?i)^c:\\programdata\\" and action_file_name ~= "(?i)\.exe$")
        or (action_file_path ~= "^/tmp/"                 and action_file_name ~= "\.(py|sh)$")
        or (action_file_path ~= "^/Library/Caches/"      and action_file_name ~= "^com\\.apple\\.")
     )
| fields _time, agent_hostname, actor_username,
         actor_process_image_name, actor_process_command_line,
         action_file_path, action_file_name

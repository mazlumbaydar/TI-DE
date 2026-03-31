// ============================================================
// Threat  : Axios npm Supply Chain — Cross-Platform RAT Dropper
// Platform: Palo Alto Cortex XDR (XQL)
// TTPs    : T1195.001 / T1059.001 / T1059.004 / T1059.006 / T1036.005
// Severity: Critical
// Dataset : xdr_data
// Note    : actor_process = parent, action_process = spawned child
// ============================================================

// ── RULE 1: NPM/Node Spawning Network Tool (Linux) ──
// Actor (parent) = npm/node running postinstall hook
// Action (child) = curl/wget/python3 doing network retrieval
// Two conditions required: parent identity AND child identity.
dataset = xdr_data
| filter event_type = ENUM.PROCESS and event_sub_type = ENUM.PROCESS_START
| filter actor_process_image_name in ("node", "npm", "npm-cli.js")
     and actor_process_command_line contains "node_modules"
| filter action_process_image_name in ("curl", "wget", "python3", "python", "bash", "sh", "nc", "ncat")
| fields _time, agent_hostname, actor_username,
         actor_process_image_name, actor_process_command_line,
         action_process_image_name, action_process_command_line

// ── RULE 2: Node.exe Spawning Windows Scripting Engine ──
// Windows vector: node.exe → wscript.exe or powershell.exe
// Requires BOTH parent being node AND child being a scripting engine.
dataset = xdr_data
| filter event_type = ENUM.PROCESS and event_sub_type = ENUM.PROCESS_START
| filter actor_process_image_name ~= "(?i)node\.exe"
     and actor_process_command_line ~= "(?i)(postinstall|setup\.js)"
| filter action_process_image_name ~= "(?i)(wscript|cscript|powershell|pwsh)\.exe"
| fields _time, agent_hostname, actor_username,
         actor_process_command_line, action_process_image_name,
         action_process_command_line

// ── RULE 3: Executable Written to ProgramData by Node/Script Engine ──
// Detects wt.exe masquerade: node or scripting engine writing an .exe
// to C:\ProgramData\ (T1036.005). Requires writer process + file path.
dataset = xdr_data
| filter event_type = ENUM.FILE and event_sub_type = ENUM.FILE_CREATE_NEW
| filter actor_process_image_name ~= "(?i)(node|wscript|powershell|pwsh)\.exe"
| filter action_file_path ~= "(?i)c:\\programdata\\"
     and action_file_name ~= "(?i)\.exe$"
| fields _time, agent_hostname, actor_username,
         actor_process_image_name, actor_process_command_line,
         action_file_path, action_file_name

// ── RULE 4: Python File Created in /tmp by Node Process (Linux) ──
// Linux vector: node drops /tmp/ld.py — detects by writer process (node)
// AND destination pattern (/tmp/ + .py extension). Requires BOTH conditions.
dataset = xdr_data
| filter event_type = ENUM.FILE and event_sub_type = ENUM.FILE_CREATE_NEW
| filter actor_process_image_name = "node"
| filter action_file_path ~= "^/tmp/"
     and action_file_name ~= "\.py$"
| fields _time, agent_hostname, actor_username,
         actor_process_image_name, action_file_path, action_file_name

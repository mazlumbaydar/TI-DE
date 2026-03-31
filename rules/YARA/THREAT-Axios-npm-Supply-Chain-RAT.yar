/*
 * Threat  : Axios npm Supply Chain — Cross-Platform RAT Dropper
 * Platform: YARA
 * TTPs    : T1140 (Deobfuscation), T1027 (Obfuscation), T1195.001
 * Severity: Critical
 * Response: Quarantine file, audit npm dependency tree
 *
 * Rules target the dropper script (setup.js in plain-crypto-js) and
 * the obfuscation artefacts unique to this campaign. NOT IOC-based —
 * the XOR key and index formula are behavioural signatures of the
 * dropper logic, not network indicators.
 */

// ── RULE 1: Dropper XOR Obfuscation Key ──
// The dropper setup.js uses a unique XOR key "OrDeR_7077" with a
// modular index formula. This string does not appear in any legitimate
// npm package and is distinctive to this dropper family (T1140).
rule Axios_npm_RAT_Dropper_XOR_Key
{
    meta:
        description     = "Detects the XOR obfuscation key from the Axios npm supply chain RAT dropper (plain-crypto-js postinstall setup.js)"
        author          = "TI-DE Detection Engineering"
        date            = "2026-03-31"
        severity        = "critical"
        mitre_attack    = "T1140, T1027, T1195.001"
        reference       = "https://www.stepsecurity.io/blog/axios-compromised-on-npm-malicious-versions-drop-remote-access-trojan"

    strings:
        $xor_key        = "OrDeR_7077" ascii nocase
        $index_formula  = "7 * r * r % 10" ascii wide
        $index_alt      = "7*r*r%10" ascii
        $xor_const      = "^ a ^ 333" ascii
        $xor_const_alt  = "^a^333" ascii

    condition:
        $xor_key and (1 of ($index_formula, $index_alt)) and (1 of ($xor_const, $xor_const_alt))
}


// ── RULE 2: Malicious npm Postinstall Dropper Pattern ──
// Detects a JavaScript file in a node_modules context that combines:
// - A postinstall reference
// - An os.platform() call (OS fingerprinting, T1057)
// - A network request function
// This combination is the structural fingerprint of the dropper.
rule Axios_npm_RAT_Postinstall_Dropper_Structure
{
    meta:
        description     = "Detects a malicious npm postinstall dropper combining OS detection and network callback — structural signature of the Axios RAT dropper family"
        author          = "TI-DE Detection Engineering"
        date            = "2026-03-31"
        severity        = "critical"
        mitre_attack    = "T1195.001, T1059.006, T1071.001"

    strings:
        $postinstall    = "postinstall" ascii
        $os_platform    = "os.platform()" ascii
        $http_request   = "http.request" ascii
        $https_request  = "https.request" ascii
        $fs_unlink      = "fs.unlink" ascii          // evidence destruction
        $fs_rename      = "fs.rename" ascii          // package.json replacement

    condition:
        $postinstall and $os_platform
        and (1 of ($http_request, $https_request))
        and (1 of ($fs_unlink, $fs_rename))
}


// ── RULE 3: macOS RAT Binary Masquerade Path ──
// The macOS payload is written to /Library/Caches/ with a name
// beginning with "com.apple." — mimicking Apple daemon naming (T1036.005).
// Detect any ELF/Mach-O binary landing in that path pattern.
rule Axios_npm_RAT_macOS_Masquerade_Binary
{
    meta:
        description     = "Detects a Mach-O binary in /Library/Caches/ with Apple daemon naming convention, indicative of the Axios npm RAT macOS persistence artefact"
        author          = "TI-DE Detection Engineering"
        date            = "2026-03-31"
        severity        = "high"
        mitre_attack    = "T1036.005"

    strings:
        $macho_magic_64 = { CF FA ED FE }       // Mach-O 64-bit LE
        $macho_magic_32 = { CE FA ED FE }       // Mach-O 32-bit LE
        $path_caches    = "/Library/Caches/com.apple." ascii nocase
        $beacon_ua      = "mozilla/4.0 (compatible; msie 8.0; windows nt 5.1" ascii nocase

    condition:
        (1 of ($macho_magic_64, $macho_magic_32)) at 0
        and (1 of ($path_caches, $beacon_ua))
}

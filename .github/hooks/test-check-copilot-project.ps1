$ErrorActionPreference = "Stop"

$sourceDirectory = $PSScriptRoot
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("copilot-hook-" + [guid]::NewGuid())
$hookDirectory = Join-Path $tempRoot ".github/hooks"
$configDirectory = Join-Path $tempRoot ".github/copilot"
$configPath = Join-Path $configDirectory "project.json"

New-Item -ItemType Directory -Path $hookDirectory, $configDirectory -Force | Out-Null
Copy-Item (Join-Path $sourceDirectory "check-copilot-project.ps1") $hookDirectory
Copy-Item (Join-Path $sourceDirectory "check-copilot-project.sh") $hookDirectory
Set-Content (Join-Path $configDirectory "issue-tracker.md") "# Issue Tracker"
Set-Content (Join-Path $configDirectory "git-server.md") "# Git Server"

$cases = @(
    @{
        Name = "missing manifest"
        Expected = "absent"
        Json = $null
    },
    @{
        Name = "valid unconfigured"
        Expected = "remain unconfigured"
        Json = '{"schemaVersion":1,"capabilities":{"issueTracker":{"status":"unconfigured","instructions":".github/copilot/issue-tracker.md"},"gitServer":{"status":"disabled","instructions":".github/copilot/git-server.md"},"grilling":{"status":"enabled","customization":"grill-me-on"},"conciseStyle":{"status":"disabled","customization":null}}}'
    },
    @{
        Name = "valid enabled integrations"
        Expected = '^\{\}$'
        Json = '{"schemaVersion":1,"capabilities":{"issueTracker":{"status":"enabled","instructions":".github/copilot/issue-tracker.md"},"gitServer":{"status":"enabled","instructions":".github/copilot/git-server.md"},"grilling":{"status":"enabled","customization":"grill-me-on"},"conciseStyle":{"status":"disabled","customization":null}}}'
    },
    @{
        Name = "malformed JSON"
        Expected = "invalid"
        Json = '{'
    },
    @{
        Name = "string schema version"
        Expected = "invalid"
        Json = '{"schemaVersion":"1","capabilities":{}}'
    },
    @{
        Name = "wrong-case status"
        Expected = "invalid"
        Json = '{"schemaVersion":1,"capabilities":{"issueTracker":{"status":"ENABLED","instructions":"."},"gitServer":{"status":"disabled"},"grilling":{"status":"enabled","customization":"grill-me-on"},"conciseStyle":{"status":"disabled"}}}'
    },
    @{
        Name = "wrong metadata types"
        Expected = "invalid"
        Json = '{"schemaVersion":1,"capabilities":{"issueTracker":{"status":"enabled","instructions":42},"gitServer":{"status":"disabled"},"grilling":{"status":"enabled","customization":["grill-me-on"]},"conciseStyle":{"status":"disabled"}}}'
    },
    @{
        Name = "missing instruction file"
        Expected = "invalid"
        Json = '{"schemaVersion":1,"capabilities":{"issueTracker":{"status":"enabled","instructions":".github/copilot/missing.md"},"gitServer":{"status":"disabled"},"grilling":{"status":"enabled","customization":"grill-me-on"},"conciseStyle":{"status":"disabled"}}}'
    },
    @{
        Name = "unknown malformed capability"
        Expected = "invalid"
        Json = '{"schemaVersion":1,"capabilities":{"issueTracker":{"status":"disabled"},"gitServer":{"status":"disabled"},"grilling":{"status":"enabled","customization":"grill-me-on"},"conciseStyle":{"status":"disabled"},"unknown":{}}}'
    }
)

function Invoke-Matrix([string] $runner) {
    foreach ($case in $cases) {
        if ($null -eq $case.Json) {
            Remove-Item $configPath -Force -ErrorAction SilentlyContinue
        } else {
            Set-Content -Path $configPath -Value $case.Json -NoNewline
        }
        Push-Location $tempRoot
        try {
            if ($runner -eq "PowerShell") {
                $output = & (Join-Path $hookDirectory "check-copilot-project.ps1")
            } elseif ($runner -eq "Windows PowerShell") {
                $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $hookDirectory "check-copilot-project.ps1")
            } else {
                $previousOptimize = $env:PYTHONOPTIMIZE
                $env:PYTHONOPTIMIZE = "1"
                try {
                    $output = & sh (Join-Path $hookDirectory "check-copilot-project.sh")
                } finally {
                    $env:PYTHONOPTIMIZE = $previousOptimize
                }
            }
        } finally {
            Pop-Location
        }

        if ($output -notmatch $case.Expected) {
            throw "$runner accepted '$($case.Name)' unexpectedly: $output"
        }
    }
}

try {
    Invoke-Matrix "PowerShell"
    if (Get-Command powershell.exe -ErrorAction SilentlyContinue) {
        Invoke-Matrix "Windows PowerShell"
    }
    if (Get-Command sh -ErrorAction SilentlyContinue) {
        Invoke-Matrix "POSIX"
    } else {
        Write-Warning "POSIX hook tests skipped because sh is unavailable."
    }
    Write-Output "Hook validation matrix passed."
} finally {
    Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
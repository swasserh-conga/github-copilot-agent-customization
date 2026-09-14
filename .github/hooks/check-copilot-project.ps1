Set-StrictMode -Version Latest

$configPath = Join-Path $PSScriptRoot "..\copilot\project.json"

function Write-HookMessage([string] $message) {
    @{ systemMessage = $message } | ConvertTo-Json -Compress
}

function Get-PropertyValue($object, [string] $name) {
    if ($null -eq $object -or $object -isnot [PSCustomObject]) {
        return $null
    }

    $property = $object.PSObject.Properties[$name]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

if (-not (Test-Path $configPath)) {
    Write-HookMessage "Copilot project configuration is absent. Do not interrupt unrelated work. Before using a configurable capability, run the setup-copilot-project skill in the main agent before delegation."
    exit 0
}

try {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
} catch {
    Write-HookMessage "Copilot project configuration is invalid JSON. Do not interrupt unrelated work. Before using a configurable capability, run setup-copilot-project in the main agent to repair it."
    exit 0
}

$requiredCapabilities = @("issueTracker", "gitServer", "grilling", "conciseStyle")
$allowedStatuses = @("unconfigured", "enabled", "disabled")
$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$schemaVersion = Get-PropertyValue $config "schemaVersion"
$capabilities = Get-PropertyValue $config "capabilities"
$integerVersion = $schemaVersion -is [int] -or $schemaVersion -is [long]
$invalid = -not $integerVersion -or $schemaVersion -ne 1 -or $capabilities -isnot [PSCustomObject]

if ($capabilities -is [PSCustomObject]) {
    $unknownCapabilities = @(
        $capabilities.PSObject.Properties |
            ForEach-Object { $_.Name } |
            Where-Object { -not $requiredCapabilities.Contains($_) }
    )
    $invalid = $invalid -or $unknownCapabilities.Count -gt 0
}

foreach ($name in $requiredCapabilities) {
    $capability = Get-PropertyValue $capabilities $name
    $status = Get-PropertyValue $capability "status"
    if ($capability -isnot [PSCustomObject] -or $status -isnot [string] -or
        -not $allowedStatuses.Contains($status)) {
        $invalid = $true
        continue
    }

    if ($capability.status -eq "enabled") {
        if ($name -in @("issueTracker", "gitServer")) {
            $instructions = Get-PropertyValue $capability "instructions"
            if ($instructions -isnot [string] -or [string]::IsNullOrWhiteSpace($instructions)) {
                $invalid = $true
            } else {
                $instructionsPath = Join-Path $workspaceRoot $instructions
                if (-not (Test-Path $instructionsPath -PathType Leaf)) {
                    $invalid = $true
                }
            }
        } else {
            $customization = Get-PropertyValue $capability "customization"
            if ($customization -isnot [string] -or [string]::IsNullOrWhiteSpace($customization)) {
                $invalid = $true
            }
        }
    }
}

if ($invalid) {
    Write-HookMessage "Copilot project configuration is invalid or incompatible with schema version 1. Do not interrupt unrelated work. Run setup-copilot-project before using a configurable capability."
    exit 0
}

$unconfigured = @(
    $requiredCapabilities | Where-Object {
        (Get-PropertyValue (Get-PropertyValue $capabilities $_) "status") -eq "unconfigured"
    }
)

if ($unconfigured.Count -gt 0) {
    Write-HookMessage "Copilot capabilities remain unconfigured: $($unconfigured -join ', '). Do not interrupt unrelated work. At first relevant use, run setup-copilot-project in the main agent before delegation."
} else {
    Write-Output "{}"
}
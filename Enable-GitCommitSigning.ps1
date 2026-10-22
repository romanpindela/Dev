<#
.SYNOPSIS
    Root launcher for Enable-GitCommitSigning.ps1.
.DESCRIPTION
    Forwards execution directly to .\Enable-GitCommitSigning\Enable-GitCommitSigning.ps1
    preserving all parameters, switches, and argument bindings.
.NOTES
    Author: Roman Pindela (roman.pindela@gmail.com)
    GitHub: https://github.com/romanpindela
    Version: 1.0.0
#>
[CmdletBinding(DefaultParameterSetName = "Default")]
param (
    [Parameter(ParameterSetName = "Configure")]
    [Alias("e", "Setup", "Init")]
    [switch]$Enable,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [Alias("k", "Key")]
    [string]$KeyPath,

    [Parameter(ParameterSetName = "Configure")]
    [Alias("Existing")]
    [switch]$UseExistingKey,

    [Parameter(ParameterSetName = "Configure")]
    [ValidateSet("ed25519", "rsa")]
    [string]$KeyType = "ed25519",

    [Parameter(ParameterSetName = "Configure")]
    [Alias("t", "Title")]
    [string]$KeyTitle,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [string]$Email,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [string]$Name,

    [Parameter(ParameterSetName = "Configure")]
    [string]$AllowedSignersFile,

    [Parameter(ParameterSetName = "Configure")]
    [ValidateSet("Auto", "Manual", "Prompt")]
    [string]$RegistrationMode = "Auto",

    [Parameter(ParameterSetName = "Configure")]
    [Alias("Agent")]
    [switch]$ConfigureAgent,

    [Parameter(ParameterSetName = "Configure")]
    [Alias("Test")]
    [switch]$TestCommit,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [Alias("p", "Path")]
    [string]$RepoPath,

    [Parameter(ParameterSetName = "PushMode")]
    [Alias("Ship")]
    [switch]$Push,

    [Parameter(ParameterSetName = "PushMode")]
    [Alias("m", "Message")]
    [string]$CommitMessage,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [Alias("l", "Log")]
    [string]$LogPath,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [switch]$NoLog,

    [Parameter(ParameterSetName = "Help")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("h")]
    [switch]$Help
)

$targetScript = Join-Path $PSScriptRoot "Enable-GitCommitSigning\Enable-GitCommitSigning.ps1"

if (Test-Path $targetScript) {
    & $targetScript @PSBoundParameters
} else {
    Write-Error "Target script not found: $targetScript"
}

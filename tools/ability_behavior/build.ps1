[CmdletBinding()]
param(
    [string]$Catalog,
    [string]$SemanticSdk,
    [string]$OutputDirectory,
    [ValidateRange(1, 8)]
    [int]$Jobs = 2,
    [switch]$Reuse
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$toolDirectory = $PSScriptRoot
$toolchain = [IO.Path]::GetFullPath((Join-Path $toolDirectory '..\..'))
$workspace = [IO.Path]::GetFullPath((Join-Path $toolchain '..\..\..'))
if ([string]::IsNullOrWhiteSpace($Catalog)) {
    $Catalog = Join-Path $workspace 'work\catalogs\ability-catalog.json'
}
if ([string]::IsNullOrWhiteSpace($SemanticSdk)) {
    $SemanticSdk = Join-Path $workspace 'shared\semantic-sdk\symbols.tsv'
}
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $workspace 'work\ability-behavior\current'
}

dotnet build (Join-Path $toolDirectory 'AbilityBehaviorCatalog.csproj') `
    --configuration Release `
    --nologo
if ($LASTEXITCODE -ne 0) { throw 'Ability behavior tool build failed.' }

$dll = Join-Path $toolDirectory 'bin\Release\net9.0\AbilityBehaviorCatalog.dll'
dotnet $dll self-test
if ($LASTEXITCODE -ne 0) { throw 'Ability behavior self-test failed.' }

$arguments = @(
    $dll,
    'build',
    '--catalog', [IO.Path]::GetFullPath($Catalog),
    '--toolchain', $toolchain,
    '--semantic-sdk', [IO.Path]::GetFullPath($SemanticSdk),
    '--output-dir', [IO.Path]::GetFullPath($OutputDirectory),
    '--jobs', [string]$Jobs
)
if ($Reuse) { $arguments += '--reuse' }
dotnet @arguments
if ($LASTEXITCODE -ne 0) { throw 'Ability behavior catalog has rejected modules or entry bindings.' }

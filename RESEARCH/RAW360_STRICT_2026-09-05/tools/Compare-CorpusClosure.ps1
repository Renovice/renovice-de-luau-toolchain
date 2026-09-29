[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ArtifactDirectory,
    [Parameter(Mandatory)][int]$ClosureNumber,
    [Parameter(Mandatory)][string]$OutputDirectory
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$paths = @()
foreach ($cycle in @('01','02')) {
    $sourcePath = Join-Path $ArtifactDirectory "$cycle.luau"
    $lines = Get-Content -LiteralPath $sourcePath
    $declarations = @(Select-String -LiteralPath $sourcePath -Pattern "^ +local c${ClosureNumber}v[0-9]")
    if ($declarations.Count -ne 1) { throw "Need one exact local declaration for c$ClosureNumber in $sourcePath" }
    $start = $declarations[0].LineNumber - 2
    if ($start -lt 0 -or $lines[$start] -notmatch '^([ ]+).* = function\(') {
        throw 'The matched declaration is not directly inside a generated closure'
    }
    $indent = $Matches[1]
    $end = $start + 1
    while ($end -lt $lines.Count -and $lines[$end] -ne ($indent + 'end')) { ++$end }
    if ($end -eq $lines.Count) { throw 'Matching closure end not found' }
    $output = Join-Path $OutputDirectory "c$ClosureNumber-$cycle.luau"
    [IO.File]::WriteAllText([IO.Path]::GetFullPath($output),
        (($lines[$start..$end] -join "`n") + "`n"), [Text.UTF8Encoding]::new($false))
    $paths += $output
}
$diffPath = Join-Path $OutputDirectory "c$ClosureNumber.diff"
$diff = @(& git diff --no-index --ignore-all-space --unified=3 -- $paths[0] $paths[1] 2>&1)
if ($LASTEXITCODE -notin @(0,1)) { throw "Diff failed: $diff" }
[IO.File]::WriteAllText([IO.Path]::GetFullPath($diffPath),
    (($diff -join "`n") + $(if ($diff.Count) { "`n" } else { '' })),
    [Text.UTF8Encoding]::new($false))
Write-Output $diffPath

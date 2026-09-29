[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$OutputDirectory,
    [string]$FixtureName = 'loop_exit_fixture.luau',
    [string]$ExpectedOutput = 'loop exit fixture: 9 assertions passed',
    [int]$AssertionCount = 9,
    [string]$CompilerPath = ''
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$output = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $output) {
    throw "Use a fresh output directory: $output"
}
New-Item -ItemType Directory -Path $output | Out-Null
$compiler = if ($CompilerPath) { [IO.Path]::GetFullPath($CompilerPath) } else {
    Join-Path $repo 'bin/derecomp.exe'
}
$runtime = Join-Path $repo 'bin/luau.exe'
$source = Join-Path $PSScriptRoot $FixtureName
$expected = $ExpectedOutput
$binaryHash = (Get-FileHash -LiteralPath $compiler -Algorithm SHA256).Hash
$records = @()
try {
for ($cycle = 0; $cycle -le 2; $cycle++) {
    $run = @(& $runtime $source 2>&1 | ForEach-Object { $_.ToString() })
    $exitCode = $LASTEXITCODE
    $run | Set-Content -LiteralPath (Join-Path $output "cycle-$cycle.runtime.txt")
    if ($exitCode -ne 0 -or ($run -join "`n").Trim() -ne $expected) {
        throw "Runtime assertion failure at cycle $cycle : $($run -join ' | ')"
    }
    $records += [pscustomobject]@{
        cycle = $cycle
        source_sha256 = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
        assertions = $AssertionCount
        runtime_exit = $exitCode
    }
    if ($cycle -eq 2) { break }
    $bytecode = Join-Path $output "cycle-$cycle.lua_B"
    $compileLog = @(& $compiler recompile $source $bytecode 2>&1)
    [IO.File]::WriteAllText((Join-Path $output "cycle-$cycle.compile.txt"),
        ($compileLog -join "`n"), [Text.UTF8Encoding]::new($false))
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $bytecode)) {
        throw "Fixture compilation failed: $compileLog"
    }
    $source = Join-Path $output "cycle-$($cycle + 1).luau"
    $decompileLog = @(& $compiler decompile-mod $bytecode $source 2>&1)
    [IO.File]::WriteAllText((Join-Path $output "cycle-$cycle.decompile.txt"),
        ($decompileLog -join "`n"), [Text.UTF8Encoding]::new($false))
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $source)) {
        throw "Fixture decompilation failed: $decompileLog"
    }
}
} catch {
    [pscustomobject]@{
        compiler = $compiler
        binary_sha256 = $binaryHash
        records = $records
        passed = $false
        failure_cycle = $cycle
        failure = $_.Exception.Message
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $output 'result.json')
    throw
}
if ((Get-FileHash -LiteralPath $compiler -Algorithm SHA256).Hash -ne $binaryHash) {
    throw 'Compiler changed during fixture verification'
}
[pscustomobject]@{ binary_sha256 = $binaryHash; records = $records; passed = $true } |
    ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $output 'result.json')
Write-Output "PASS: $AssertionCount runtime assertions on source and each of two decompiled cycles ($($AssertionCount * 3) total)."

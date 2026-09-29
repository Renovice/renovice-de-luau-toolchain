[CmdletBinding()]
param([Parameter(Mandatory)][string]$OutputDirectory)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$output = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $output) { throw "Use a fresh output directory: $output" }
New-Item -ItemType Directory -Path $output | Out-Null
$compiler = Join-Path $repo 'bin/derecomp.exe'
$binaryHash = (Get-FileHash -LiteralPath $compiler -Algorithm SHA256).Hash
$cases = @(
    @('loop_exit', 'loop exit', 9),
    @('shared_return', 'shared return', 24),
    @('stock_binary_search', 'stock binary search', 36),
    @('exit_relay', 'exit relay', 56),
    @('return_continuation', 'return continuation', 24),
    @('value_temporary', 'value temporary', 33),
    @('index_and_first_loop', 'index and first loop', 29),
    @('ordered_comparison', 'ordered comparison', 16),
    @('index_store', 'index store', 4),
    @('effectful_latch', 'effectful latch', 29),
    @('shared_terminal_effect', 'shared terminal effect', 15),
    @('shared_loop_guard', 'shared loop guard', 12),
    @('linear_return_guard', 'linear return guard', 32),
    @('nested_repeat_guard', 'nested repeat guard', 121),
    @('private_loop_terminal', 'private loop terminal', 517),
    @('root_repeat_return', 'root repeat return', 66),
    @('stock_inventory_guard', 'stock inventory guard', 8),
    @('stock_inventory_loop', 'stock inventory loop', 24),
    @('stock_dojo_loop', 'stock dojo loop', 16)
)
$records = @()
$failure = $null
try {
    foreach ($case in $cases) {
        $name = $case[0] + '_fixture.luau'
        $count = [int]$case[2]
        $word = if ($case[0] -eq 'stock_inventory_loop') { 'case assertions' } else { 'assertions' }
        $expected = "{0} fixture: {1} {2} passed" -f $case[1], $count, $word
        & (Join-Path $PSScriptRoot 'verify-loop-exit-fixture.ps1') `
            -OutputDirectory (Join-Path $output $case[0]) -FixtureName $name `
            -ExpectedOutput $expected -AssertionCount $count
        $records += [pscustomobject]@{fixture=$name; assertions_per_cycle=$count; cycles=3; passed=$true}
    }
} catch {
    $failure = $_.Exception.Message
} finally {
    $after = (Get-FileHash -LiteralPath $compiler -Algorithm SHA256).Hash
    if ($after -ne $binaryHash) { $failure = 'Compiler changed during fixture suite' }
    $total = 0
    foreach ($record in $records) { $total += $record.assertions_per_cycle * $record.cycles }
    [pscustomobject]@{
        binary_sha256=$binaryHash; binary_sha256_after=$after
        fixtures_expected=$cases.Count; fixtures_passed=$records.Count
        case_assertions=$total; records=$records; failure=$failure
        passed=($null -eq $failure -and $records.Count -eq $cases.Count)
    } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $output 'suite.json')
}
if ($failure) { throw $failure }
Write-Output "SUITE PASS: $($records.Count) fixtures, $total case assertions across source and two recovered cycles."

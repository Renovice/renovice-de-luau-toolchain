# Explicit experimental profile; excludes the separate exit-only-tail experiment.
. (Join-Path $PSScriptRoot 'Set-CandidateProfileV10.ps1')
$env:RENOVICE_SCOPED_STATE_PREFIX_REUSE = '1'
$env:RENOVICE_CANONICAL_LITERAL_RETURN_TAIL = '1'
$env:RENOVICE_CANONICAL_OR_VALUE_TEMPORARIES = '1'

# Explicit experimental profile; does not change compiler defaults.
. (Join-Path $PSScriptRoot 'Set-CandidateProfileV6.ps1')
$env:RENOVICE_MAPPED_EXIT_STATE_RELAYS = '1'
$env:RENOVICE_CANONICAL_EMPTY_ELSE_RETURN = '1'
$env:RENOVICE_CFG_PARTITION_SHARED_GUARD = '1'
$env:RENOVICE_CFG_PREFER_PRIVATE_RETURN_TRIANGLE = '1'
$env:RENOVICE_CANONICAL_EMPTY_RETURN_CONTINUATION = '1'

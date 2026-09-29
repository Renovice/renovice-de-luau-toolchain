. (Join-Path $PSScriptRoot 'Set-CandidateProfileV18.ps1')
$env:RENOVICE_CFG_EFFECTFUL_LATCH_GUARD_REPEAT = '1'
$env:RENOVICE_CFG_RETRY_COMPLETE_LOOP_DISPATCH = '1'
$env:RENOVICE_LOCALIZED_INDEX_STORE_LIFETIMES = '1'
# Ordered-predicate correction remains a separate explicit experiment during
# focused control-flow diagnosis: RENOVICE_EXACT_ORDERED_PREDICATES=1.

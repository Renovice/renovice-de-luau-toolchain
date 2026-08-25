-- Proves OnInit's BODY executes and error() reaches EE.log: an unconditional error with a unique tag.
-- If EE.log shows "CERT_MIN_RUNS", the body runs and the error channel works -> a clean cert_all means PASS.
function OnInit()
    error("CERT_MIN_RUNS")
end

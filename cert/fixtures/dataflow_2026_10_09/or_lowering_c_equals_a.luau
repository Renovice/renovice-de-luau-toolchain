-- FIXED (DEFECTS #65, 2026-10-09; found by dataflow-identity). RECOMPILER, not decompiler:
-- transcode.h lowered OR A B C to MOVE A<-B; JUMPIF A; MOVE A<-C, which reads the clobbered A when
-- C == A, so `value = IsMissing(value) or value` became `... or IsMissing(value)`. C is now saved in a
-- scratch register first; RENOVICE_LEGACY_ORAND_LOWERING=1 reproduces the old lowering. Behavior is
-- observed on the source re-decompiled from the rebuilt bytecode. Class OR VALUE (slot 1).
local function IsMissing(value) return value == nil end
local function Choose(value)
    value = IsMissing(value) or value
    print("choose", value)
end
Choose(nil)
Choose("kept")

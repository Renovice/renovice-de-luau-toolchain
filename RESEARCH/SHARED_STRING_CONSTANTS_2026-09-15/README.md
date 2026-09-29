# Shared string constants used as names and values

Hypothesis: every string used by a hashed name opcode may be replaced by its
hash. **False.** In the V86 automatic observer prototype 54, `table` is also a
literal used to compare type results. The compiler omitted LOADK and other
value contexts from str_set, so that literal became a name hash. Fidelity text
cracks it back into a readable spelling, concealing the emitted tag error.

The actual original observer has six nonboolean hash LOADK operands. The
baseline regression harness rejects nine mixed-name/value cases and that
artifact; its name-only control passes. The compiler now records LOADK,
LOADKX, JUMPXEQKS, FASTCALL2K, arithmetic/logical constant operands and table
template keys/values as literal contexts. Existing appended-hash remapping
preserves hashed consumers without changing literal operands or opcode maps.

Ten regression fixtures and all existing build gates pass. The repaired
observer has 321 value LOADK operands, zero erroneous name hashes, and passes
DE parse/re-emission and semantic IR. Compiler SHA256
6F4572FAA0BB5BB56469EA2B874C4226191C482279A9CD9FBA91A59A3BCB977D.
Old compiler SHA256
60157E2FD66E884E089AA7762AA7C5CD79C67748A502B7885FF6FEAE5AB46D6C.
Preserved compiler/source/build script precede these edits.

The release run uses decompile-mod with 300 alignment files and 150 behavioural
realtrips: ALIGNED=211, NAME-DIFF=0, SAME=150, DIFFERENT=0, timeout=0;
all baseline gates pass. It is not a renewed raw 360/360 or original-stock-byte
certificate, nor full 5,386-script individual certification. The fixture is
part of build.bat and stays under tools; logs/certificate stay under evidence.

See the [central shared buff repair](../../../../../Documentation/03-Abilities-and-Combat/Shared-Buff-Pipeline-Repair-2026-09-15.md)
for live failure evidence, generic activation repair and pending live gates.

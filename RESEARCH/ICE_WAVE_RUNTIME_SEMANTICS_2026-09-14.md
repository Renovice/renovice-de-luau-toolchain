# Ice Wave runtime semantics propagated into the toolchain — 2026-09-14

## Scope

This record separates what the compiler/decompiler proved from what the live
Ice Wave investigation proved about engine-owned objects and hook execution.
The bytecode pipeline did not miscompile the addon. The failures came from
incorrect runtime lifetime and identity assumptions in authored Lua.

## Hypotheses and results

| Hypothesis | Result | Evidence and consequence |
| --- | --- | --- |
| Correct decompile and recompile implies correct engine-object semantics. | **False.** | The addon compiled, reparsed, round-tripped, and passed semantic structure gates while still retaining an aliased `UpgradedValue`. Bytecode correctness proves the emitted operations, not the lifetime behavior of native userdata. |
| `DamageData:GetBaseAmount()` returns a stable snapshot of the old amount. | **False at the proven Ice Wave callsite.** | A wrapper that initially read `1771` read `5313` after the packet was set to `5313`. Preserve the old value as the Lua number returned by `GetModifiedValue()`, then construct a new `Engine.UpgradedValue(number)` for restoration. |
| Equal userdata or native addresses identify one logical object over several calls. | **False.** | Stock creates `DamageData` inside the target loop, while live traces reused one printed native address for consecutive logical packets. Do not key caches or transaction ownership only by pointer or userdata equality. |
| A target with multiplier one requires no write. | **False for a mutable/reused packet boundary.** | Skipping `SetBaseAmount` allowed the prior target's multiplied value to survive. Explicitly install the calculated value for every target, including 1x. |
| One cast can share one status multiplier across every victim. | **False.** | Mixed zero-stack and ten-stack targets exchanged damage when state was grouped. Capture and consume one transaction at the exact target-local native call. |
| A Lua-entry hook and a native-call hook see the same nested execution. | **False on the tested path.** | Native `DamageDD` callbacks identified prototype 7 instruction 64 while `luaCalls[7].before` fired zero times. Hook visibility must be proven per layer and callsite. |
| The DE VM provides ordinary Luau standard-library fields. | **False as a general assumption.** | `math.min` existed while `math.huge` was nil in the deployed target-addon environment. Dependencies on library fields require direct proof or a fail-closed fallback. |
| Every wrapper for an Avatar-shaped native object exposes the complete Avatar Lua API. | **False.** | The earlier Mallet callback wrapper lacked `IsDead`. Probe optional methods independently and record availability rather than inferring the Lua metatable from native object identity. |
| Raw damage is equal to visible health removed. | **False as a general equation.** | Armor, shields, Overguard, attenuation, invulnerability, resistances, and other native behavior can intervene. Record raw input and immediate pool deltas separately. |
| The readable renderer can always assign one friendly name and type to a hook-payload value. | **False, and the renderer failed closed.** | The V74 consumer smoke produced exactly `READABLE_ALIAS_AMBIGUOUS:proto=27:web=25` and `READABLE_TYPE_AMBIGUOUS:proto=27:web=25`. That web is both payload element two and the receiver of `GetBaseAmount`; the renderer retained canonical `frame_27[25]` instead of inventing ownership. No other readable ambiguity diagnostic occurred. |

## Toolchain consequence

The opcode map, DE container reader/writer, compiler lowering, decompiler CFG,
Semantic IR, and readable renderer require no corrective algorithm change from
this incident. Their gates correctly described the emitted program.

The durable change belongs in the API and authoring knowledge layers:

1. `DamageData:GetBaseAmount` now declares a borrowed packet-local live wrapper
   and cites the exact alias trace.
2. Negative contracts permanently reject immutable-wrapper, pointer-identity,
   equal-hook-visibility, guaranteed-standard-library, and skipped-1x-write
   assumptions.
3. Semantic SDK consumers must keep wrapper type, ownership, lifetime, and
   numeric snapshot semantics separate.
4. Ability modifications must attach state to an exact call transaction and
   target, not merely a cast label, userdata address, or plausible helper.
5. Diagnostics record availability and unknown fields explicitly. They do not
   rename unresolved damage/status indices or reconstruct a hidden native
   damage formula from pool deltas.

## Evidence levels

- V73 mixed-stack gameplay: **user-reported live pass**.
- V72 aliasing and V69 hook visibility: **live trace evidence**.
- Target-local transaction behavior, explicit 1x assignment, wrapper rebuild,
  missing-method handling, and battle-log correlation: **offline regression
  harness pass**.
- V74 runtime/addon/config deployment: **hash-verified pass**.
- Updated Semantic SDK consumer smoke over the V74 addon: **rendered 33
  prototypes with 288 accepted aliases and 69 accepted types; the two exact
  proto-27/web-25 ambiguity diagnostics were retained fail-closed; generated
  readable source recompiled to 13,152 bytes and reparsed as 33 prototypes**.
- V74 startup and live `BATTLE_*` records: **pending**.

Do not upgrade the last two offline or deployment claims into live gameplay
proof until the capture is complete.

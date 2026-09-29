# `ability_stats_labeled.json` status

This 2026-07-24 AI-authored dataset is **discovery material, not a compiler or
editor authority**. It does not carry exact body keys, reproducible source
spans, or a verified generator.

An exact Semantic IR audit on 2026-08-28 proved that the Octavia Mallet entry
had Radius and Duration swapped and described the Strength selector
incorrectly. Those three known rows were corrected. A broad evidence-text
consistency scan found 28 additional candidate selector/label conflicts; they
remain unverified rather than being guessed into corrections.

Production consumers must bind a label to the exact module body key and exact
value-flow evidence. Ability Studio follows that rule through
`REGISTRIES/stock_value_bindings.tsv`; it does not consume this JSON.


# Initial validation

Executed with MATLAB R2025a. The event-parser regression test passes on the known mle01 retest run: 34 displacement markers retained; trials 76 and 78 labelled 2; duplicated 500 samples collapsed; a missing marker flagged rather than classified as correct.

All 36 run-named EEG recordings are represented in the manifest. Same-day mouse log matching is required. Six early spe30 runs lack matching same-day mouse CSVs; another spe30 run fails strict trial-start alignment. These runs remain in the audit but do not contribute epochs. This is conservative exclusion, not a claim that their EEG cannot be recovered.

Initial accepted counts: spe30 1387; mle01 1184. These differ from the paper because this pipeline uses explicit log validation, a different baseline, absolute-amplitude rejection and conservative loss/edge exclusion. No FORCe cleaning is applied. Do not describe these figures as an exact reproduction.

Trials 76 and 78 have corrected condition labels in the new metadata, but are rejected from averaging because their windows overlap data loss/filter-edge exclusion. Legacy per-run and aggregate Labels files remain untouched.

Each processed epoch has 1000 samples at 500 Hz, time -1.000 to +0.998 seconds. Invalid/rejected trials retain their metadata rows and NaN epoch slots. Accepted trials alone contribute to plots. Plot colours: blue non-displaced, red displaced, black difference, gold Bonferroni-significant difference.

# MATLAB EEG pipeline

## Current configuration: FORCe v2 pilot

`config()` selects `output/pipeline_v2_2s` and all eligible runs for spe30 and
mle01 across pre, post and retest sessions. `config('v1')` exposes the historical
settings for reference. Stage 2 refuses to write to the v1 root.
Original recordings, legacy labels and existing `output/pipeline_v1`
products are retained. Both participants have now been processed across all
eligible task recordings: 29 of 36 recordings, with seven excluded because
no trials passed event validation. The previous one-second-window results
remain in `output/pipeline_v2`. The two-second experiment uses the same runs.
`cfg.forceWindowSeconds` selects 1 or 2 seconds; selecting 1 also restores
the original v2 output location and its comparison against v1.

```matlab
addpath('ErrpAnalysis/Code')
stage02_preprocess_epochs
stage03_plot_errp
```

Event parsing is shared between versions. `cfg.parsedOutput` points to
`output/pipeline_v1/parsed`; stage 2 always reads that manifest and its parsed
files. It calls stage 1 only when the manifest is missing. Running stage 1
explicitly also reuses an existing manifest. No v2/v1 location search is used.
If the event parser or input dataset changes, explicitly choose a new parsed
output folder in the configuration before parsing again.

Selected runs are recorded in `selected_manifest.csv` under `cfg.output`.
The default includes all eligible runs. Set `cfg.maxRunsPerSubjectSession`
to a finite number only for a smaller trial run.

## Stages

1. **Parse events:** match same-day mouse logs, validate event sequences and
   target displacement, and retain trial identity and raw sample positions.
   Ambiguous/missing events remain invalid. Training recordings are excluded.
2. **Preprocess epochs:** convert nV to microvolts, split at data loss and
   timestamp gaps, filter valid continuous segments at 1-20 Hz, retain the
   existing two-second edge guard, and extract [-1,1) movement-locked epochs.
   Clean each eligible epoch in one 1000-sample FORCe window at 500 Hz
   when `cfg.forceWindowSeconds=2`; the 1-second setting uses two halves. Apply the [-0.2,0) baseline afterward, followed by absolute
   100-microvolt rejection. All metadata rows remain; final rejected epochs
   are NaN. Use `trials.accepted` when analyzing the final arrays.
3. **Participant plots:** condition averages and displaced-minus-non-displaced
   differences, separately for each participant/session. Unpaired two-sided
   equal-variance tests are Bonferroni-corrected over 8000 channel/time
   comparisons within each participant/session. Only selected manifest runs
   contribute; legend handles explicitly identify significance markers.
4. **Group averages:** equal weights for eligible participant means and paired
   tests of their differences, corrected within each session. This remains
   available but is not part of the initial participant-review pilot. A group
   computed with the pilot configuration contains two participants, not 25.

## FORCe integration and dependencies

The supplied implementation is in `Code/FORCe`, with Windows x64 compiled
histogram helpers in `Code/FORCe/mex-files`. MATLAB Wavelet, Signal Processing
and Statistics and Machine Learning toolboxes are used. No Python port or
new external package is needed. The adapter is
`Code/helpers/clean_epoch_force.m`; stage 2 remains one script with short
Stage 2a-2g labels. Wavelet boundary mode is explicitly `sym` during cleaning
and restored afterward. Channel locations come from `chanlocs8.mat` in the
recording order. Accelerometer mode is disabled.

The pipeline uses the supplied `FORCe.m` and `mi.m`, with local fixes applied
in place. [Applied fixes](FORCe/PATCHES.md) summarizes the MEX function-name
correction, failure diagnostics and validation. Modified lines are marked
`updated by Satyam`; original author and license notices are retained.
Unmodified source copies are retained as non-executable text in
`Code/FORCe/upstream` for comparison. The adapter handles windowing and quality
checks while calling the supplied cleaning algorithm. Scientific thresholds
and decomposition logic are unchanged. To avoid accepting unvalidated
coordinate-scale-dependent interpolation, the adapter rejects windows that invoke that branch. It also
flags invalid input/output, flat channels, channel-threshold failures and
all-IC removal. These are documented pilot quality policies.

## Saved results

Each processed run contains final `epochs`, `trials` with acceptance flags and
rejection reasons, `time`, `channels`, recording information and configuration.
Rejected epochs remain NaN. Stage 2 recomputes the selected runs on each
execution and replaces their v2 outputs. It does not use file hashes or
cache matching, and it never writes to the v1 output root.

`test_force_integration` is an optional quick check on one real epoch and an
invalid input; it is not required before each analysis run.

## Comparing window lengths

Optionally run `compare_pipeline_versions` after stages 2 and 3. It reads
`cfg.comparisonOutput` (one-second FORCe results by default) and `cfg.output`
(two-second results), then writes comparisons under `cfg.output/comparison`:

- `common` and `own` figures: averages on identical accepted trials and on
  each method's accepted trials, respectively. Current results are solid;
  reference results are dashed.
- `onset` figures: a closer view around movement onset on common trials.
- `comparison_counts.csv`: retention by participant/session/condition and
  median onset steps on common trials. Conditions 1/2 are non-displaced/displaced.
- `onset_steps.csv`: per-trial maximum channel step from -2 ms to 0 ms, plus
  typical nearby steps within +/-50 ms excluding the join, in microvolts.
- `waveform_comparison.csv`: condition-average correlation and RMS difference
  over 0.2-1 s for each channel, using common trials.

Two-second cleaning removes the internal concatenation point but also changes
component estimation and rejection. It is a window-length variation from the
one-second method; a smoother onset alone does not establish better recovery
of physiological activity. Filter ordering, interpolation policy and all
other processing settings are unchanged.

The previous one-second results are in
[VALIDATION.md](../output/pipeline_v2/VALIDATION.md). The completed [window-length comparison](../output/pipeline_v2_2s/WINDOW_COMPARISON.md)
supports the two-second setting: on 2,610 common trials, the median onset step
decreased from 2.79 to 0.57 microvolts while nearby variation remained similar.

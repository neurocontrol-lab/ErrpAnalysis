# MATLAB EEG pipeline

## Current configuration: FORCe v2 pilot

`config()` selects `output/pipeline_v2` and all eligible runs for spe30 and
mle01 across pre, post and retest sessions. `config('v1')` exposes the historical
settings for reference. Stage 2 refuses to write to the v1 root.
Original recordings, legacy labels and existing `output/pipeline_v1`
products are retained. Both participants have now been processed across all
eligible task recordings: 29 of 36 recordings, with seven excluded because
no trials passed event validation. See the [results report](../output/pipeline_v2/VALIDATION.md).

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

Selected runs are recorded in `output/pipeline_v2/selected_manifest.csv`.
The default includes all eligible runs. Set `cfg.maxRunsPerSubjectSession`
to a finite number only for a smaller trial run.

## Stages

1. **Parse events:** match same-day mouse logs, validate event sequences and
   target displacement, and retain trial identity and raw sample positions.
   Ambiguous/missing events remain invalid. Training recordings are excluded.
2. **Preprocess epochs:** convert nV to microvolts, split at data loss and
   timestamp gaps, filter valid continuous segments at 1-20 Hz, retain the
   existing two-second edge guard, and extract [-1,1) movement-locked epochs.
   Clean each eligible epoch in two independent 500-sample FORCe windows at
   500 Hz. Apply the [-0.2,0) baseline afterward, followed by absolute
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

## Pilot review

Optionally run `compare_pipeline_versions` to compare saved v1 results with
the configured pipeline. It writes participant/session comparisons under
`output/pipeline_v2/comparison`: identical retained trials (`common`), each
pipeline's retained trials (`own`). A table records condition counts and
recovered/lost trials. The comparison uses saved v1 epochs as its reference.
Reduced amplitude alone is not evidence of successful artifact removal.
Inspect all channels and possible boundary steps before expanding the
subject list.

The 1-20 Hz-before-FORCe ordering follows the conference paper's stated
sequence. Higher-frequency internal criteria and independent-window seams
remain methodological concerns, not automatically corrected bugs. Exact
historical reproduction still requires the group's settings/reference output.
No significant ErrP mechanism or stimulation effect follows from a successful
software test or a cleaner-looking waveform.

Complete two-participant results are described in
[VALIDATION.md](../output/pipeline_v2/VALIDATION.md). The movement-onset window
join remains a methodological concern; review window placement before
interpreting the cleaned ErrP.

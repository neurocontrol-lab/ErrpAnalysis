# MATLAB EEG pipeline

## Current configuration: FORCe v2 pilot

`config()` selects `output/pipeline_v2_2` and all eligible runs for spe30 and
mle01 across pre, post and retest sessions. `config('v1')` exposes the historical
settings for reference. Stage 2 refuses to write to the v1 root.
Original recordings, legacy labels and existing `output/pipeline_v1`
products are retained. Both participants have now been processed across all
eligible task recordings: 29 of 36 recordings, with seven excluded because
no trials passed event validation. The current experiment uses continuous 1 Hz high-pass filtering, two-second
FORCe cleaning, then per-epoch 20 Hz low-pass filtering. Earlier outputs remain
in `pipeline_v2` (one-second windows) and `pipeline_v2_1` (two-second windows,
bandpass before cleaning). Set `cfg.filterPlacement='before'` to restore the
earlier order; `cfg.forceWindowSeconds` then selects its one- or two-second
variant and output folder.

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
   timestamp gaps, high-pass valid continuous segments at 1 Hz, retain the
   existing two-second edge guard, and extract [-1,1) movement-locked epochs.
   Clean each eligible epoch in one 1000-sample FORCe window at 500 Hz
   when `cfg.forceWindowSeconds=2`. Apply the 20 Hz low-pass to the cleaned
   epoch, then the [-0.2,0) baseline, followed by absolute
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
and restored afterward. Channel locations come from `Code/resources/chanlocs8.mat` in the
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

## Comparing processing settings

Optionally run `compare_pipeline_versions` after stages 2 and 3. It reads
`cfg.comparisonOutput` (the earlier bandpass-first, two-second results) and
`cfg.output` (the split-filter experiment), then writes comparisons under `cfg.output/comparison`:

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

The previous window-length experiment showed that two-second cleaning removes the internal concatenation point but also changes
component estimation and rejection. It is a window-length variation from the
one-second method; a smoother onset alone does not establish better recovery
of physiological activity. That experiment held filter ordering and other processing settings fixed.

The previous one-second results are in
[VALIDATION.md](../output/pipeline_v2/VALIDATION.md). The completed [window-length comparison](../output/pipeline_v2_1/WINDOW_COMPARISON.md)
supports the two-second setting: on 2,610 common trials, the median onset step
decreased from 2.79 to 0.57 microvolts while nearby variation remained similar.

## Filter-order experiment and rationale

The current sequence is **continuous 1 Hz high-pass -> extract [-1,1) epochs ->
FORCe -> 20 Hz low-pass -> [-0.2,0) baseline -> 100 microvolt rejection**.
All filters use Butterworth designs with `cfg.filterOrder=4` and zero-phase
`filtfilt`. The channel-interpolation exclusion policy and the two-second
cleaning duration are not changed by this experiment.

High-pass filtering removes DC offsets and slow drift before decomposition;
epoch baseline correction subtracts a pre-event mean after cleaning. These
are different operations. No epoch baseline subtraction is done before FORCe.
The references supporting this distinction are:

- [EEGLAB: Filtering](https://eeglab.org/tutorials/05_Preprocess/Filtering.html)
  recommends high-pass filtering around 1 Hz for ICA and filtering continuous
  data before epoching.
- [MNE: Repairing artifacts with ICA](https://mne.tools/stable/auto_tutorials/preprocessing/40_artifact_correction_ica.html)
  recommends high-pass filtering before ICA and baseline correction afterward,
  because ICA cleaning can introduce offsets.

These references support general ICA preprocessing practice; they do not
validate this particular FORCe implementation or establish that moving the
20 Hz low-pass improves artifact removal. The latter is our experimental
hypothesis: preserve higher-frequency input for FORCe, then restrict the
cleaned signal to the ErrP analysis band.

The reference uses one combined bandpass on continuous segments. The new
pipeline uses separate high-pass and low-pass designs and filters the cleaned
epoch at the last step. This changes both filter response and endpoint context,
so differences cannot be attributed exclusively to ordering. MATLAB's
[filtfilt documentation](https://www.mathworks.com/help/signal/ref/filtfilt.html)
describes endpoint-transient handling; filtering a short epoch can still affect
its edges. No extra smoothing, padding scheme, or threshold adjustment is used.

Results are saved separately under `output/pipeline_v2_2`; the
[completed comparison report](../output/pipeline_v2_2/FILTER_ORDER_COMPARISON.md)
summarizes retention and matched-trial waveform changes. The new sequence
retains 2,616 trials versus 2,611, with a median condition-average correlation
of 0.992. This does not by itself establish better artifact removal.

## Code layout

The four stage scripts and `config.m` are the pipeline entry points.
`helpers/` contains shared functions and the optional comparison script;
`tests/` contains the two optional checks; `resources/` holds channel locations.
`FORCe/` contains the supplied library, and `legacy/` holds the earlier analysis.

From the repository root, run the optional comparison or checks with:

```matlab
addpath('Code', 'Code/helpers', 'Code/tests')
compare_pipeline_versions
test_event_parser
test_force_integration
```

Add only the required folders to the MATLAB path; recursively adding `Code/`
also includes legacy toolboxes and can introduce conflicting function names.

## Output versions

| Folder | Processing change |
|---|---|
| `pipeline_v1` | Original pipeline |
| `pipeline_v2` | Initial FORCe integration, one-second windows |
| `pipeline_v2_1` | Two-second FORCe windows |
| `pipeline_v2_2` | High-pass -> FORCe -> low-pass |

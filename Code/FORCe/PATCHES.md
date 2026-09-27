# FORCe applied fixes

The supplied FORCe library has the following local fixes for use in this
analysis. Modified code is marked `updated by Satyam`; original author and
license notices are retained. Original sources are available as
non-executable text in `upstream/` for comparison.

## Applied fixes

- **Histogram function name (`mi.m`):** the 72-sample branch called the
  missing `hista_72_mex` function. It now calls the supplied `hista__72_mex`
  binary. This corrects an execution error without changing the histogram
  definition.
- **Failure reporting (`FORCe.m`):** an optional second output reports
  rejected channels, rejected independent components, all-component removal,
  and the no-usable-channel abort. This lets the pipeline distinguish failed
  cleaning from valid output, including the original abort path that returns
  the input unchanged. Existing one-output calls remain supported. Cleaning
  thresholds, interpolation, decomposition and reconstructed samples are
  unchanged.

## Validation

All 22 specialized MEX lengths matched the supplied MATLAB histogram/MI
reference to 1e-12 on deterministic nonconstant inputs. Cleaned demo-window
samples matched the original FORCe source to 1e-12, and the all-channel abort
reported `no_usable_channels` as expected.

## Pipeline safeguards

The adapter `../helpers/clean_epoch_force.m` calls the supplied library. It
validates dimensions, channel order and finite data, calls FORCe using the
configured one- or two-second windows, and returns cleaned samples with a
success/failure status. Window length is an analysis setting, not a library fix.
Failed windows invalidate the epoch. The pilot also rejects windows requiring
channel interpolation, flat channels and all-component removal. These are
pipeline quality policies, not changes to the FORCe algorithm.

The optional adapter check covers one real epoch and invalid-input handling.

## Unresolved scientific checks

The positive-only 200-microvolt channel threshold, coordinate-dependent
interpolation, IC spikiness indexing, spectral criteria after 1-20 Hz
filtering remain unchanged and require scientific validation. Independent-window
join artifacts are addressed by the two-second pipeline setting, evaluated in
the [window-length comparison](../../output/pipeline_v2_2s/WINDOW_COMPARISON.md);
this is separate from library bug fixes. Passing numerical regression
checks does not establish physiological validity; see the
[pilot validation report](../../output/pipeline_v2/VALIDATION.md).

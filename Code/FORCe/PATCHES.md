# FORCe library change log

## 2026-09-26 - source relocation (no algorithm changes)

Moved supplied code/example files from `ErrpAnalysis/FORCe` to
`ErrpAnalysis/Code/FORCe`, and compiled helpers from `ErrpAnalysis/mex-files`
to `Code/FORCe/mex-files`. Moved files were hash-checked. The Word reference
`FORCe - ID.docx` is now colocated with the library (moved by the user).
`mex_Me` is not part of the FORCe dependency chain.
The diagnostic script's paths were updated. No library bug fixes or
algorithm changes have been applied yet; no cohort outputs were regenerated.

## Pending compatibility fix

`mi.m` calls `hista_72_mex` in its 72-sample branch; the supplied binary is
`hista__72_mex.mexw64`. Earlier targeted execution confirmed an undefined
function error. This is a source-level typo and can affect fresh runs.
Record the patch and regression result here when it is actually applied.

## Integration safeguards planned (not library patches)

The planned adapter belongs in `Code/helpers/clean_epoch_force.m`. It will
validate units, dimensions and channel order; process separate 500-sample
windows; detect nonfinite/invalid outputs and unchanged-input aborts; and
record cleaning status. Stage 2 retains filtering, baseline and rejection.

## Scientific questions requiring validation

Keep these separate from confirmed compatibility bugs: one-sided positive
200-microvolt channel threshold; coordinate-scale-dependent interpolation;
IC spikiness indexing; spectral criteria after 1-20 Hz filtering; and
waveform discontinuities at the independent-window join. Do not silently
change thresholds, coordinates, component logic or processing order.

## Required entry for every future patch

Record date, file/function, triggering condition, original behavior, exact
change, rationale, whether numerical cleaning behavior changes, validation
and results, and pre/post source hashes. Keep compatibility fixes distinct
from algorithm variants. Preserve existing author/license notices.

## Relocated supplied-file SHA-256 baseline

- `16channels.loc`: `8e5fdef356688b7997625fb38c17d447e7ab30991314b583071ce1e9c42c66cb`
- `applyOnlineICAmethodWaveNowsobi.m`: `3b6f8c55f7bde3ea395869f512dde803fb1d86da88ea26da37554da3b5114137`
- `chanlocs16.mat`: `2719abc5d923eeeae82ba9c609e277ab4d30e0e3e991e2b04035d5dae1f1d0ad`
- `checkThresholds.m`: `b9a2619bfc2f7b6bde64c9b64f0fecc344a4e9542b46c3c1250641d31c7ac2a4`
- `demo.m`: `453704dddb3277309224afa2196a43c602d37e99d33945c5fcaf9de2a0409098`
- `EEG_example.mat`: `767e4d9b40d5ee782e1d55af7714928e94733db8f1f61851cdd70fe6deb27b39`
- `estimateRemovedChs.m`: `23af7a01bd7ab27079b1c0100380812f6b4c3c0acbea905397ac0b1bcf523e87`
- `extractFeaturesMultiChsWaveAMI.m`: `c7de04f6d76e3d941a53afc44c287c33c584595d7a6f2657bc5df3cbd9671cac`
- `FORCe.m`: `cfa08973abf81b11ca73d5cbcb4a540d483e0ec0f8b5f8c8420a812b5650abbc`
- `hist2a.m`: `6fe173b15a16d96fede385e800992c4ccd9c11581bf9c077e165519c31473bec`
- `hista.m`: `3a5d6dc02812660f3c0412acdafa281fe658692ebccb97f36328be4cd0be5359`
- `mex-files/hist2a_100_mex.mexw64`: `aa06a851c08cd9d22b90a83c0925362cd9da083d25fb5cfd2d206f729e32f239`
- `mex-files/hist2a_102_mex.mexw64`: `2ce82dfd7105f501413834d7f54e709f091200021af745618e56b3a7a0459fe1`
- `mex-files/hist2a_104_mex.mexw64`: `8674630badf27b80bdf5b296fc412595cc655dfdf33a408e871d1351e20c0746`
- `mex-files/hist2a_108_mex.mexw64`: `e8ba5db93805988882b1ceaf55c01c06fe4252027e2d7e62d3a2b6d6d96bd1aa`
- `mex-files/hist2a_112_mex.mexw64`: `595d1549bc8ce43a668418b06d7ed096c6b2b84ab0b6e3de60ab604028469709`
- `mex-files/hist2a_114_mex.mexw64`: `93402110960141de108b759f2737a44ad793c1cd15ad2906fa2b8731059e5807`
- `mex-files/hist2a_116_mex.mexw64`: `c320e05dfeedbea1b9021e9d588c8190a38d404237c8d79ac03a3440b013c49d`
- `mex-files/hist2a_120_mex.mexw64`: `4a8989ce830c62ebe08b48d7feb0b03033d60fca7531461365a64d613e0de132`
- `mex-files/hist2a_124_mex.mexw64`: `4194eff47920b381ff175607ca01626f7dd726164ba1bbcc8b0680939571cbdb`
- `mex-files/hist2a_126_mex.mexw64`: `b428cb17f868cbb3c526ff92f300732449de495cc79e8779f027f9c2b92bf643`
- `mex-files/hist2a_128_mex.mexw64`: `544e954f5618b35426af1d533c0165e308abd5ae8e7ef1f4dcc488975fed9e0a`
- `mex-files/hist2a_132_mex.mexw64`: `301056f79c699e226636de2f030fbd00e9ca4f04995f972bca2814ff82ad27a0`
- `mex-files/hist2a__68_mex.mexw64`: `3565135372a335f741e52e814c2226d09e95eaa64442f7375d7f14d61ec301cd`
- `mex-files/hist2a__72_mex.mexw64`: `8deb8e0312dab8f294f4dfcb59a35bfde4955a007221233d05add4430431cd5d`
- `mex-files/hist2a__76_mex.mexw64`: `a1aab72b4b6903d66468782ca8d210f2edf7df97fd69e9ddeb845940247281c3`
- `mex-files/hist2a__78_mex.mexw64`: `f6a04c3b1878cd6c7336f27c91ccd018887064d472f60e6fff443c51851333f3`
- `mex-files/hist2a__80_mex.mexw64`: `2cdbe8a83cba968dc5dbce80112aa5d32c71f164674d595564e5fb4fa175ce5d`
- `mex-files/hist2a__84_mex.mexw64`: `5d7c8cf575fc5a361293da0424b1c5946125b1b6e47aec702d0ae61394180fab`
- `mex-files/hist2a__88_mex.mexw64`: `2826e4c299cb242a5d8e739d3678d764832add50ad2bb20c03888fe15a36a387`
- `mex-files/hist2a__90_mex.mexw64`: `a1772346a17907d59bc75d8810b685509fe1424c6dfdb4885fdfabf9b71f4397`
- `mex-files/hist2a__92_mex.mexw64`: `0dea077a249aaa4718b609614049d5f0e44a7cc336955808154ad80c32a0342b`
- `mex-files/hist2a__96_mex.mexw64`: `796910b60abfcdd553afde8cd2b17e1d5324ac3536770d007189209755858290`
- `mex-files/hista_100_mex.mexw64`: `df5794f90d68750909f4f9138c0c526617b7c363ac6458680ee7cc55b8327ab4`
- `mex-files/hista_102_mex.mexw64`: `a487d716406093388fca31545e486e5aaeb55ed3b3c0d773845604cdd87445a1`
- `mex-files/hista_104_mex.mexw64`: `6e677862629aa2f398894b4f947da563ca4d1b0fdaecaaed3c53b4efb48efa16`
- `mex-files/hista_108_mex.mexw64`: `5f6cf19fbb5b23772dc2e22f2e77b1b1fd3ac3a5dff667e3f9607fa63d398dca`
- `mex-files/hista_112_mex.mexw64`: `7de002d40044ce896cd1d9972bd69ae729d810c20dc5c6ef5440c2f8ebc522bf`
- `mex-files/hista_114_mex.mexw64`: `acee1976b71ea593c2b238abd8eb9d4dd95b03f461707a6551f76bc37af197df`
- `mex-files/hista_116_mex.mexw64`: `1e6eb82e487e3f13646433e1b120e044eead0e948d2c67f29408b17a1710e1f6`
- `mex-files/hista_120_mex.mexw64`: `67eaba01cbe80eb923440b26214fd6787cbcc7cb973b7695920b28f40676ada7`
- `mex-files/hista_124_mex.mexw64`: `fda9e2305266ee89d4858d2af554729ff7655a2066ddeb285d45a6b29c2aa193`
- `mex-files/hista_126_mex.mexw64`: `38634da81a1d146ed70d2a864de6c8515048091283830cbe2b1deaa172206432`
- `mex-files/hista_128_mex.mexw64`: `a4d1b8ed6f9f128b472683c3a3fa8700033dd5d86a319996fbe182c251627345`
- `mex-files/hista_132_mex.mexw64`: `d86e282cfa9833aa3a7d0f51a529dd99a5df628d63d961e102df8788d431c7d8`
- `mex-files/hista__68_mex.mexw64`: `b6b4147c00fd1cdd470852117234ca2f3e675ddea8c322059d57f2d0dd0d30f7`
- `mex-files/hista__72_mex.mexw64`: `15555f2d3bebc3a095f7e7cdf039bc1423d184a6e49b58d69639b61088eee74b`
- `mex-files/hista__76_mex.mexw64`: `f66399a62acb18c896b35ceaa4630edbd02771a456d83b71a9c329713598d897`
- `mex-files/hista__78_mex.mexw64`: `e338a88a32844192484b60b080da934c104b3b5938ab240a2725e13ed980eeeb`
- `mex-files/hista__80_mex.mexw64`: `ebe1d8e3232933d70a71baa8720e86cf06eafd1c340da22ade481b3ae6dce596`
- `mex-files/hista__84_mex.mexw64`: `03e10b87e7ad81949805ac0df2ad9ba9c3dd690ac9a9774153fff6f78b52c855`
- `mex-files/hista__88_mex.mexw64`: `f12b5fdd372098856daa26c283d5b049f93f57b891be5333569562c88c9d1b02`
- `mex-files/hista__90_mex.mexw64`: `270f94705041fac4f43b9f1ecc29a9ee4368b72fb684a0ddf7de3d90747fffd8`
- `mex-files/hista__92_mex.mexw64`: `59058a73f7f9baa729e693673b16d6344cd3f8aacb041a012cac357204e933f0`
- `mex-files/hista__96_mex.mexw64`: `5c21f21fe546c8854f47fc0d100e2143e40d56ce954cfe229040102c7f9d3d83`
- `mex-files/minf_mex.mexw64`: `622d1fe10dc97bbf4963e836e2762c367cd920a2d837b600a4553e76ca90d815`
- `mi.m`: `4bc31498cc1a7e48f982b574adc6d3b16cf8a46b7518aa9c8b02bfec168981af`
- `minf.m`: `86fc9cccbd0da60e54cc8ed4bf93e2f2b92f3db025763918f12732f977819c92`
- `powerspectrum.m`: `a89e231b57b54247af0f05eb644a87b3b31e276df73d907b2dab3c91cb4b0097`
- `removeArtifactsOnlineWavessobi.m`: `9fb3870753e4e204ffd9da8d527a803c558f36e113cf5935a2594ae8687e9364`
- `sobi_FAST.m`: `8d5475b7fce3a2af5cc994df2e8a26f61f8f297ec5411cc29a0a9f708e7682b3`

# Hippocampal Subfields & Amygdala Nuclei Atlas

FreeSurfer segmentation of the hippocampal subfields (Iglesias et al.
2015) and the nuclei of the amygdala (Saygin et al. 2017), as produced
by `segment_subregions hippo-amygdala`. Built from the `cvs_avg35`
template segmentation embedded in fsaverage5's full aseg, so slice views
show the subregions inside cerebral cortex and white matter (rendered
grey as anatomical context), surrounded by the neighbouring subcortical
structures. Region colours come from FreeSurfer's official LUT.

## Usage

``` r
hippoamyg()
```

## Value

A
[ggseg.formats::ggseg_atlas](https://ggsegverse.github.io/ggseg.formats/reference/ggseg_atlas.html)
object (subcortical).

## References

Iglesias JE, Augustinack JC, Nguyen K, Player CM, Player A, Wright M,
Roy N, Frosch MP, McKee AC, Wald LL, Fischl B, Van Leemput K (2015). "A
computational atlas of the hippocampal formation using ex vivo,
ultra-high resolution MRI: Application to adaptive segmentation of in
vivo MRI." *NeuroImage*, 115:117-137.
[doi:10.1016/j.neuroimage.2015.04.042](https://doi.org/10.1016/j.neuroimage.2015.04.042)

Saygin ZM, Kliemann D, Iglesias JE, van der Kouwe AJW, Boyd E, Reuter M,
Stevens A, Van Leemput K, McKee A, Frosch MP, Fischl B, Augustinack JC
(2017). "High-resolution magnetic resonance imaging reveals nuclei of
the human amygdala: manual segmentation to automatic atlas."
*NeuroImage*, 155:370-382.
[doi:10.1016/j.neuroimage.2017.04.046](https://doi.org/10.1016/j.neuroimage.2017.04.046)

## See also

Other ggseg_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

Other subcortical_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

Other freesurfer_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

## Examples

``` r
hippoamyg()
#> 
#> ── hippoamyg ggseg atlas ───────────────────────────────────────────────────────
#> Type: subcortical
#> Regions: 28
#> Hemispheres: left, right
#> Views: axial_1, axial_2, coronal_1, coronal_2
#> Palette: ✔
#> Rendering: ✔ ggseg
#> ✔ ggseg3d (meshes)
#> ────────────────────────────────────────────────────────────────────────────────
#>    hemi              region                    label
#> 1  left       parasubiculum       Left-parasubiculum
#> 2  left                hata                Left-HATA
#> 3  left             fimbria             Left-fimbria
#> 4  left hippocampal fissure Left-hippocampal_fissure
#> 5  left             hp tail             Left-HP_tail
#> 6  left   presubiculum head   Left-presubiculum-head
#> 7  left   presubiculum body   Left-presubiculum-body
#> 8  left      subiculum head      Left-subiculum-head
#> 9  left      subiculum body      Left-subiculum-body
#> 10 left            ca1 head            Left-CA1-head
#> ... with 46 more rows
```

# Thalamic Nuclei Atlas

Probabilistic atlas of the 26 thalamic nuclei per hemisphere combining
ex vivo MRI and histology, as implemented in FreeSurfer's
`segmentThalamicNuclei.sh` (Iglesias et al. 2018). Built from the
`cvs_avg35` template segmentation embedded in its full-brain aseg, so
slice views show the thalamus inside cerebral cortex and white matter
(rendered grey as anatomical context). Nucleus colours come from
FreeSurfer's official LUT — the published Iglesias palette.

## Usage

``` r
thalamus()
```

## Value

A
[ggseg.formats::ggseg_atlas](https://ggsegverse.github.io/ggseg.formats/reference/ggseg_atlas.html)
object (subcortical).

## References

Iglesias JE, Insausti R, Lerma-Usabiaga G, Bocchetta M, Van Leemput K,
Greve D, van der Kouwe A, Caballero-Gaudes C, Paz-Alonso P (2018). "A
probabilistic atlas of the human thalamic nuclei combining ex vivo MRI
and histology." *NeuroImage*, 183:314-326.
[doi:10.1016/j.neuroimage.2018.08.012](https://doi.org/10.1016/j.neuroimage.2018.08.012)

## See also

Other ggseg_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md)

Other subcortical_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md)

Other freesurfer_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md)

## Examples

``` r
thalamus()
#> 
#> ── thalamus ggseg atlas ────────────────────────────────────────────────────────
#> Type: subcortical
#> Regions: 26
#> Hemispheres: left, right
#> Views: axial_4, coronal_1, coronal_2, coronal_3
#> Palette: ✔
#> Rendering: ✔ ggseg
#> ✔ ggseg3d (meshes)
#> ────────────────────────────────────────────────────────────────────────────────
#>    hemi region     label
#> 1  left     av   Left-AV
#> 2  left    cem  Left-CeM
#> 3  left     cl   Left-CL
#> 4  left     cm   Left-CM
#> 5  left     ld   Left-LD
#> 6  left    lgn  Left-LGN
#> 7  left     lp   Left-LP
#> 8  left   l sg Left-L-Sg
#> 9  left    mdl  Left-MDl
#> 10 left    mdm  Left-MDm
#> ... with 42 more rows
```

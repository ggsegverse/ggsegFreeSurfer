# Hypothalamic Subunits Atlas

Atlas of the five FreeSurfer hypothalamic subunits per hemisphere
(anterior-inferior, anterior-superior, posterior, tubular-inferior and
tubular-superior), as implemented in FreeSurfer's
`mri_segment_hypothalamic_subunits` (Billot et al. 2020). Built from the
`cvs_avg35` template segmentation embedded in its full-brain aseg, so
slice views show the hypothalamus inside cerebral cortex and white
matter (rendered grey as anatomical context). Subunit colours come from
FreeSurfer's official LUT.

## Usage

``` r
hypothalamus()
```

## Value

A
[ggseg.formats::ggseg_atlas](https://ggsegverse.github.io/ggseg.formats/reference/ggseg_atlas.html)
object (subcortical).

## References

Billot B, Bocchetta M, Todd E, Dalca AV, Rohrer JD, Iglesias JE (2020).
"Automated segmentation of the hypothalamus and associated subunits in
brain MRI." *NeuroImage*, 223:117287.
[doi:10.1016/j.neuroimage.2020.117287](https://doi.org/10.1016/j.neuroimage.2020.117287)

## See also

Other ggseg_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

Other subcortical_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

Other freesurfer_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

## Examples

``` r
hypothalamus()
#> 
#> ── hypothalamus ggseg atlas ────────────────────────────────────────────────────
#> Type: subcortical
#> Regions: 5
#> Hemispheres: left, right
#> Views: axial_1, axial_2, coronal_1, coronal_2
#> Palette: ✔
#> Rendering: ✔ ggseg
#> ✔ ggseg3d (meshes)
#> ────────────────────────────────────────────────────────────────────────────────
#>     hemi                         region                            label
#> 1   left hypothalamus anterior inferior L_hypothalamus_anterior_inferior
#> 2   left hypothalamus anterior superior L_hypothalamus_anterior_superior
#> 3   left         hypothalamus posterior         L_hypothalamus_posterior
#> 4   left  hypothalamus tubular inferior  L_hypothalamus_tubular_inferior
#> 5   left  hypothalamus tubular superior  L_hypothalamus_tubular_superior
#> 6  right hypothalamus anterior inferior R_hypothalamus_anterior_inferior
#> 7  right hypothalamus anterior superior R_hypothalamus_anterior_superior
#> 8  right         hypothalamus posterior         R_hypothalamus_posterior
#> 9  right  hypothalamus tubular inferior  R_hypothalamus_tubular_inferior
#> 10 right  hypothalamus tubular superior  R_hypothalamus_tubular_superior
```

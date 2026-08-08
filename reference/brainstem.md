# Brainstem Substructures Atlas

Atlas of the four FreeSurfer brainstem substructures (midbrain, pons,
medulla oblongata and superior cerebellar peduncle), as implemented in
FreeSurfer's `segment_subregions brainstem` (Iglesias et al. 2015).
Built from the `cvs_avg35` template segmentation embedded in its
full-brain aseg, so slice views show the brainstem inside cerebral
cortex and white matter (rendered grey as anatomical context).
Substructure colours come from FreeSurfer's official LUT.

## Usage

``` r
brainstem()
```

## Value

A
[ggseg.formats::ggseg_atlas](https://ggsegverse.github.io/ggseg.formats/reference/ggseg_atlas.html)
object (subcortical).

## References

Iglesias JE, Van Leemput K, Bhatt P, Casillas C, Dutt S, Schuff N,
Truran-Sacrey D, Boxer A, Fischl B (2015). "Bayesian segmentation of
brainstem structures in MRI." *NeuroImage*, 113:184-195.
[doi:10.1016/j.neuroimage.2015.02.065](https://doi.org/10.1016/j.neuroimage.2015.02.065)

## See also

Other ggseg_atlases:
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

Other subcortical_atlases:
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

Other freesurfer_atlases:
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

## Examples

``` r
brainstem()
#> 
#> ── brainstem ggseg atlas ───────────────────────────────────────────────────────
#> Type: subcortical
#> Regions: 4
#> Hemispheres: NA
#> Views: sagittal_1, axial_3, coronal_1
#> Palette: ✔
#> Rendering: ✔ ggseg
#> ✔ ggseg3d (meshes)
#> ────────────────────────────────────────────────────────────────────────────────
#>   hemi   region    label
#> 1 <NA> midbrain Midbrain
#> 2 <NA>     pons     Pons
#> 3 <NA>  medulla  Medulla
#> 4 <NA>      scp      SCP
```

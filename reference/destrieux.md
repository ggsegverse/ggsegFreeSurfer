# Destrieux Cortical Atlas

Brain atlas for the Destrieux cortical parcellation (aparc.a2009s) with
75 regions per hemisphere. Contains 2D polygon geometry for
[`ggseg::geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.html).

## Usage

``` r
destrieux()
```

## Value

A
[ggseg.formats::ggseg_atlas](https://ggsegverse.github.io/ggseg.formats/reference/ggseg_atlas.html)
object (cortical).

## References

Destrieux C, Fischl B, Dale A, Halgren E (2010). Automatic parcellation
of human cortical gyri and sulci using standard anatomical nomenclature.
*NeuroImage*, 53(1), 1-15.
[doi:10.1016/j.neuroimage.2010.06.010](https://doi.org/10.1016/j.neuroimage.2010.06.010)

## See also

Other ggseg_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

Other cortical_atlases:
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md)

Other freesurfer_atlases:
[`brainstem()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/brainstem.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md),
[`hippoamyg()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hippoamyg.md),
[`hypothalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hypothalamus.md),
[`thalamus()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/thalamus.md)

## Examples

``` r
destrieux()
#> 
#> ── destrieux ggseg atlas ───────────────────────────────────────────────────────
#> Type: cortical
#> Regions: 74
#> Hemispheres: left, right
#> Views: inferior, lateral, superior, medial
#> Palette: ✔
#> Rendering: ✔ ggseg
#> ✔ ggseg3d (vertices)
#> ────────────────────────────────────────────────────────────────────────────────
#>    hemi                   region                       label
#> 1  left     G_and_S_frontomargin     lh_G_and_S_frontomargin
#> 2  left    G_and_S_occipital_inf    lh_G_and_S_occipital_inf
#> 3  left      G_and_S_paracentral      lh_G_and_S_paracentral
#> 4  left       G_and_S_subcentral       lh_G_and_S_subcentral
#> 5  left G_and_S_transv_frontopol lh_G_and_S_transv_frontopol
#> 6  left       G_and_S_cingul-Ant       lh_G_and_S_cingul-Ant
#> 7  left   G_and_S_cingul-Mid-Ant   lh_G_and_S_cingul-Mid-Ant
#> 8  left  G_and_S_cingul-Mid-Post  lh_G_and_S_cingul-Mid-Post
#> 9  left     G_cingul-Post-dorsal     lh_G_cingul-Post-dorsal
#> 10 left    G_cingul-Post-ventral    lh_G_cingul-Post-ventral
#> ... with 138 more rows
plot(destrieux())
```

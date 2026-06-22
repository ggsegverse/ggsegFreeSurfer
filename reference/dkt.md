# Desikan-Killiany-Tourville Cortical Atlas

Cortical parcellation with 32 regions per hemisphere based on the
Desikan-Killiany-Tourville labeling protocol. Contains both 2D polygon
geometry for
[`ggseg::geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.html)
and 3D vertex indices for
[`ggseg3d::ggseg3d()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d.html).

## Usage

``` r
dkt()
```

## Value

A
[ggseg.formats::ggseg_atlas](https://ggsegverse.github.io/ggseg.formats/reference/ggseg_atlas.html)
object (cortical).

## References

Klein A, Tourville J (2012). 101 labeled brain images and a consistent
human cortical labeling protocol. *Frontiers in Neuroscience*, 6:171.
[doi:10.3389/fnins.2012.00171](https://doi.org/10.3389/fnins.2012.00171)

## See also

Other ggseg_atlases:
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md)

Other cortical_atlases:
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md)

Other freesurfer_atlases:
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md)

## Examples

``` r
dkt()
#> 
#> ── dkt ggseg atlas ─────────────────────────────────────────────────────────────
#> Type: cortical
#> Regions: 31
#> Hemispheres: left, right
#> Views: inferior, lateral, medial, superior
#> Palette: ✔
#> Rendering: ✔ ggseg
#> ✔ ggseg3d (vertices)
#> ────────────────────────────────────────────────────────────────────────────────
#>    hemi                  region                      label
#> 1  left caudalanteriorcingulate lh_caudalanteriorcingulate
#> 2  left     caudalmiddlefrontal     lh_caudalmiddlefrontal
#> 3  left                  cuneus                  lh_cuneus
#> 4  left              entorhinal              lh_entorhinal
#> 5  left                fusiform                lh_fusiform
#> 6  left        inferiorparietal        lh_inferiorparietal
#> 7  left        inferiortemporal        lh_inferiortemporal
#> 8  left        isthmuscingulate        lh_isthmuscingulate
#> 9  left        lateraloccipital        lh_lateraloccipital
#> 10 left    lateralorbitofrontal    lh_lateralorbitofrontal
#> ... with 52 more rows
plot(dkt())
```

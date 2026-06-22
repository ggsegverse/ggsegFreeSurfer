# HCP Subcortical Atlas

Human Connectome Project subcortical atlas with aseg regions and
anterior/posterior hippocampus subdivisions. Contains 3D mesh geometry
for
[`ggseg3d::ggseg3d()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d.html).

## Usage

``` r
hcpa()
```

## Value

A
[ggseg.formats::ggseg_atlas](https://ggsegverse.github.io/ggseg.formats/reference/ggseg_atlas.html)
object (subcortical).

## See also

Other ggseg_atlases:
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md)

Other freesurfer_atlases:
[`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
[`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md)

## Examples

``` r
hcpa()
#> 
#> ── hcpa ggseg atlas ────────────────────────────────────────────────────────────
#> Type: subcortical
#> Regions: 34
#> Hemispheres: subcort
#> Palette: ✔
#> Rendering: ✖ ggseg
#> ✔ ggseg3d (meshes)
#> ────────────────────────────────────────────────────────────────────────────────
#>       hemi                       region                        label
#> 1  subcort       Left-Lateral-Ventricle       Left-Lateral-Ventricle
#> 2  subcort            Left-Inf-Lat-Vent            Left-Inf-Lat-Vent
#> 3  subcort Left-Cerebellum-White-Matter Left-Cerebellum-White-Matter
#> 4  subcort       Left-Cerebellum-Cortex       Left-Cerebellum-Cortex
#> 5  subcort         Left-Thalamus-Proper         Left-Thalamus-Proper
#> 6  subcort                 Left-Caudate                 Left-Caudate
#> 7  subcort                 Left-Putamen                 Left-Putamen
#> 8  subcort                Left-Pallidum                Left-Pallidum
#> 9  subcort                3rd-Ventricle                3rd-Ventricle
#> 10 subcort                4th-Ventricle                4th-Ventricle
#> ... with 24 more rows
```

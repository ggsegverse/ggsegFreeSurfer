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
#> # A tibble: 34 × 3
#>    hemi    region                        label                        
#>    <chr>   <chr>                         <chr>                        
#>  1 subcort Left-Lateral-Ventricle        Left-Lateral-Ventricle       
#>  2 subcort Left-Inf-Lat-Vent             Left-Inf-Lat-Vent            
#>  3 subcort Left-Cerebellum-White-Matter  Left-Cerebellum-White-Matter 
#>  4 subcort Left-Cerebellum-Cortex        Left-Cerebellum-Cortex       
#>  5 subcort Left-Thalamus-Proper          Left-Thalamus-Proper         
#>  6 subcort Left-Caudate                  Left-Caudate                 
#>  7 subcort Left-Putamen                  Left-Putamen                 
#>  8 subcort Left-Pallidum                 Left-Pallidum                
#>  9 subcort 3rd-Ventricle                 3rd-Ventricle                
#> 10 subcort 4th-Ventricle                 4th-Ventricle                
#> 11 subcort Brain-Stem                    Brain-Stem                   
#> 12 subcort Left-Amygdala                 Left-Amygdala                
#> 13 subcort Left-Accumbens-area           Left-Accumbens-area          
#> 14 subcort Left-VentralDC                Left-VentralDC               
#> 15 subcort Right-Lateral-Ventricle       Right-Lateral-Ventricle      
#> 16 subcort Right-Inf-Lat-Vent            Right-Inf-Lat-Vent           
#> 17 subcort Right-Cerebellum-White-Matter Right-Cerebellum-White-Matter
#> 18 subcort Right-Cerebellum-Cortex       Right-Cerebellum-Cortex      
#> 19 subcort Right-Thalamus-Proper         Right-Thalamus-Proper        
#> 20 subcort Right-Caudate                 Right-Caudate                
#> 21 subcort Right-Putamen                 Right-Putamen                
#> 22 subcort Right-Pallidum                Right-Pallidum               
#> 23 subcort Right-Amygdala                Right-Amygdala               
#> 24 subcort Right-Accumbens-area          Right-Accumbens-area         
#> 25 subcort Right-VentralDC               Right-VentralDC              
#> 26 subcort Right-Hippocampus.ant         Right-Hippocampus.ant        
#> 27 subcort Right-Hippocampus.post        Right-Hippocampus.post       
#> 28 subcort CC_Posterior                  CC_Posterior                 
#> 29 subcort CC_Mid_Posterior              CC_Mid_Posterior             
#> 30 subcort CC_Central                    CC_Central                   
#> 31 subcort CC_Mid_Anterior               CC_Mid_Anterior              
#> 32 subcort CC_Anterior                   CC_Anterior                  
#> 33 subcort Left-Hippocampus.ant          Left-Hippocampus.ant         
#> 34 subcort Left-Hippocampus.post         Left-Hippocampus.post        
```

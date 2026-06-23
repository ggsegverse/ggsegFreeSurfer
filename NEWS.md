# ggsegFreeSurfer 1.0.1.9000

- Added `thalamus()`, a subcortical atlas of the 26 thalamic nuclei per
  hemisphere (Iglesias et al. 2018)
- Added `hippoamyg()`, a subcortical atlas of the hippocampal subfields
  (Iglesias et al. 2015) and amygdala nuclei (Saygin et al. 2017)
- Added `brainstem()`, a subcortical atlas of the four brainstem
  substructures: midbrain, pons, medulla and superior cerebellar peduncle
  (Iglesias et al. 2015)
- Added `hypothalamus()`, a subcortical atlas of the five hypothalamic
  subunits per hemisphere (Billot et al. 2020)
- `hcpa()` is now a focused anterior/posterior hippocampus atlas with 2D
  slice geometry (left/right × anterior/posterior), regenerated from the
  `fsaverage5` aseg. It previously carried only 3D meshes and could not be
  `plot()`ted
- The new atlases ship directly in the sf-optional `brain_polygons` format
  introduced in 1.0.1, so they render without `sf`
- Subcortical 2D layouts trimmed to their most informative slices (`brainstem`
  to 3 views, `hcpa` to 2, `hypothalamus` to 4) and the grey anatomical context
  geometry simplified, for clearer plots and smaller bundled data

# ggsegFreeSurfer 1.0.1

- Atlas 2D geometry migrated to the sf-optional `brain_polygons` format
  (`ggseg.formats` 0.0.3). The atlases now render without `sf` and its
  GDAL/GEOS/PROJ system libraries, enabling wasm and air-gapped installs.
  Plots are unchanged.

# ggsegFreeSurfer 1.0.0

- Initial release bundling FreeSurfer atlases from `ggsegDKT`,
  `ggsegDestrieux`, and `ggsegDefaultExtra`
- Includes `dkt()`, `destrieux()`, and `hcpa()` atlas accessors
- `dkextra()` has been removed

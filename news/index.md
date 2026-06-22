# Changelog

## ggsegFreeSurfer 1.0.1

- Atlas 2D geometry migrated to the sf-optional `brain_polygons` format
  (`ggseg.formats` 0.0.3). The atlases now render without `sf` and its
  GDAL/GEOS/PROJ system libraries, enabling wasm and air-gapped
  installs. Plots are unchanged.

## ggsegFreeSurfer 1.0.0

- Initial release bundling FreeSurfer atlases from `ggsegDKT`,
  `ggsegDestrieux`, and `ggsegDefaultExtra`
- Includes
  [`dkt()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/dkt.md),
  [`destrieux()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/destrieux.md),
  and
  [`hcpa()`](https://ggsegverse.github.io/ggsegFreeSurfer/reference/hcpa.md)
  atlas accessors
- `dkextra()` has been removed

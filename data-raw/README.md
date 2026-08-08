# ggsegFreeSurfer — atlas provenance and build prerequisites

These notes record the **one-time, maintainer-only** external steps used to build the
atlas objects in `R/sysdata.rda`. End users install the built package and never run any
of this — the atlases ship as data and render with `ggseg` / `ggseg3d` alone (pure R).

Atlas _creation_ (volume → meshes → 2D `brain_polygons` → `ggseg_atlas`) is handled
entirely in R by `ggseg.extra::create_subcortical_from_volume()`. The only external
tools are **FreeSurfer** binaries used to produce the source segmentation volumes.

## External prerequisites

FreeSurfer 7.4.1 with `FREESURFER_HOME` set and the `cvs_avg35` subject available
(ships `mri/norm.mgz`, used as the template all atlases are registered into).

| Atlas              | Source segmentation                                                   | Tool                                                           | Kind                                                       |
| ------------------ | --------------------------------------------------------------------- | -------------------------------------------------------------- | ---------------------------------------------------------- |
| `destrieux`, `dkt` | `aparc.a2009s` / `aparc.DKTatlas` annotations resampled to fsaverage5 | `mri_surf2surf`                                                | FS compiled binary                                         |
| `thalamus`         | `ThalamicNuclei.mgz`                                                  | `segment_subregions thalamus --cross cvs_avg35`                | FS tool → **bundled TensorFlow CNN** (Iglesias 2018)       |
| `hippoamyg`        | `hippoAmygLabels` (per hemi)                                          | `segment_subregions hippo-amygdala --cross cvs_avg35`          | FS tool → **bundled TF CNN** (Iglesias 2015 / Saygin 2017) |
| `brainstem`        | `brainstemSsLabels.mgz`                                               | `segment_subregions brainstem --cross cvs_avg35`               | FS tool → **bundled TF CNN** (Iglesias 2015)               |
| `hypothalamus`     | `hypothalamic_subunits.mgz`                                           | `mri_segment_hypothalamic_subunits --i cvs_avg35/mri/norm.mgz` | FS tool → **bundled TF CNN** (Billot 2020)                 |
| `hcpa`             | anterior/posterior split of the aseg hippocampus                      | — (pure R, RAS-y median split)                                 | R only                                                     |

## Note on Python

ggsegverse deliberately keeps atlas creation in **pure R + FreeSurfer binaries**;
`ggseg.extra` contains no Python and no `reticulate`. The `segment_subregions` and
`mri_segment_hypothalamic_subunits` tools above are FreeSurfer **bash wrappers** that
internally run FreeSurfer's own bundled Python/TensorFlow networks — an implementation
detail of FreeSurfer, treated here as an external prerequisite exactly like `recon-all`.
They run once, on the maintainer's machine, to generate the input `.mgz` volumes; the
make scripts then only `stopifnot(file.exists(...))` and proceed in R.

(On Apple Silicon FreeSurfer's bundled TensorFlow can crash on AVX; run the segmentation
network under an arm64-native Python/TensorFlow environment. This affects only the
one-time segmentation step, not the R atlas-creation pipeline.)

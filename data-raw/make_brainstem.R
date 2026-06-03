# Create Brainstem Substructures Atlas (Iglesias et al. 2015) on fsaverage5
#
# Builds a ggseg atlas of the FreeSurfer brainstem substructures
# (midbrain, pons, medulla, superior cerebellar peduncle) embedded in
# fsaverage5's full aseg, so the brain context matches the other
# FreeSurfer atlases in this package (which all derive from fsaverage5).
#
# Why fsaverage5 + registration:
#   `segment_subregions brainstem` needs `norm.mgz`, which fsaverage5
#   does not ship with. cvs_avg35 does, so we run the segmentation there
#   and bring the result across to fsaverage5 via the talairach.xfm affine
#   (fsaverage5 is already in MNI305/talairach, so its own talairach.xfm
#   is identity — the registration is just cvs_avg35's talairach.xfm
#   applied to the subregion volume). This mirrors make_thalamus.R.
#
# Hemisphere handling:
#   The brainstem is an unpaired midline structure; the substructures
#   carry no Left-/Right- prefix and use the standard FreeSurferColorLUT
#   ids directly (173 Midbrain, 174 Pons, 175 Medulla, 178 SCP), so no
#   custom LUT or label remapping is needed (unlike make_hippoamyg.R).
#
# Inputs (must be generated outside R first):
#   1. cvs_avg35's recon-all (ships with FreeSurfer).
#   2. fsaverage5's recon-all (ships with FreeSurfer).
#   3. brainstemSsLabels.mgz from
#      `segment_subregions brainstem --cross cvs_avg35
#       --sd $FREESURFER_HOME/subjects
#       --out-dir data-raw/cvs_avg35_brainstem`.
#
# This script:
#   a) Registers the cvs_avg35 brainstem segmentation into fsaverage5
#      space using cvs_avg35's talairach.xfm.
#   b) Stamps the substructure labels into fsaverage5's full aseg,
#      replacing the lumped Brain-Stem (16) label.
#   c) Hands the combined volume to ggseg.extra's pipeline using the
#      standard FreeSurferColorLUT.txt.
#   d) Removes White-Matter, ventricles, CSF and similar polygons
#      post-build, punches the white matter out of the cortex silhouette,
#      and keeps the neighbouring subcortical structures as context.
#   e) Applies atlas_smooth() to tidy the 2D contours.
#
# Reference: Iglesias JE, et al. (2015). "Bayesian segmentation of
#   brainstem structures in MRI." NeuroImage, 113:184-195.
#   DOI: 10.1016/j.neuroimage.2015.02.065
#
# Run with: Rscript data-raw/make_brainstem.R

library(dplyr)
library(ggseg.extra)
library(ggseg.formats)

options(chromote.timeout = 120)
future::plan(future::sequential)
progressr::handlers("cli")
progressr::handlers(global = TRUE)

data_raw <- here::here("data-raw")
fs_home <- Sys.getenv("FREESURFER_HOME", "/Applications/freesurfer/7.4.1")
cvs_subj <- file.path(fs_home, "subjects/cvs_avg35")
fs5_subj <- file.path(fs_home, "subjects/fsaverage5")

seg_dir <- file.path(data_raw, "cvs_avg35_brainstem")
cvs_bs <- file.path(seg_dir, "brainstemSsLabels.mgz")
fs5_aseg <- file.path(fs5_subj, "mri/aseg.mgz")
cvs_tal_xfm <- file.path(cvs_subj, "mri/transforms/talairach.xfm")
lut_file <- file.path(fs_home, "FreeSurferColorLUT.txt")

seg_file <- file.path(data_raw, "BrainstemSs_fs5_brain.nii.gz")

# Substructure label ids in the standard LUT.
BS_LABELS <- c(173L, 174L, 175L, 178L)

stopifnot(
  "cvs_avg35 brainstemSsLabels.mgz not found (run segment_subregions first)" = file.exists(
    cvs_bs
  ),
  "fsaverage5 aseg.mgz not found" = file.exists(fs5_aseg),
  "cvs_avg35 talairach.xfm not found" = file.exists(cvs_tal_xfm),
  "FreeSurferColorLUT.txt not found" = file.exists(lut_file)
)

fs <- function(...) {
  bin <- file.path(fs_home, "bin")
  system2(file.path(bin, ..1), c(...)[-1], stdout = FALSE, stderr = FALSE)
}

# ── 1. Register cvs_avg35 brainstem labels into fsaverage5 space ─────────
bs_fs5_mgz <- file.path(data_raw, "fs5_brainstem/brainstemSs_fs5.mgz")
if (!file.exists(bs_fs5_mgz) || file.mtime(bs_fs5_mgz) < file.mtime(cvs_bs)) {
  dir.create(dirname(bs_fs5_mgz), showWarnings = FALSE, recursive = TRUE)
  cli::cli_alert_info("Registering brainstem labels: cvs_avg35 → fsaverage5")
  fs(
    "mri_vol2vol",
    "--mov",
    cvs_bs,
    "--targ",
    fs5_aseg,
    "--xfm",
    cvs_tal_xfm,
    "--o",
    bs_fs5_mgz,
    "--nearest"
  )
}

# ── 2. Build embedded volume: fs5 aseg + brainstem substructures ─────────
build_embedded_volume <- function(aseg_path, bs_path, out_path) {
  cli::cli_alert_info("Embedding brainstem substructures in fsaverage5 aseg")

  aseg_nii <- file.path(tempdir(), "fs5_aseg.nii.gz")
  bs_nii <- file.path(tempdir(), "bs_fs5.nii.gz")
  fs("mri_convert", "-ot", "nii", aseg_path, aseg_nii)
  fs("mri_convert", "-ot", "nii", bs_path, bs_nii)

  aseg <- RNifti::readNifti(aseg_nii)
  bs <- RNifti::readNifti(bs_nii)
  out <- as.integer(round(aseg))
  dim(out) <- dim(aseg)

  # Drop the lumped brainstem so only the substructures remain.
  out[out == 16L] <- 0L

  bs <- as.integer(round(bs))
  bs_mask <- bs %in% BS_LABELS
  out[bs_mask] <- bs[bs_mask]

  RNifti::writeNifti(out, out_path, template = aseg_nii, datatype = "int32")
  invisible(out)
}

if (
  !file.exists(seg_file) ||
    file.mtime(seg_file) < max(file.mtime(c(fs5_aseg, bs_fs5_mgz)))
) {
  out_vol <- build_embedded_volume(fs5_aseg, bs_fs5_mgz, seg_file)
} else {
  cli::cli_alert_success("Reusing existing {.path {basename(seg_file)}}")
  out_vol <- as.integer(round(RNifti::readNifti(seg_file)))
  dim(out_vol) <- dim(RNifti::readNifti(seg_file))
}

# ── 3. Derive slice views from the substructure bounding box ─────────────
# The view slabs must be indexed in the same axis frame the pipeline
# projects in. ggseg.extra's read_volume() reorients the NIfTI relative to
# RNifti (it swaps/flips the A/P and I/S axes), so we compute the bounding
# box from read_volume()'s output rather than the RNifti array used for the
# embedding. In that frame dim1 indexes sagittal, dim2 coronal, dim3 axial.
# The brainstem long axis runs I/S, with midbrain (superior) → pons →
# medulla (inferior) stacked, so a midline sagittal slab carries all four
# substructures; axial slabs separate them by height.
proj_vol <- ggseg.extra:::read_volume(seg_file)
sub_mask <- array(proj_vol %in% BS_LABELS, dim = dim(proj_vol))
idx <- which(sub_mask, arr.ind = TRUE)
xr <- range(idx[, 1])
yr <- range(idx[, 2])
zr <- range(idx[, 3])
xc <- round(mean(idx[, 1]))

slab <- function(lo, hi, n, type, prefix) {
  edges <- round(seq(lo, hi, length.out = n + 1))
  do.call(
    rbind,
    lapply(seq_len(n), function(i) {
      data.frame(
        name = sprintf("%s_%d", prefix, i),
        type = type,
        start = edges[i],
        end = max(edges[i] + 1, edges[i + 1] - 1)
      )
    })
  )
}

# Midline sagittal slab spanning the brainstem's L/R thickness, plus axial
# slabs through the I/S extent and a couple of coronal slabs.
views <- rbind(
  data.frame(
    name = "sagittal_1",
    type = "sagittal",
    start = xr[1],
    end = xr[2]
  ),
  slab(zr[1], zr[2], 3, "axial", "axial"),
  slab(yr[1], yr[2], 2, "coronal", "coronal")
)
cli::cli_alert_info("Views:")
print(views)

# ── 4. Build the ggseg atlas ────────────────────────────────────────────
cli::cli_h1("Creating brainstem substructures atlas")

bs_raw <- create_subcortical_from_volume(
  input_volume = seg_file,
  input_lut = lut_file,
  atlas_name = "brainstem",
  views = views,
  output_dir = data_raw,
  skip_existing = TRUE,
  cleanup = FALSE
)

# Punch the cerebral white matter out of the brain silhouette so slices
# show the cortical ribbon with the white-matter interior as a hole rather
# than one solid grey blob (see make_hippoamyg.R for the rationale). Must
# run before White-Matter is removed below.
bs_raw <- atlas_region_op(
  bs_raw,
  x = "^cortex",
  y = "White-Matter$",
  action = "difference",
  into = "cortex"
)

# ── 5. Post-process: drop polygons aseg doesn't show either ──────────────
cli::cli_h2("Post-processing atlas")

bs <- bs_raw |>
  atlas_region_remove("White-Matter", match_on = "label") |>
  atlas_region_remove("WM-hypointensities", match_on = "label") |>
  atlas_region_remove("-Ventricle", match_on = "label") |>
  atlas_region_remove("-Vent$", match_on = "label") |>
  atlas_region_remove("CSF", match_on = "label") |>
  atlas_region_remove("Cerebral-Cortex", match_on = "label") |>
  atlas_region_remove("choroid-plexus", match_on = "label") |>
  atlas_region_remove("vessel", match_on = "label") |>
  atlas_region_remove("CC_", match_on = "label") |>
  atlas_region_contextual(
    paste0(
      "Caudate|Putamen|Pallidum|Thalamus|Hippocampus|Amygdala|Accumbens",
      "|VentralDC|Cerebellum|Optic-Chiasm",
      "|unknown|Background"
    ),
    "label"
  )

# Drop slabs that contain only context (no substructure).
empty_views <- vapply(
  unique(bs$data$sf$view),
  function(v) {
    rows <- bs$data$sf[bs$data$sf$view == v, ]
    !any(rows$label %in% bs$core$label)
  },
  logical(1)
)
empty_views <- names(empty_views)[empty_views]
if (length(empty_views) > 0) {
  cli::cli_alert_info("Dropping context-only view{?s}: {.val {empty_views}}")
  bs <- atlas_view_remove(bs, empty_views)
}

bs <- bs |>
  atlas_view_gather() |>
  atlas_smooth(
    keep = NULL,
    smoothness = 3,
    exclude = "^cortex"
  )

# Cortex outline gets a heavier close so the silhouette reads smooth, plus
# light vertex simplification. smoothness is a morphological close — keep it
# low enough to preserve the anatomical ventricle/WM holes.
bs_2 <- atlas_smooth(
  bs,
  keep = 0.1,
  smoothness = 7,
  labels = "^cortex"
)
plot(bs_2)

cli::cli_alert_success("brainstem: {nrow(bs$core)} regions")
print(bs_2)

# ── 6. Save into sysdata.rda alongside the other atlases ─────────────────
sysdata_path <- here::here("R/sysdata.rda")
if (file.exists(sysdata_path)) {
  load(sysdata_path)
}

.brainstem <- bs_2

usethis::use_data(
  .dkt,
  .destrieux,
  .hcpa,
  .thalamus,
  .hippoamyg,
  .brainstem,
  .hypothalamus,
  overwrite = TRUE,
  compress = "xz",
  internal = TRUE
)

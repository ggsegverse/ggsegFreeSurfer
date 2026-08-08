# Create Hypothalamic Subunits Atlas (Billot et al. 2020) on fsaverage5
#
# Builds a ggseg atlas of the FreeSurfer hypothalamic subunits (anterior-
# inferior, anterior-superior, posterior, tubular-inferior, tubular-
# superior, per hemisphere) embedded in fsaverage5's full aseg, so the
# brain context matches the other FreeSurfer atlases in this package
# (which all derive from fsaverage5).
#
# Why fsaverage5 + registration:
#   `mri_segment_hypothalamic_subunits` runs on a conformed T1. We run it
#   on cvs_avg35's norm.mgz and bring the result across to fsaverage5 via
#   the talairach.xfm affine (fsaverage5 is already in MNI305/talairach,
#   so its own talairach.xfm is identity — the registration is just
#   cvs_avg35's talairach.xfm applied to the subunit volume). This mirrors
#   make_thalamus.R / make_brainstem.R.
#
# Hemisphere handling:
#   The subunits are bilateral and the standard FreeSurferColorLUT carries
#   L_/R_ prefixed names for ids 801-810, which ggseg.extra's hemisphere
#   detection reads directly, so no custom LUT or label remapping is needed
#   (unlike make_hippoamyg.R).
#
# Inputs (must be generated outside R first):
#   1. cvs_avg35's recon-all (ships with FreeSurfer).
#   2. fsaverage5's recon-all (ships with FreeSurfer).
#   3. hypothalamic_subunits.mgz from
#      `mri_segment_hypothalamic_subunits --i cvs_avg35/mri/norm.mgz
#       --o data-raw/cvs_avg35_hypothalamus/hypothalamic_subunits.mgz`.
#      (On Apple Silicon the bundled TensorFlow crashes on AVX; run the
#       script's network under an arm64-native Python/TensorFlow venv,
#       patching the one `np.float128` reference to `np.float64`.)
#
# This script:
#   a) Registers the cvs_avg35 hypothalamic segmentation into fsaverage5
#      space using cvs_avg35's talairach.xfm.
#   b) Stamps the subunit labels into fsaverage5's full aseg (they fall
#      within the ventral diencephalon).
#   c) Hands the combined volume to ggseg.extra's pipeline using the
#      standard FreeSurferColorLUT.txt.
#   d) Removes White-Matter, ventricles, CSF and similar polygons
#      post-build, punches the white matter out of the cortex silhouette,
#      and keeps the neighbouring subcortical structures as context.
#   e) Applies atlas_smooth() to tidy the 2D contours.
#
# Reference: Billot B, et al. (2020). "Automated segmentation of the
#   hypothalamus and associated subunits in brain MRI." NeuroImage,
#   223:117287. DOI: 10.1016/j.neuroimage.2020.117287
#
# Run with: Rscript data-raw/make_hypothalamus.R

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

seg_dir <- file.path(data_raw, "cvs_avg35_hypothalamus")
cvs_hyp <- file.path(seg_dir, "hypothalamic_subunits.mgz")
fs5_aseg <- file.path(fs5_subj, "mri/aseg.mgz")
cvs_tal_xfm <- file.path(cvs_subj, "mri/transforms/talairach.xfm")
lut_file <- file.path(fs_home, "FreeSurferColorLUT.txt")

seg_file <- file.path(data_raw, "HypothalamicSubunits_fs5_brain.nii.gz")

# Subunit label ids in the standard LUT (801-805 left, 806-810 right).
HYP_LABELS <- 801:810

stopifnot(
  "cvs_avg35 hypothalamic_subunits.mgz not found (run segmentation first)" = file.exists(
    cvs_hyp
  ),
  "fsaverage5 aseg.mgz not found" = file.exists(fs5_aseg),
  "cvs_avg35 talairach.xfm not found" = file.exists(cvs_tal_xfm),
  "FreeSurferColorLUT.txt not found" = file.exists(lut_file)
)

fs <- function(...) {
  bin <- file.path(fs_home, "bin")
  system2(file.path(bin, ..1), c(...)[-1], stdout = FALSE, stderr = FALSE)
}

# ── 1. Register cvs_avg35 hypothalamic labels into fsaverage5 space ───────
hyp_fs5_mgz <- file.path(data_raw, "fs5_hypothalamus/hypothalamic_fs5.mgz")
if (
  !file.exists(hyp_fs5_mgz) || file.mtime(hyp_fs5_mgz) < file.mtime(cvs_hyp)
) {
  dir.create(dirname(hyp_fs5_mgz), showWarnings = FALSE, recursive = TRUE)
  cli::cli_alert_info(
    "Registering hypothalamic subunits: cvs_avg35 → fsaverage5"
  )
  fs(
    "mri_vol2vol",
    "--mov",
    cvs_hyp,
    "--targ",
    fs5_aseg,
    "--xfm",
    cvs_tal_xfm,
    "--o",
    hyp_fs5_mgz,
    "--nearest"
  )
}

# ── 2. Build embedded volume: fs5 aseg + hypothalamic subunits ───────────
build_embedded_volume <- function(aseg_path, hyp_path, out_path) {
  cli::cli_alert_info("Embedding hypothalamic subunits in fsaverage5 aseg")

  aseg_nii <- file.path(tempdir(), "fs5_aseg.nii.gz")
  hyp_nii <- file.path(tempdir(), "hyp_fs5.nii.gz")
  fs("mri_convert", "-ot", "nii", aseg_path, aseg_nii)
  fs("mri_convert", "-ot", "nii", hyp_path, hyp_nii)

  aseg <- RNifti::readNifti(aseg_nii)
  hyp <- RNifti::readNifti(hyp_nii)
  out <- as.integer(round(aseg))
  dim(out) <- dim(aseg)

  hyp <- as.integer(round(hyp))
  hyp_mask <- hyp %in% HYP_LABELS
  out[hyp_mask] <- hyp[hyp_mask]

  RNifti::writeNifti(out, out_path, template = aseg_nii, datatype = "int32")
  invisible(out)
}

if (
  !file.exists(seg_file) ||
    file.mtime(seg_file) < max(file.mtime(c(fs5_aseg, hyp_fs5_mgz)))
) {
  out_vol <- build_embedded_volume(fs5_aseg, hyp_fs5_mgz, seg_file)
} else {
  cli::cli_alert_success("Reusing existing {.path {basename(seg_file)}}")
  out_vol <- as.integer(round(RNifti::readNifti(seg_file)))
  dim(out_vol) <- dim(RNifti::readNifti(seg_file))
}

# ── 3. Derive slice views from the subunit bounding box ──────────────────
# The view slabs must be indexed in the same axis frame the pipeline
# projects in. ggseg.extra's read_volume() reorients the NIfTI relative to
# RNifti (it swaps/flips the A/P and I/S axes), so we compute the bounding
# box from read_volume()'s output rather than the RNifti array used for the
# embedding. In that frame dim2 indexes coronal and dim3 indexes axial.
proj_vol <- ggseg.extra:::read_volume(seg_file)
sub_mask <- array(proj_vol %in% HYP_LABELS, dim = dim(proj_vol))
idx <- which(sub_mask, arr.ind = TRUE)
yr <- range(idx[, 2])
zr <- range(idx[, 3])

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

views <- rbind(
  slab(yr[1], yr[2], 3, "coronal", "coronal"),
  slab(zr[1], zr[2], 2, "axial", "axial")
)
cli::cli_alert_info("Views:")
print(views)

# ── 4. Build the ggseg atlas ────────────────────────────────────────────
cli::cli_h1("Creating hypothalamic subunits atlas")

# The hypothalamic subunits are small (each ~30-250 voxels), so a few
# dilation iterations on the projection snapshots are needed for them to
# produce valid 2D contours; without it every subunit is dropped for
# having no traceable polygon.
hyp_raw <- create_subcortical_from_volume(
  input_volume = seg_file,
  input_lut = lut_file,
  atlas_name = "hypothalamus",
  views = views,
  output_dir = data_raw,
  dilate = 3,
  skip_existing = TRUE,
  cleanup = FALSE
)

# Punch the cerebral white matter out of the brain silhouette so slices
# show the cortical ribbon with the white-matter interior as a hole rather
# than one solid grey blob (see make_hippoamyg.R for the rationale). Must
# run before White-Matter is removed below.
hyp_raw <- atlas_region_op(
  hyp_raw,
  x = "^cortex",
  y = "White-Matter$",
  action = "difference",
  into = "cortex"
)

# ── 5. Post-process: drop polygons aseg doesn't show either ──────────────
cli::cli_h2("Post-processing atlas")

hyp <- hyp_raw |>
  atlas_region_remove("White-Matter", match_on = "label") |>
  atlas_region_remove("WM-hypointensities", match_on = "label") |>
  atlas_region_remove("-Ventricle", match_on = "label") |>
  atlas_region_remove("-Vent$", match_on = "label") |>
  atlas_region_remove("CSF", match_on = "label") |>
  atlas_region_remove("Cerebral-Cortex", match_on = "label") |>
  atlas_region_remove("choroid-plexus", match_on = "label") |>
  atlas_region_remove("vessel", match_on = "label") |>
  atlas_region_remove("CC_", match_on = "label") |>
  # "-Thalamus" (not "Thalamus"): atlas_region_contextual matches case-
  # insensitively, so a bare "Thalamus" also matches "hypothalamus" and would
  # demote every subunit to context. The leading hyphen matches the aseg
  # "Left-/Right-Thalamus" labels without catching "L_hypothalamus_*".
  atlas_region_contextual(
    paste0(
      "Caudate|Putamen|Pallidum|-Thalamus|Hippocampus|Amygdala|Accumbens",
      "|VentralDC|Cerebellum|Brain-Stem|Optic-Chiasm",
      "|unknown|Background"
    ),
    "label"
  ) |>
  # clean_region_name keeps the L_/R_ prefix as a redundant "l "/"r " in the
  # region name (hemi already lives in its own column); drop it so regions
  # read "hypothalamus anterior inferior" etc.
  atlas_region_rename("^[lr] ", "")

# Drop slabs that contain only context (no subunit).
hyp_sf <- ggseg.formats::atlas_sf(hyp)
empty_views <- vapply(
  unique(hyp_sf$view),
  function(v) {
    rows <- hyp_sf[hyp_sf$view == v, ]
    !any(rows$label %in% hyp$core$label)
  },
  logical(1)
)
empty_views <- names(empty_views)[empty_views]
if (length(empty_views) > 0) {
  cli::cli_alert_info("Dropping context-only view{?s}: {.val {empty_views}}")
  hyp <- atlas_view_remove(hyp, empty_views)
}

hyp <- hyp |>
  atlas_view_gather() |>
  atlas_smooth(
    keep = NULL,
    smoothness = 3,
    exclude = "^cortex"
  )

# Cortex outline gets a heavier close so the silhouette reads smooth, plus
# light vertex simplification. smoothness is a morphological close — keep it
# low enough to preserve the anatomical ventricle/WM holes.
hyp_2 <- atlas_smooth(
  hyp,
  keep = 0.1,
  smoothness = 7,
  labels = "^cortex"
)
plot(hyp_2)

cli::cli_alert_success("hypothalamus: {nrow(hyp$core)} regions")
print(hyp_2)

# ── 6. Save into sysdata.rda alongside the other atlases ─────────────────
sysdata_path <- here::here("R/sysdata.rda")
if (file.exists(sysdata_path)) {
  load(sysdata_path)
}

.hypothalamus <- hyp_2

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

ggseg.formats::migrate_atlas_files("R")

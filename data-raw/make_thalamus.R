# Create Thalamic Nuclei Atlas (Iglesias et al. 2018) on fsaverage5
#
# Builds a ggseg atlas of the 26 Iglesias thalamic nuclei per hemisphere
# embedded in fsaverage5's full aseg, so the brain context matches the
# other FreeSurfer atlases in this package (which all derive from
# fsaverage5).
#
# Why fsaverage5 + registration:
#   `segment_subregions thalamus` needs `norm.mgz`, which fsaverage5
#   does not ship with. cvs_avg35 does, so we run the segmentation
#   there and bring the result across to fsaverage5 via the
#   talairach.xfm affine (fsaverage5 is already in MNI305/talairach,
#   so its own talairach.xfm is identity — the registration is just
#   cvs_avg35's talairach.xfm applied to the thalamic volume).
#
# Inputs (must be generated outside R first):
#   1. cvs_avg35's recon-all (ships with FreeSurfer).
#   2. fsaverage5's recon-all (ships with FreeSurfer).
#   3. ThalamicNuclei.mgz from `segment_subregions thalamus --cross
#      cvs_avg35 --sd $FREESURFER_HOME/subjects --out-dir
#      data-raw/cvs_avg35_seg`.
#
# This script:
#   a) Registers the cvs_avg35 thalamic segmentation into fsaverage5
#      space using cvs_avg35's talairach.xfm.
#   b) Stamps the 26 thalamic nuclei into fsaverage5's full aseg,
#      replacing the lumped Left/Right-Thalamus (10/49) labels.
#   c) Adds symbolic footprints for the small nuclei (Pc, Pt, R, VM)
#      that get absorbed by their neighbours during atlas → template
#      argmax resampling.
#   d) Hands the combined volume to ggseg.extra's pipeline using the
#      standard FreeSurferColorLUT.txt — both standard aseg labels
#      and Iglesias thalamic labels (8100–8233) are covered.
#   e) Removes White-Matter, Cerebral-Cortex, ventricles, CSF and
#      similar polygons post-build, leaving the smooth `cortex_`
#      outline as brain context plus the standard subcortical
#      structures (Caudate, Putamen, Hippocampus, Amygdala, etc.)
#      as anatomical context around the thalamic nuclei.
#   f) Applies atlas_smooth() to tidy the 2D contours.
#
# Reference: Iglesias JE, et al. (2018). "A probabilistic atlas of the
#   human thalamic nuclei combining ex vivo MRI and histology."
#   NeuroImage, 183:314-326. DOI: 10.1016/j.neuroimage.2018.08.012
#
# Run with: Rscript data-raw/make_thalamus.R

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

cvs_thal <- file.path(data_raw, "cvs_avg35_seg/ThalamicNuclei.mgz")
fs5_aseg <- file.path(fs5_subj, "mri/aseg.mgz")
cvs_tal_xfm <- file.path(cvs_subj, "mri/transforms/talairach.xfm")

seg_file <- file.path(data_raw, "ThalamicNuclei_fs5_brain.nii.gz")
lut_file <- file.path(fs_home, "FreeSurferColorLUT.txt")

stopifnot(
  "cvs_avg35 ThalamicNuclei.mgz not found" = file.exists(cvs_thal),
  "fsaverage5 aseg.mgz not found" = file.exists(fs5_aseg),
  "cvs_avg35 talairach.xfm not found" = file.exists(cvs_tal_xfm),
  "FreeSurferColorLUT.txt not found" = file.exists(lut_file)
)

fs <- function(...) {
  bin <- file.path(fs_home, "bin")
  system2(file.path(bin, ..1), c(...)[-1], stdout = FALSE, stderr = FALSE)
}

# ── 1. Register cvs_avg35 thalamic nuclei into fsaverage5 space ────────
thal_fs5_mgz <- file.path(data_raw, "fs5_thalamus/ThalamicNuclei_fs5.mgz")
if (
  !file.exists(thal_fs5_mgz) ||
    file.mtime(thal_fs5_mgz) < file.mtime(cvs_thal)
) {
  dir.create(dirname(thal_fs5_mgz), showWarnings = FALSE, recursive = TRUE)
  cli::cli_alert_info("Registering thalamic nuclei: cvs_avg35 → fsaverage5")
  fs(
    "mri_vol2vol",
    "--mov",
    cvs_thal,
    "--targ",
    fs5_aseg,
    "--xfm",
    cvs_tal_xfm,
    "--o",
    thal_fs5_mgz,
    "--nearest"
  )
}

# ── 2. Build embedded volume: fs5 aseg + thalamic nuclei ───────────────
build_embedded_volume <- function(aseg_path, thal_path, out_path) {
  cli::cli_alert_info("Embedding thalamic nuclei in fsaverage5 aseg")

  aseg_nii <- file.path(tempdir(), "fs5_aseg.nii.gz")
  thal_nii <- file.path(tempdir(), "thal_fs5.nii.gz")
  fs("mri_convert", "-ot", "nii", aseg_path, aseg_nii)
  fs("mri_convert", "-ot", "nii", thal_path, thal_nii)

  aseg <- RNifti::readNifti(aseg_nii)
  thal <- RNifti::readNifti(thal_nii)
  out <- as.integer(round(aseg))
  dim(out) <- dim(aseg)

  out[out == 10L | out == 49L] <- 0L

  thal_mask <- thal >= 8100 & thal <= 8300
  out[thal_mask] <- as.integer(thal[thal_mask])

  # Symbolic placement for nuclei the atlas MAP loses on this template
  # (Pc, Pt, R, VM, both hemispheres). Offsets are voxel deltas from the
  # centroid of an anatomical anchor nucleus. Each missing nucleus is
  # stamped as a 3×3×3 cube of its label at that location.
  anchors <- list(
    `8117` = c(8106L, 2, 0, 2),
    `8217` = c(8206L, -2, 0, 2),
    `8119` = c(8113L, 2, 3, 2),
    `8219` = c(8213L, -2, 3, 2),
    `8125` = c(8116L, -2, -2, 0),
    `8225` = c(8216L, 2, -2, 0),
    `8130` = c(8128L, 0, -2, -2),
    `8230` = c(8228L, 0, -2, -2)
  )

  dims <- dim(out)
  min_voxels <- 27L

  stamp_cube <- function(label, cx, cy, cz, radius = 1L) {
    n <- 0L
    for (ix in seq(-radius, radius)) {
      for (iy in seq(-radius, radius)) {
        for (iz in seq(-radius, radius)) {
          x <- cx + ix
          y <- cy + iy
          z <- cz + iz
          if (
            x < 1 || x > dims[1] || y < 1 || y > dims[2] || z < 1 || z > dims[3]
          ) {
            next
          }
          out[x, y, z] <<- label
          n <- n + 1L
        }
      }
    }
    n
  }

  for (lab_chr in names(anchors)) {
    missing_label <- as.integer(lab_chr)
    a <- anchors[[lab_chr]]
    anchor_label <- a[1]
    idx <- which(out == anchor_label, arr.ind = TRUE)
    if (nrow(idx) == 0) {
      next
    }
    centroid <- round(colMeans(idx))
    n <- stamp_cube(
      missing_label,
      centroid[1] + a[2],
      centroid[2] + a[3],
      centroid[3] + a[4],
      radius = 1L
    )
    cli::cli_alert_info(
      "  stamped {n} voxel{?s} for {missing_label} off anchor {anchor_label}"
    )
  }

  thal_labels <- sort(unique(as.vector(out)))
  thal_labels <- thal_labels[thal_labels >= 8100 & thal_labels <= 8300]
  for (lab in thal_labels) {
    n_have <- sum(out == lab)
    if (n_have >= min_voxels) {
      next
    }
    idx <- which(out == lab, arr.ind = TRUE)
    centroid <- round(colMeans(idx))
    n <- stamp_cube(
      lab,
      centroid[1],
      centroid[2],
      centroid[3],
      radius = 1L
    )
    cli::cli_alert_info("  bolstered {lab}: had {n_have}, total {n}")
  }

  RNifti::writeNifti(out, out_path, template = aseg_nii, datatype = "int32")
  invisible(out_path)
}

if (
  !file.exists(seg_file) ||
    file.mtime(seg_file) < max(file.mtime(c(fs5_aseg, thal_fs5_mgz)))
) {
  build_embedded_volume(fs5_aseg, thal_fs5_mgz, seg_file)
} else {
  cli::cli_alert_success("Reusing existing {.path {basename(seg_file)}}")
}

# ── 3. Build the ggseg atlas ──────────────────────────────────────────
cli::cli_h1("Creating thalamic nuclei atlas")

# fsaverage5 1mm RAS+ grid (256³). Thalamus bbox in that space is
# x=101–157, y=112–143, z=92–136. Sagittal omitted: at the midline
# only Pt/R/MV_Re intersect, carrying no useful overview.
views <- rbind(
  data.frame(name = "axial_1", type = "axial", start = 92, end = 101),
  data.frame(name = "axial_2", type = "axial", start = 102, end = 111),
  data.frame(name = "axial_3", type = "axial", start = 112, end = 119),
  data.frame(name = "axial_4", type = "axial", start = 120, end = 128),
  data.frame(name = "coronal_1", type = "coronal", start = 112, end = 117),
  data.frame(name = "coronal_2", type = "coronal", start = 118, end = 123),
  data.frame(name = "coronal_3", type = "coronal", start = 124, end = 129),
  data.frame(name = "coronal_4", type = "coronal", start = 130, end = 136)
)

thal_raw <- create_subcortical_from_volume(
  input_volume = seg_file,
  input_lut = lut_file,
  atlas_name = "thalamus",
  views = views,
  output_dir = data_raw,
  skip_existing = TRUE,
  cleanup = FALSE
)

# ── 4. Post-process: drop polygons aseg doesn't show either ───────────
cli::cli_h2("Post-processing atlas")

thal <- thal_raw |>
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
      "Caudate|Putamen|Pallidum|Hippocampus|Amygdala|Accumbens",
      "|VentralDC|Cerebellum|Brain-Stem|Optic-Chiasm",
      "|unknown|Background"
    ),
    "label"
  ) |>
  # Drop views with little or no thalamic content. axial_1/2 (z=92-111)
  # are below the thalamus and show only cerebellum/cortex. axial_3 only
  # adds MV_Re (still covered by coronals 1-3). coronal_4 shows just 7
  # nuclei, all also visible in coronals 1-3. Verified: no nucleus is
  # exclusively visible in the dropped views.
  atlas_view_remove(c("axial_1", "axial_2", "axial_3", "coronal_4")) |>
  atlas_view_gather() |>
  atlas_smooth(
    keep = NULL,
    smoothness = 3,
    exclude = "cortex_"
  )

# Don't atlas_smooth the cortex_ — heavy simplification (keep=0.05) on a
# ~4000-vertex sulcal contour collapses the brain silhouette into jagged
# straight cuts. aseg() doesn't smooth either; keep raw contours.

# atlas_region_contextual() already drew the context structures (VentralDC,
# Hippocampus, Brain-Stem, etc.) behind the thalamic nuclei — it moves
# non-core sf rows ahead of core rows — so no manual reordering is needed.

# Cortex outline gets a heavier close so the silhouette reads smooth at
# typical plot sizes, plus light vertex simplification to keep the
# polygon size sensible.
thal_2 <- atlas_smooth(
  thal,
  keep = 0.5,
  smoothness = 4,
  labels = "cortex_"
)
plot(thal_2)

cli::cli_alert_success("thal: {nrow(thal$core)} regions")
print(thal_2)

# ── 5. Save into sysdata.rda alongside the other atlases ──────────────
sysdata_path <- here::here("R/sysdata.rda")
if (file.exists(sysdata_path)) {
  load(sysdata_path)
}

.thalamus <- thal_2

usethis::use_data(
  .dkt,
  .destrieux,
  .hcpa,
  .thalamus,
  overwrite = TRUE,
  compress = "xz",
  internal = TRUE
)

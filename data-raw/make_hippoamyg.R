# Create Hippocampal Subfields & Amygdala Nuclei Atlas on fsaverage5
#
# Builds a ggseg atlas of the FreeSurfer hippocampal subfields and
# amygdala nuclei (Iglesias et al. 2015; Saygin et al. 2017) embedded in
# fsaverage5's full aseg, so the brain context matches the other
# FreeSurfer atlases in this package (which all derive from fsaverage5).
#
# Why fsaverage5 + registration:
#   `segment_subregions hippo-amygdala` needs `norm.mgz`, which fsaverage5
#   does not ship with. cvs_avg35 does, so we run the segmentation there
#   and bring the result across to fsaverage5 via the talairach.xfm affine
#   (fsaverage5 is already in MNI305/talairach, so its own talairach.xfm
#   is identity — the registration is just cvs_avg35's talairach.xfm
#   applied to the subregion volume). This mirrors make_thalamus.R.
#
# Hemisphere handling differs from the thalamus:
#   `segment_subregions hippo-amygdala` writes one volume per hemisphere
#   (lh./rh.hippoAmygLabels), and BOTH reuse the same hemisphere-agnostic
#   label ids (e.g. 206 = CA1 in both). FreeSurferColorLUT.txt has no
#   Left-/Right- entries for these. ggseg.extra derives hemi from a
#   Left-/Right- prefix on the region name, so we remap the labels into
#   two private id ranges (left = id + 30000, right = id + 40000) and
#   build a custom LUT with Left-/Right- prefixed names that carries the
#   official subfield/nucleus colours.
#
# Inputs (must be generated outside R first):
#   1. cvs_avg35's recon-all (ships with FreeSurfer).
#   2. fsaverage5's recon-all (ships with FreeSurfer).
#   3. lh./rh.hippoAmygLabels-T1.v22.mgz from
#      `segment_subregions hippo-amygdala --cross cvs_avg35
#       --sd $FREESURFER_HOME/subjects
#       --out-dir data-raw/cvs_avg35_hippoamyg`.
#
# This script:
#   a) Registers the cvs_avg35 hippo/amygdala segmentations into
#      fsaverage5 space using cvs_avg35's talairach.xfm.
#   b) Stamps the remapped subfield/nucleus labels into fsaverage5's full
#      aseg, replacing the lumped Left/Right-Hippocampus (17/53) and
#      Left/Right-Amygdala (18/54) labels.
#   c) Hands the combined volume to ggseg.extra's pipeline with a LUT that
#      merges the standard FreeSurferColorLUT (for anatomical context) and
#      the custom Left-/Right- subregion entries.
#   d) Removes White-Matter, Cerebral-Cortex, ventricles, CSF and similar
#      polygons post-build, leaving the smooth `cortex_` outline plus the
#      neighbouring subcortical structures as anatomical context around the
#      hippocampal subfields and amygdala nuclei.
#   e) Applies atlas_smooth() to tidy the 2D contours.
#
# References:
#   Iglesias JE, et al. (2015). "A computational atlas of the hippocampal
#     formation using ex vivo, ultra-high resolution MRI: Application to
#     adaptive segmentation of in vivo MRI." NeuroImage, 115:117-137.
#     DOI: 10.1016/j.neuroimage.2015.04.042
#   Saygin ZM, et al. (2017). "High-resolution magnetic resonance imaging
#     reveals nuclei of the human amygdala: manual segmentation to
#     automatic atlas." NeuroImage, 155:370-382.
#     DOI: 10.1016/j.neuroimage.2017.04.046
#
# Run with: Rscript data-raw/make_hippoamyg.R

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

seg_dir <- file.path(data_raw, "cvs_avg35_hippoamyg")
fs5_aseg <- file.path(fs5_subj, "mri/aseg.mgz")
cvs_tal_xfm <- file.path(cvs_subj, "mri/transforms/talairach.xfm")
lut_file <- file.path(fs_home, "FreeSurferColorLUT.txt")

seg_file <- file.path(data_raw, "HippoAmyg_fs5_brain.nii.gz")

# Private id ranges so left/right never collide with each other, with the
# standard aseg labels, or with the thalamic nuclei (8100-8300).
LEFT_OFFSET <- 30000L
RIGHT_OFFSET <- 40000L

# Pick the combined hippocampus + amygdala label volume for a hemisphere,
# preferring the main T1 v22 output over the FSvoxelSpace/HBT/FS60 variants.
find_hemi_seg <- function(hemi) {
  candidates <- Sys.glob(file.path(
    seg_dir,
    paste0(hemi, ".hippoAmygLabels*.mgz")
  ))
  main <- grep(
    "FSvoxelSpace|HBT|FS60|CA\\.|\\.CA",
    candidates,
    value = TRUE,
    invert = TRUE
  )
  if (length(main) > 0) {
    main[1]
  } else if (length(candidates) > 0) {
    candidates[1]
  } else {
    NA_character_
  }
}

lh_seg <- find_hemi_seg("lh")
rh_seg <- find_hemi_seg("rh")

stopifnot(
  "lh hippoAmygLabels not found (run segment_subregions first)" = !is.na(
    lh_seg
  ) &&
    file.exists(lh_seg),
  "rh hippoAmygLabels not found (run segment_subregions first)" = !is.na(
    rh_seg
  ) &&
    file.exists(rh_seg),
  "fsaverage5 aseg.mgz not found" = file.exists(fs5_aseg),
  "cvs_avg35 talairach.xfm not found" = file.exists(cvs_tal_xfm),
  "FreeSurferColorLUT.txt not found" = file.exists(lut_file)
)

fs <- function(...) {
  bin <- file.path(fs_home, "bin")
  system2(file.path(bin, ..1), c(...)[-1], stdout = FALSE, stderr = FALSE)
}

# ── 1. Register cvs_avg35 hippo/amygdala labels into fsaverage5 space ───
register_to_fs5 <- function(src_mgz, out_mgz) {
  if (file.exists(out_mgz) && file.mtime(out_mgz) >= file.mtime(src_mgz)) {
    return(out_mgz)
  }
  dir.create(dirname(out_mgz), showWarnings = FALSE, recursive = TRUE)
  cli::cli_alert_info(
    "Registering {.path {basename(src_mgz)}}: cvs_avg35 → fsaverage5"
  )
  fs(
    "mri_vol2vol",
    "--mov",
    src_mgz,
    "--targ",
    fs5_aseg,
    "--xfm",
    cvs_tal_xfm,
    "--o",
    out_mgz,
    "--nearest"
  )
  out_mgz
}

lh_fs5 <- register_to_fs5(
  lh_seg,
  file.path(data_raw, "fs5_hippoamyg/lh.hippoAmyg_fs5.mgz")
)
rh_fs5 <- register_to_fs5(
  rh_seg,
  file.path(data_raw, "fs5_hippoamyg/rh.hippoAmyg_fs5.mgz")
)

# ── 2. Build embedded volume: fs5 aseg + remapped subregions ────────────
build_embedded_volume <- function(aseg_path, lh_path, rh_path, out_path) {
  cli::cli_alert_info(
    "Embedding hippocampal subfields & amygdala nuclei in fsaverage5 aseg"
  )

  to_nii <- function(mgz, nm) {
    nii <- file.path(tempdir(), nm)
    fs("mri_convert", "-ot", "nii", mgz, nii)
    RNifti::readNifti(nii)
  }
  aseg_nii <- file.path(tempdir(), "fs5_aseg.nii.gz")
  fs("mri_convert", "-ot", "nii", aseg_path, aseg_nii)
  aseg <- RNifti::readNifti(aseg_nii)
  lh <- to_nii(lh_path, "lh_fs5.nii.gz")
  rh <- to_nii(rh_path, "rh_fs5.nii.gz")

  out <- as.integer(round(aseg))
  dim(out) <- dim(aseg)

  # Drop the lumped hippocampus/amygdala so only the subregions remain.
  out[out %in% c(17L, 53L, 18L, 54L)] <- 0L

  lh <- as.integer(round(lh))
  rh <- as.integer(round(rh))
  lh_mask <- lh > 0L
  rh_mask <- rh > 0L
  out[lh_mask] <- lh[lh_mask] + LEFT_OFFSET
  out[rh_mask] <- rh[rh_mask] + RIGHT_OFFSET

  RNifti::writeNifti(out, out_path, template = aseg_nii, datatype = "int32")
  invisible(out)
}

if (
  !file.exists(seg_file) ||
    file.mtime(seg_file) < max(file.mtime(c(fs5_aseg, lh_fs5, rh_fs5)))
) {
  out_vol <- build_embedded_volume(fs5_aseg, lh_fs5, rh_fs5, seg_file)
} else {
  cli::cli_alert_success("Reusing existing {.path {basename(seg_file)}}")
  out_vol <- as.integer(round(RNifti::readNifti(seg_file)))
  dim(out_vol) <- dim(RNifti::readNifti(seg_file))
}

# ── 3. Build the combined LUT (standard context + custom subregions) ────
parse_fs_lut <- function(path) {
  lines <- readLines(path, warn = FALSE)
  lines <- trimws(lines)
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]
  parts <- strsplit(lines, "\\s+")
  parts <- parts[lengths(parts) >= 5]
  data.frame(
    idx = as.integer(vapply(parts, `[`, "", 1)),
    label = vapply(parts, `[`, "", 2),
    R = as.integer(vapply(parts, `[`, "", 3)),
    G = as.integer(vapply(parts, `[`, "", 4)),
    B = as.integer(vapply(parts, `[`, "", 5)),
    A = 0L,
    stringsAsFactors = FALSE
  )
}

std_lut <- parse_fs_lut(lut_file)

# Original subregion ids present in either hemisphere (before remapping).
present <- sort(unique(c(
  out_vol[out_vol > LEFT_OFFSET & out_vol < RIGHT_OFFSET] - LEFT_OFFSET,
  out_vol[out_vol >= RIGHT_OFFSET] - RIGHT_OFFSET
)))

sub_meta <- std_lut[match(present, std_lut$idx), ]
custom_lut <- rbind(
  data.frame(
    idx = present + LEFT_OFFSET,
    label = paste0("Left-", sub_meta$label),
    R = sub_meta$R,
    G = sub_meta$G,
    B = sub_meta$B,
    A = 0L,
    stringsAsFactors = FALSE
  ),
  data.frame(
    idx = present + RIGHT_OFFSET,
    label = paste0("Right-", sub_meta$label),
    R = sub_meta$R,
    G = sub_meta$G,
    B = sub_meta$B,
    A = 0L,
    stringsAsFactors = FALSE
  )
)

combined_lut <- rbind(std_lut, custom_lut)

# ── 4. Derive slice views from the subregion bounding box ───────────────
# fsaverage5 1mm RAS+ grid (256³): dim1 = L/R (sagittal), dim2 = A/P
# (coronal), dim3 = I/S (axial). The hippocampal long axis runs A/P, so
# coronal slabs through it carry the subfields; a couple of axial slabs
# give an overview. Slabs are derived from the actual label extent so the
# views always frame the structures.
sub_mask <- out_vol >= LEFT_OFFSET
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
  slab(yr[1], yr[2], 5, "coronal", "coronal"),
  slab(zr[1], zr[2], 2, "axial", "axial")
)
cli::cli_alert_info("Views:")
print(views)

# ── 5. Build the ggseg atlas ────────────────────────────────────────────
cli::cli_h1("Creating hippocampal subfields & amygdala nuclei atlas")

ha_raw <- create_subcortical_from_volume(
  input_volume = seg_file,
  input_lut = combined_lut,
  atlas_name = "hippoamyg",
  views = views,
  output_dir = data_raw,
  skip_existing = TRUE,
  cleanup = FALSE
)

# Punch the cerebral white matter out of the brain silhouette so axial and
# coronal slices show the cortical ribbon with the white-matter interior as a
# hole, instead of one solid grey blob. atlas_region_op() does the per-view
# vector difference (like an Inkscape boolean of two shapes); writing back to
# `cortex` replaces the solid silhouette with the punched ribbon. No colour,
# so it stays contextual grey. Must run before White-Matter is removed below.
ha_raw <- atlas_region_op(
  ha_raw,
  x = "^cortex",
  y = "White-Matter$",
  action = "difference",
  into = "cortex"
)

# ── 6. Post-process: drop polygons aseg doesn't show either ─────────────
cli::cli_h2("Post-processing atlas")

ha <- ha_raw |>
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
      "Caudate|Putamen|Pallidum|Thalamus|Accumbens",
      "|VentralDC|Cerebellum|Brain-Stem|Optic-Chiasm",
      "|unknown|Background"
    ),
    "label"
  )

# atlas_region_contextual() already drew the context structures behind the
# focus regions (it moves non-core sf rows ahead of core rows), so no manual
# reordering is needed here.

# Drop slabs that contain only context (no subfield/nucleus): the bbox-derived
# coronal slabs run past the posterior end of the structures, leaving a few
# views with nothing but surrounding brain. Compute them from core membership
# so the set stays correct if the slab geometry changes.
ha_sf <- ggseg.formats::atlas_sf(ha)
empty_views <- vapply(
  unique(ha_sf$view),
  function(v) {
    rows <- ha_sf[ha_sf$view == v, ]
    !any(rows$label %in% ha$core$label)
  },
  logical(1)
)
empty_views <- names(empty_views)[empty_views]
if (length(empty_views) > 0) {
  cli::cli_alert_info("Dropping context-only view{?s}: {.val {empty_views}}")
  ha <- atlas_view_remove(ha, empty_views)
}

ha <- ha |>
  atlas_view_gather() |>
  atlas_smooth(
    keep = NULL,
    smoothness = 3,
    exclude = "^cortex"
  )

# Cortex outline gets a heavier close so the silhouette reads smooth at
# typical plot sizes, plus light vertex simplification. The current
# ggseg.extra labels the brain silhouette `cortex` (no trailing `_`), so
# match `^cortex` — which never catches the `Left/Right-Cerebral-Cortex`
# context polygons. Guard against an absent silhouette just in case.
#
# smoothness is a morphological close (buffer +s then -s) — it both merges
# the fragmented contour pieces into one silhouette and bridges gaps
# narrower than ~2*s. Keep it at 1: higher values close the anatomical
# ventricle/temporal-horn holes (e.g. the central hole in axial_2 and the
# temporal-horn holes in the coronal slices), which should stay open.
ha_2 <-
  atlas_smooth(
    ha,
    keep = 0.1,
    smoothness = 7,
    labels = "^cortex"
  )
plot(ha_2)

cli::cli_alert_success("hippoamyg: {nrow(ha$core)} regions")
print(ha_2)

# ── 7. Save into sysdata.rda alongside the other atlases ────────────────
sysdata_path <- here::here("R/sysdata.rda")
if (file.exists(sysdata_path)) {
  load(sysdata_path)
}

.hippoamyg <- ha_2

usethis::use_data(
  .dkt,
  .destrieux,
  .hcpa,
  .thalamus,
  .hippoamyg,
  overwrite = TRUE,
  compress = "xz",
  internal = TRUE
)

ggseg.formats::migrate_atlas_files("R")

# Create HCP-style Anterior/Posterior Hippocampus Atlas on fsaverage5
#
# Builds a ggseg atlas that splits each hippocampus into an anterior and a
# posterior part, embedded in fsaverage5's full aseg so the slice views
# show the hippocampus inside cerebral cortex and white matter (rendered
# grey as anatomical context), matching the other FreeSurfer atlases in
# this package.
#
# This replaces the previous 3D-only `hcpa` (imported from ggsegDefaultExtra,
# which carried meshes but no 2D slice geometry) with a focused 2D + 3D
# atlas of the four hippocampal parts (left/right × anterior/posterior).
#
# The anterior/posterior boundary is the midpoint of each hippocampus's own
# anterior-posterior extent, computed in world (RAS) coordinates so the
# split direction does not depend on the volume's voxel orientation: the
# anterior part is the head side (larger RAS y), the posterior part the tail.
#
# Inputs (ship with FreeSurfer):
#   fsaverage5's recon-all aseg.mgz.
#
# Run with: Rscript data-raw/make_hcpa.R

library(dplyr)
library(ggseg.extra)
library(ggseg.formats)

options(chromote.timeout = 120)
future::plan(future::sequential)
progressr::handlers("cli")
progressr::handlers(global = TRUE)

data_raw <- here::here("data-raw")
fs_home <- Sys.getenv("FREESURFER_HOME", "/Applications/freesurfer/7.4.1")
fs5_subj <- file.path(fs_home, "subjects/fsaverage5")

fs5_aseg <- file.path(fs5_subj, "mri/aseg.mgz")
lut_file <- file.path(fs_home, "FreeSurferColorLUT.txt")
seg_file <- file.path(data_raw, "HippoAntPost_fs5_brain.nii.gz")

# aseg hippocampus labels and the private ids for the split parts.
LEFT_HIPPO <- 17L
RIGHT_HIPPO <- 53L
LH_ANT <- 20001L
LH_POST <- 20002L
RH_ANT <- 20003L
RH_POST <- 20004L
SPLIT <- list(
  c(label = LEFT_HIPPO, ant = LH_ANT, post = LH_POST),
  c(label = RIGHT_HIPPO, ant = RH_ANT, post = RH_POST)
)
NEW_LABELS <- c(LH_ANT, LH_POST, RH_ANT, RH_POST)

stopifnot(
  "fsaverage5 aseg.mgz not found" = file.exists(fs5_aseg),
  "FreeSurferColorLUT.txt not found" = file.exists(lut_file)
)

fs <- function(...) {
  bin <- file.path(fs_home, "bin")
  system2(file.path(bin, ..1), c(...)[-1], stdout = FALSE, stderr = FALSE)
}

# ── 1. Build embedded volume: fs5 aseg with hippocampus split A/P ─────────
build_embedded_volume <- function(aseg_path, out_path) {
  cli::cli_alert_info("Splitting hippocampus anterior/posterior in fs5 aseg")

  aseg_nii <- file.path(tempdir(), "fs5_aseg.nii.gz")
  fs("mri_convert", "-ot", "nii", aseg_path, aseg_nii)
  aseg <- RNifti::readNifti(aseg_nii)

  out <- as.integer(round(aseg))
  dim(out) <- dim(aseg)

  for (s in SPLIT) {
    idx <- which(array(out == s[["label"]], dim = dim(out)), arr.ind = TRUE)
    world <- RNifti::voxelToWorld(idx, aseg)
    ras_y <- world[, 2]
    anterior <- ras_y >= stats::median(ras_y)
    out[idx[anterior, , drop = FALSE]] <- s[["ant"]]
    out[idx[!anterior, , drop = FALSE]] <- s[["post"]]
    cli::cli_alert_info(
      "  label {s[['label']]}: {sum(anterior)} anterior, {sum(!anterior)} posterior"
    )
  }

  RNifti::writeNifti(out, out_path, template = aseg_nii, datatype = "int32")
  invisible(out)
}

if (!file.exists(seg_file) || file.mtime(seg_file) < file.mtime(fs5_aseg)) {
  build_embedded_volume(fs5_aseg, seg_file)
} else {
  cli::cli_alert_success("Reusing existing {.path {basename(seg_file)}}")
}

# ── 2. Build the combined LUT (standard context + split hippocampus) ──────
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

# Anterior head = gold, posterior tail = blue; left/right share a colour and
# are told apart by the hemi column (as in the FreeSurfer hypothalamus LUT).
custom_lut <- data.frame(
  idx = NEW_LABELS,
  label = c(
    "Left-Hippocampus-ant",
    "Left-Hippocampus-post",
    "Right-Hippocampus-ant",
    "Right-Hippocampus-post"
  ),
  R = c(220L, 60L, 220L, 60L),
  G = c(190L, 140L, 190L, 140L),
  B = c(30L, 200L, 30L, 200L),
  A = 0L,
  stringsAsFactors = FALSE
)

combined_lut <- rbind(std_lut, custom_lut)

# ── 3. Derive slice views from the split-hippocampus bounding box ─────────
# Compute the bbox in read_volume()'s axis frame (it reorients the NIfTI
# relative to RNifti), so the coronal/axial slabs land on the right slices.
# The hippocampus long axis runs A/P, so coronal slabs through it carry the
# anterior/posterior split, with a couple of axial slabs for overview.
proj_vol <- ggseg.extra:::read_volume(seg_file)
sub_mask <- array(proj_vol %in% NEW_LABELS, dim = dim(proj_vol))
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

# ── 4. Build the ggseg atlas ─────────────────────────────────────────────
cli::cli_h1("Creating anterior/posterior hippocampus atlas")

hc_raw <- create_subcortical_from_volume(
  input_volume = seg_file,
  input_lut = combined_lut,
  atlas_name = "hcpa",
  views = views,
  output_dir = data_raw,
  skip_existing = TRUE,
  cleanup = FALSE
)

# Punch the cerebral white matter out of the brain silhouette so slices show
# the cortical ribbon with the white-matter interior as a hole rather than a
# solid grey blob (see make_hippoamyg.R). Must run before White-Matter is
# removed below.
hc_raw <- atlas_region_op(
  hc_raw,
  x = "^cortex",
  y = "White-Matter$",
  action = "difference",
  into = "cortex"
)

# ── 5. Post-process: drop polygons aseg doesn't show either ───────────────
cli::cli_h2("Post-processing atlas")

hc <- hc_raw |>
  atlas_region_remove("White-Matter", match_on = "label") |>
  atlas_region_remove("WM-hypointensities", match_on = "label") |>
  atlas_region_remove("-Ventricle", match_on = "label") |>
  atlas_region_remove("-Vent$", match_on = "label") |>
  atlas_region_remove("CSF", match_on = "label") |>
  atlas_region_remove("Cerebral-Cortex", match_on = "label") |>
  atlas_region_remove("choroid-plexus", match_on = "label") |>
  atlas_region_remove("vessel", match_on = "label") |>
  atlas_region_remove("CC_", match_on = "label") |>
  # Everything except the four hippocampus parts becomes grey context.
  # "Hippocampus" is deliberately absent from this pattern.
  atlas_region_contextual(
    paste0(
      "Caudate|Putamen|Pallidum|-Thalamus|Amygdala|Accumbens",
      "|VentralDC|Cerebellum|Brain-Stem|Optic-Chiasm",
      "|unknown|Background"
    ),
    "label"
  ) |>
  # clean_region_name lowercases and de-hyphenates; drop the redundant hemi
  # word so regions read "hippocampus ant" / "hippocampus post".
  atlas_region_rename("^(left|right) ", "")

# Drop slabs that contain only context (no hippocampus part).
hc_sf <- ggseg.formats::atlas_sf(hc)
empty_views <- vapply(
  unique(hc_sf$view),
  function(v) {
    rows <- hc_sf[hc_sf$view == v, ]
    !any(rows$label %in% hc$core$label)
  },
  logical(1)
)
empty_views <- names(empty_views)[empty_views]
if (length(empty_views) > 0) {
  cli::cli_alert_info("Dropping context-only view{?s}: {.val {empty_views}}")
  hc <- atlas_view_remove(hc, empty_views)
}

hc <- hc |>
  atlas_view_gather() |>
  atlas_smooth(
    keep = NULL,
    smoothness = 3,
    exclude = "^cortex"
  )

# Cortex outline: heavier close for a smooth silhouette plus light vertex
# simplification, kept low enough to preserve anatomical holes.
hc_2 <- atlas_smooth(
  hc,
  keep = 0.1,
  smoothness = 7,
  labels = "^cortex"
)
plot(hc_2)

cli::cli_alert_success("hcpa: {nrow(hc$core)} regions")
print(hc_2)

# ── 6. Save into sysdata.rda alongside the other atlases ──────────────────
sysdata_path <- here::here("R/sysdata.rda")
if (file.exists(sysdata_path)) {
  load(sysdata_path)
}

.hcpa <- hc_2

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

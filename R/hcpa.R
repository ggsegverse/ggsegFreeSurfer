#' Anterior/Posterior Hippocampus Atlas
#'
#' Atlas of the hippocampus split into an anterior (head) and a posterior
#' (body and tail) part per hemisphere, after the common HCP-style
#' long-axis subdivision. The boundary is the midpoint of each
#' hippocampus's own anterior-posterior extent in the FreeSurfer `aseg`.
#' Built from the `fsaverage5` aseg, so slice views show the hippocampus
#' inside cerebral cortex and white matter (rendered grey as anatomical
#' context).
#'
#' @family ggseg_atlases
#' @family subcortical_atlases
#' @family freesurfer_atlases
#'
#' @return A [ggseg.formats::ggseg_atlas] object (subcortical).
#' @export
#' @examples
#' hcpa()
hcpa <- function() .hcpa

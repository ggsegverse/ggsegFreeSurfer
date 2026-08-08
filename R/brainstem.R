#' Brainstem Substructures Atlas
#'
#' Atlas of the four FreeSurfer brainstem substructures (midbrain, pons,
#' medulla oblongata and superior cerebellar peduncle), as implemented in
#' FreeSurfer's `segment_subregions brainstem` (Iglesias et al. 2015).
#' Built from the `cvs_avg35` template segmentation embedded in its
#' full-brain aseg, so slice views show the brainstem inside cerebral
#' cortex and white matter (rendered grey as anatomical context).
#' Substructure colours come from FreeSurfer's official LUT.
#'
#' @references
#' Iglesias JE, Van Leemput K, Bhatt P, Casillas C, Dutt S, Schuff N,
#' Truran-Sacrey D, Boxer A, Fischl B (2015). "Bayesian segmentation of
#' brainstem structures in MRI." \emph{NeuroImage}, 113:184-195.
#' \doi{10.1016/j.neuroimage.2015.02.065}
#'
#' @family ggseg_atlases
#' @family subcortical_atlases
#' @family freesurfer_atlases
#'
#' @return A [ggseg.formats::ggseg_atlas] object (subcortical).
#' @export
#' @examples
#' brainstem()
brainstem <- function() .brainstem

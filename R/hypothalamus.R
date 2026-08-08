#' Hypothalamic Subunits Atlas
#'
#' Atlas of the five FreeSurfer hypothalamic subunits per hemisphere
#' (anterior-inferior, anterior-superior, posterior, tubular-inferior and
#' tubular-superior), as implemented in FreeSurfer's
#' `mri_segment_hypothalamic_subunits` (Billot et al. 2020). Built from the
#' `cvs_avg35` template segmentation embedded in its full-brain aseg, so
#' slice views show the hypothalamus inside cerebral cortex and white
#' matter (rendered grey as anatomical context). Subunit colours come from
#' FreeSurfer's official LUT.
#'
#' @references
#' Billot B, Bocchetta M, Todd E, Dalca AV, Rohrer JD, Iglesias JE (2020).
#' "Automated segmentation of the hypothalamus and associated subunits in
#' brain MRI." \emph{NeuroImage}, 223:117287.
#' \doi{10.1016/j.neuroimage.2020.117287}
#'
#' @family ggseg_atlases
#' @family subcortical_atlases
#' @family freesurfer_atlases
#'
#' @return A [ggseg.formats::ggseg_atlas] object (subcortical).
#' @export
#' @examples
#' hypothalamus()
hypothalamus <- function() .hypothalamus

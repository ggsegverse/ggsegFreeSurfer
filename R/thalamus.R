#' Thalamic Nuclei Atlas
#'
#' Probabilistic atlas of the 26 thalamic nuclei per hemisphere
#' combining ex vivo MRI and histology, as implemented in FreeSurfer's
#' `segmentThalamicNuclei.sh` (Iglesias et al. 2018). Built from the
#' `cvs_avg35` template segmentation embedded in its full-brain aseg,
#' so slice views show the thalamus inside cerebral cortex and white
#' matter (rendered grey as anatomical context). Nucleus colours come
#' from FreeSurfer's official LUT — the published Iglesias palette.
#'
#' @references
#' Iglesias JE, Insausti R, Lerma-Usabiaga G, Bocchetta M,
#' Van Leemput K, Greve D, van der Kouwe A, Caballero-Gaudes C,
#' Paz-Alonso P (2018). "A probabilistic atlas of the human
#' thalamic nuclei combining ex vivo MRI and histology."
#' \emph{NeuroImage}, 183:314-326.
#' \doi{10.1016/j.neuroimage.2018.08.012}
#'
#' @family ggseg_atlases
#' @family subcortical_atlases
#' @family freesurfer_atlases
#'
#' @return A [ggseg.formats::ggseg_atlas] object (subcortical).
#' @export
#' @examples
#' thalamus()
thalamus <- function() .thalamus

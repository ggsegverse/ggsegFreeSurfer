#' Hippocampal Subfields & Amygdala Nuclei Atlas
#'
#' FreeSurfer segmentation of the hippocampal subfields (Iglesias et al.
#' 2015) and the nuclei of the amygdala (Saygin et al. 2017), as produced
#' by `segment_subregions hippo-amygdala`. Built from the `cvs_avg35`
#' template segmentation embedded in fsaverage5's full aseg, so slice
#' views show the subregions inside cerebral cortex and white matter
#' (rendered grey as anatomical context), surrounded by the neighbouring
#' subcortical structures. Region colours come from FreeSurfer's official
#' LUT.
#'
#' @references
#' Iglesias JE, Augustinack JC, Nguyen K, Player CM, Player A, Wright M,
#' Roy N, Frosch MP, McKee AC, Wald LL, Fischl B, Van Leemput K (2015).
#' "A computational atlas of the hippocampal formation using ex vivo,
#' ultra-high resolution MRI: Application to adaptive segmentation of in
#' vivo MRI." \emph{NeuroImage}, 115:117-137.
#' \doi{10.1016/j.neuroimage.2015.04.042}
#'
#' Saygin ZM, Kliemann D, Iglesias JE, van der Kouwe AJW, Boyd E,
#' Reuter M, Stevens A, Van Leemput K, McKee A, Frosch MP, Fischl B,
#' Augustinack JC (2017). "High-resolution magnetic resonance imaging
#' reveals nuclei of the human amygdala: manual segmentation to automatic
#' atlas." \emph{NeuroImage}, 155:370-382.
#' \doi{10.1016/j.neuroimage.2017.04.046}
#'
#' @family ggseg_atlases
#' @family subcortical_atlases
#' @family freesurfer_atlases
#'
#' @return A [ggseg.formats::ggseg_atlas] object (subcortical).
#' @export
#' @examples
#' hippoamyg()
hippoamyg <- function() .hippoamyg

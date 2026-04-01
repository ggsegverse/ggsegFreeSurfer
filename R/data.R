#' Desikan-Killiany-Tourville Cortical Atlas
#'
#' Cortical parcellation with 32 regions per hemisphere based on
#' the Desikan-Killiany-Tourville labeling protocol. Contains both
#' 2D polygon geometry for [ggseg::geom_brain()] and 3D vertex
#' indices for [ggseg3d::ggseg3d()].
#'
#' @family ggseg_atlases
#' @family cortical_atlases
#' @family freesurfer_atlases
#'
#' @references Klein A, Tourville J (2012). 101 labeled brain
#'   images and a consistent human cortical labeling protocol.
#'   *Frontiers in Neuroscience*, 6:171.
#'   \doi{10.3389/fnins.2012.00171}
#'
#' @return A [ggseg.formats::ggseg_atlas] object (cortical).
#' @export
#' @examples
#' dkt()
#' plot(dkt())
dkt <- function() .dkt

#' Destrieux Cortical Atlas
#'
#' Brain atlas for the Destrieux cortical parcellation
#' (aparc.a2009s) with 75 regions per hemisphere. Contains 2D
#' polygon geometry for [ggseg::geom_brain()].
#'
#' @family ggseg_atlases
#' @family cortical_atlases
#' @family freesurfer_atlases
#'
#' @references Destrieux C, Fischl B, Dale A, Halgren E (2010).
#'   Automatic parcellation of human cortical gyri and sulci
#'   using standard anatomical nomenclature. *NeuroImage*,
#'   53(1), 1-15. \doi{10.1016/j.neuroimage.2010.06.010}
#'
#' @return A [ggseg.formats::ggseg_atlas] object (cortical).
#' @export
#' @examples
#' destrieux()
#' plot(destrieux())
destrieux <- function() .destrieux

#' HCP Subcortical Atlas
#'
#' Human Connectome Project subcortical atlas with aseg regions
#' and anterior/posterior hippocampus subdivisions. Contains 3D
#' mesh geometry for [ggseg3d::ggseg3d()].
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

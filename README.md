

<!-- README.md is generated from README.qmd. Please edit that file -->

# ggsegFreeSurfer

<!-- badges: start -->

[![R-CMD-check](https://github.com/ggsegverse/ggsegFreeSurfer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ggsegverse/ggsegFreeSurfer/actions/workflows/R-CMD-check.yaml)
[![r-universe](https://ggseg.r-universe.dev/badges/ggsegFreeSurfer.png)](https://ggseg.r-universe.dev/ggsegFreeSurfer)
<!-- badges: end -->

This package provides FreeSurfer cortical and subcortical brain atlases
formatted for use with ggseg.

## Installation

We recommend installing the ggseg-atlases through the ggseg
[r-universe](https://ggseg.r-universe.dev/ui#builds):

``` r
options(repos = c(
  ggseg = "https://ggseg.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))

install.packages("ggsegFreeSurfer")
```

You can install this package from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("ggsegverse/ggsegFreeSurfer")
```

# Cortical atlases

## Desikan-Killiany-Tourville (DKT) atlas

``` r
library(ggseg)
library(ggsegFreeSurfer)

plot(dkt())
```

<img src="man/figures/README-dkt-1.png" style="width:100.0%" />

## Destrieux atlas

``` r
plot(destrieux())
```

<img src="man/figures/README-destrieux-1.png" style="width:100.0%" />

# Subcortical atlases

The subcortical atlases are embedded in the full-brain `aseg`, so each
slice view shows the structure of interest within its anatomical context
(cerebral cortex and white matter rendered grey).

## Anterior/posterior hippocampus atlas

``` r
plot(hcpa())
```

<img src="man/figures/README-hcpa-1.png" style="width:100.0%" />

## Thalamic nuclei atlas

``` r
plot(thalamus())
```

<img src="man/figures/README-thalamus-1.png" style="width:100.0%" />

## Hippocampal subfields & amygdala nuclei atlas

``` r
plot(hippoamyg())
```

<img src="man/figures/README-hippoamyg-1.png" style="width:100.0%" />

## Brainstem substructures atlas

``` r
plot(brainstem())
```

<img src="man/figures/README-brainstem-1.png" style="width:100.0%" />

## Hypothalamic subunits atlas

``` r
plot(hypothalamus())
```

<img src="man/figures/README-hypothalamus-1.png" style="width:100.0%" />

## Data source

Desikan RS, Segonne F, Fischl B, Quinn BT, Dickerson BC, Blacker D, … &
Killiany RJ (2006). An automated labeling system for subdividing the
human cerebral cortex on MRI scans into gyral based regions of interest.
*NeuroImage*, 31(3), 968-980.

Destrieux C, Fischl B, Dale A, & Halgren E (2010). Automatic
parcellation of human cortical gyri and sulci using standard anatomical
nomenclature. *NeuroImage*, 53(1), 1-15.

Iglesias JE, Augustinack JC, Nguyen K, Player CM, Player A, Wright M, …
& Van Leemput K (2015). A computational atlas of the hippocampal
formation using ex vivo, ultra-high resolution MRI: Application to
adaptive segmentation of in vivo MRI. *NeuroImage*, 115, 117-137.

Iglesias JE, Van Leemput K, Bhatt P, Casillas C, Dutt S, Schuff N, … &
Fischl B (2015). Bayesian segmentation of brainstem structures in MRI.
*NeuroImage*, 113, 184-195.

Saygin ZM, Kliemann D, Iglesias JE, van der Kouwe AJW, Boyd E, Reuter M,
… & Fischl B (2017). High-resolution magnetic resonance imaging reveals
nuclei of the human amygdala: manual segmentation to automatic atlas.
*NeuroImage*, 155, 370-382.

Iglesias JE, Insausti R, Lerma-Usabiaga G, Bocchetta M, Van Leemput K,
Greve DN, … & Paz-Alonso PM (2018). A probabilistic atlas of the human
thalamic nuclei combining ex vivo MRI and histology. *NeuroImage*, 183,
314-326.

Billot B, Bocchetta M, Todd E, Dalca AV, Rohrer JD, & Iglesias JE
(2020). Automated segmentation of the hypothalamus and associated
subunits in brain MRI. *NeuroImage*, 223, 117287.

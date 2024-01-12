# smoothSSF
Fit step selection functions with non-linear and random effects in mgcv.


This repository contains code to reproduce the analyses of the preprint, "Step selection analysis with non-linear and random effects in mgcv" (Klappstein et al. 2024), as well as several other smaller illustrative examples.

### Basic structure
The `code` folder contains the scripts to reproduce the main analyses of the paper (i.e., the polar and zebra examples). The `examples` folder contains vignette-type files for the paper analyses and other examples. The `data` folder contains all the relevant data.

### Description of examples

1. Polar bear example: fit an SSF with random slopes and hierarchical smooths.
2. Zebra example: fit an SSF with time-varying movement patterns and spatial smoothing.
3. Petrel example: fit an SSF with non-linear habitat selection and a non-parametric movement kernel.
4. Simulated example: fit a spatial smooth to account for an "unknown" centre of attraction

### References

Klappstein NJ, T Michelot, J Fieberg, EJ Pedersen, C Field, and J Mills Flemming. 2024. Step selection analysis with non-linear and random effects in mgcv. bioRxiv. 

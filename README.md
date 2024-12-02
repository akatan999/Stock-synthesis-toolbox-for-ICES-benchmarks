# Stock-synthesis-toolbox-for-ICES-benchmarks
Code and scripts for ICES stock synthesis benchmark models

1.	Run script 1. Ensemble_grid_Lobster3a_example.R for creating the models grid diagnostic table; it creates the diags table and some plots for the next script
2.	Run script 2. Diags_Compare_refruns_Lobster3a example.Rmd for presenting and comparing the different models of the grid 
3.	Run script 3. Lobster3a_basecase model example.Rmd for presenting the best case, includes code for steepness profiling at the end of the script
4.	Script for the F Forecast options but with need to add also biomass options, same SSB as year before, Btrigger and Blim (Henning to be modified for ICES purposes)
5.	Run script for running MSE to estimate reference points as from WKREFNEW reccomandations (example with 2 models, a best case and a robustness test; 3 scripts and an utilities.R script). The example is done with Southern seabass, a lenght based model with SR as B-H for limited number of combinations of Ftarget and Btrigger. One running the final MSE, more combinations should be added. The MSE takes several hours on an ordinary pc, thus it is reccomended to run it over a cluster computer. 

Scripts for additional useful diagnostics

6.	Script for profiling M and h at the same time (new from Laurie, I dont have it yet)
7.	Script for profiling M at age (M_at_age_profile.R)
8.	Script for jittering (Jittering.R using NOAA wrapper); includes also wrappers for retrospective (already run for all models in script 1.) and profiling (also included in script 3)
9.	Use fishlife for estimating life history priors (Fishlife.R)
10.	Identify parameters that changes when running the retro (Retro_sensitivity.R)

Lobster example.zip contains the basecase model and a copy of it as mock example. Run both models and then you can use directly in script 1 as example.


# Stock-synthesis-toolbox-for-ICES-benchmarks
Code and scripts for ICES stock synthesis benchmark models

First, you need to install all necessary packages:

For this, you should use Install packages for stock synthesis benchmark.Rmd (originally created by Henning Winker)

Then you can follow the scheme below:

1.	Run script 1. Ensemble_grid_Lobster3a_example.R for creating the models grid diagnostic table; it creates the diags table and some plots for the next script. Use Lobster example.zip as an example.
2.	Run script 2. Diags_Compare_refruns_Lobster3a example.Rmd for presenting and comparing the different models of the grid 
3.	Run script 3. Lobster3a_basecase model example.Rmd for presenting the best case, includes code for steepness profiling at the end of the script (but see more handy profiling code in Jittering_profiling & retro.R below) 
4.	Script for the F Forecast options but with need to add also biomass options, same SSB as year before, Btrigger and Blim (Henning to be modified for ICES purposes, not yet ready)
5.	Series of scripts for estimating reference points (MSE southern seabass example.zip) running a MSE as from WKREFNEW recommendations (example with 2 models, a best case and a mock robustness test; 3 scripts and an utilities.R script). The example is done with Southern seabass (Southern seabass example.zip), a lenght based model with SR as B-H for limited number of combinations of Ftarget and Btrigger. First, estimate Blim (set to 15% B0 in the example), then create the FLR stock object for MSE and MSE best cases attibutes, finally run the MSE using the rmd file. When running the final MSE, more combinations should be added. The MSE takes several hours on an ordinary pc, thus it is recommended to run it over a cluster computer (originally created by Iago Mosqueira). 

Scripts for additional diagnostics: 

6.	Script for profiling M and steepness at the same time (not yet ready)
7.	Script for profiling M at age (M_at_age_profile.R originally created by Iago Mosqueira)
8.	Script for jittering (Jittering_profiling & retro.R using NOAA wrapper); includes also wrappers for retrospective (which is also run for all models using script 1) and profiling (also included at the end of script 3)
9.	Use fishlife for estimating life history priors (Fishlife.R)
10.	Identify parameters that changes most when running the retro (Retro_sensitivity.R; originally created by Hans Gerritsen))

More additional diagnostics: <br>

11.  R script  [anf.27.3a4_ss3diags_simple.R](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/11.anf.27.3a4_ss3diags_simple.R) to run basic diagnostics with ss3diags for [anf.27.3a4](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/anf.27.3a4.zip) with output [pdf](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/anf.27.3a4_ref.pdf)
12.  NUTS MCMC.R run MCMC both with RWM and NUTS algorithms for your best case model (originally created by Cole Monnahan)
13.  MCMC_plots.R is used for comparing MCMC and MLE models



Lobster example.zip contains the basecase model and a copy of it as mock example. Run first both models and then you can use those directly in script 1 as an example


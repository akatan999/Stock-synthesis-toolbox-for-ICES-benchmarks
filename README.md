# Stock-synthesis-toolbox-for-ICES-benchmarks
Code and scripts for ICES stock synthesis benchmark models

Here we collate a series of scripts and code provided by different authors and used in several ICES workshops and other fora to conduct a full benchmark with a Stock Synthesis to select a bestcase model for advice. 

First, you need to install all necessary packages. 

For this, you can follow the [installation guidelines](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Pdf/Install-packages-for-stock-synthesis-benchmark.pdf) of suggest R packages or run [Install-packages-for-stock-synthesis-benchmark.pdf](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Rmd/Install%20packages%20for%20stock%20synthesis%20benchmark.Rmd)

Then you can follow the scheme below to select the best model from a grid of alternative model configurations:

1.	Run the script [Ensemble_grid_Lobster3a_example.R](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Scripts/Ensemble_grid_Lobster3a%20example.R) for creating the models grid diagnostic table; it creates the diags table and some plots for the next script. Use Lobster [example.zip](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/Data/main/Lobster_example.zip) as an example of a a grid of alternative model configurations.
2.	Run the script [Diags_Compare_refruns_Lobster3a example.Rmd](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Rmd/Diags_Compare_refruns_Lobster3a%20example.Rmd) for presenting and comparing the different models of the a grid of alternative model configurations. 
3.	Run the script [Lobster3a_basecase model example.Rmd](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Rmd/Lobster3a_basecase%20model%20example.Rmd) for presenting the bestcase, includes code for steepness profiling at the end of the script (but see more handy profiling code in Jittering_profiling & retro.R below) 
4.	Run the script [SS3.UserGuide.FishingOpportunities.Rmd](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Rmd/SS3.UserGuide.FishingOpportunities.Rmd) for the ICES F Forecast options, including biomass and TAC status quo options, using [anf.27.3a4.zip](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Data/anf.27.3a4.zip) as an example ([pfd](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Pdf/SS3.UserGuide.FishingOpportunities.pdf)).
5.  Series of scripts for estimating reference points [MSE southern seabass example.zip](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Reference_points/MSE_southern%20seabass%20example.zip) running an MSE as from WKREFNEW recommendations (example with 2 models, a best case and a mock robustness test; 3 scripts and an utilities.R script). The example is done with Southern seabass (Southern seabass example.zip), a lenght based model with SR as B-H for limited number of combinations of Ftarget and Btrigger. First, estimate Blim (set to 15% B0 in the example), then create the FLR stock object for MSE and MSE best cases attibutes, finally run the MSE using the rmd file. When running the final MSE, more combinations should be added. The MSE takes several hours on an ordinary pc, thus it is recommended to run it over a cluster computer (originally created by Iago Mosqueira).
6.  Two additionals scripts for estimating reference points using EqSim for 1-sex and 2-sex models (Example_refPts_SS3_EqSim_1sex_models.Rmd and Example_refPts_SS3_EqSim_2sex_models.Rmd).

Scripts for additional diagnostics: 

6.	Script for profiling M vectors and steepness at the same time (Profiling M and steepness.Rmd, originally created by Laurie Kell). For this to run, you need to create a folder with the 4 files and the exe and call this one "files". 
7.	Script for profiling M at age (M_at_age_profile.R originally created by Iago Mosqueira)
8.	Script for jittering (Jittering_profiling & retro.R using NOAA wrapper); includes also wrappers for retrospective (which is also run for all models using script 1) and profiling (also included at the end of script 3)
9.	Use fishlife for estimating life history priors (Fishlife.R)
10.	Identify parameters that changes most when running the retro (Retro_sensitivity.R; originally created by Hans Gerritsen))

More additional diagnostics: <br>

11.  R script  [anf.27.3a4_ss3diags_simple.R](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Scripts/anf.27.3a4_ss3diags_simple.R) to run basic diagnostics with ss3diags for [anf.27.3a4.zip](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Data/anf.27.3a4.zip) with output [anf.27.3a4_ref.pdf](https://github.com/akatan999/Stock-synthesis-toolbox-for-ICES-benchmarks/blob/main/Pdf/anf.27.3a4_ref.pdf)
12.  NUTS MCMC.R run MCMC both with RWM and NUTS algorithms for your best case model (originally created by Cole Monnahan)
13.  MCMC_plots.R is used for comparing MCMC and MLE models

Lobster example.zip contains the basecase model and a copy of it as mock example. Run first both models and then you can use those directly in script 1 as an example

For estimating sample size of the survey length and age distribution, we recommend using the method described by the Stewart et al., 2014 paper, where you simply need to multiply the number of hauls times 2.73  (general value for all species) described in the paper. For the commercial fisheries sample size of length and age distribution, you need to apply the formula described in the word file (fishery input sample sizes) and included as an example in the excel file (inputN fisheries formula). All necessary documents are embedded in the zip file Sample size.zip.

Script (OSA_residuals.R) for calculating One Step Ahead residuals (OSA) for age based models (example with Central Baltic herring.RData)



#######################################################################################################
# Here are the required packages that should be loaded with the nwfscDiag
# library(HandyCode)
# library(plyr)
# devtools::load_all("C:/Users/Chantel.Wetzel/Documents/GitHub/r4ss")
#devtools::load_all("C:/Users/Chantel.Wetzel/Documents/GitHub/nwfscDiag")
#remotes::install_github("pfmc-assessments/nwfscDiag", force=TRUE)

library(nwfscDiag)

#######################################################################################################
# Define the working directory where the base model is and where all jitter, profile, and retrospective
# runs will be done:

mydir = "C:/Users/mascar/Documents/Max/Commitees/ICES/WKBBASS/Northern stock"

# The base model should be within a fold in the above directory.

#######################################################################################################
# Define the parameters to profile and the parameter ranges:
#------------------------------------------------------------------------------------------------------
# Can use the get_settings_profile function to specify which parameters to run a profile for and 
# the parameter ranges for each profile.  The low and high values can be specified in 3 ways:
# as a 'multiplier' where a percent where the low and high range will be specified as x% of the base 
# parameter (i.e., (base parameter - base parameter* x) - (base parameter + base parameter * x)),
# in 'real' space where the low and high values are in the parameter space, and finally as
# 'relative' where the low and high is a specified amount relative to the base model parameter 
# (i.e., (base parameter - x) - (base parameter + x).
# Here is an example call to the get_settings_profile function:

get = get_settings_profile( parameters =  c("NatM_uniform_Fem_GP_1", "SR_BH_steep", "SR_LN(R0)"),
							low =  c(0.40, 0.25, -2),
							high = c(0.40, 1.0,  2),
							step_size = c(0.005, 0.05, 0.25),
							param_space = c('multiplier', 'real', 'relative'))

#######################################################################################################
# Create a list of settings to run the profiles, jitters, and retrospectives:

model_settings = get_settings(mydir=mydir, settings = list(run = c("jitter", "profile", "retro"),
											  profile_details = get))

# "base_name" is the folder name that contains the base model
# "run" specifies which diagnostics to run. Can be all or a subset.  If all diagnostics should be run 
# 	this does not need to be given to the get_settings function.
# "profile details" defines the parameters to do profiles for and the the range and step size to conduct
# 	the profile over.  The default setting for this function is shown above.

#######################################################################################################
# Run all diagnostics in one goal, the plot are automatically produced at the end

run_diagnostics(mydir = mydir, model_settings = model_settings)

# "mydir" is the working directory (parent folder with the base model)
# "model_settings" defined above using the get_settings function.  The results of this function is a list
# and can be viewed in the R terminal.

#####################################################################################################
#
# Example 2: Run only a profile over steepness
#
#####################################################################################################

get = get_settings_profile( parameters =  c("SR_BH_steep"),
							low =  c(0.65),
							high = c(1.00),
							step_size = c(0.05),
							param_space = c('real'))

model_settings = get_settings(mydir = mydir, settings = list(base_name = "Basecase",
											  run = "profile",
											  profile_details = get))

run_diagnostics(mydir = mydir, model_settings = model_settings)

#####################################################################################################
#
# Example 3: Run only jitters
#
#####################################################################################################

model_settings = get_settings(settings = list(base_name = "Basecase",
											  run = "jitter",
											  Njitter = 100,
											  jitter_fraction = 0.10))

run_diagnostics(mydir = mydir, model_settings = model_settings)

#####################################################################################################
#
# Example 4: Run only retrospectives
#
#####################################################################################################

model_settings = get_settings(settings = list(base_name = "Basecase",
											  run = "retro",
											  retro_yrs = -1:-5))

run_diagnostics(mydir = mydir, model_settings = model_settings)

#####################################################################################################



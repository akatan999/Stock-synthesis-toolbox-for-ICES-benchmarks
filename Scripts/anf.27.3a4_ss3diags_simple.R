#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>
#> Stock Synthesis reference model summary and diagnostic output
#> ICES-WKBSS3
#> @author Henning Winker (GFCM)
#> henning.winker@fao.org
#><>><>><>><>><>><>
# Load packages
library("r4ss")
library("ss3diags")

# First set working directory to the R file location wiht ss3 subfolders

# Define run name of folder
stock = "anf.27.3a4_"
run ="ref"

# Load the model run
ss3rep = SS_output(run)
# Plot the model run
r4ss::SS_plots(ss3rep)
# Save the r4ss object as rdata
dir.create("rdata",showWarnings = F)
save(ss3rep,file=file.path("rdata",paste0(stock,run,".rdata")))

# approximate uncertainty  and produce Kobe Plot
sspar(mfrow=c(1,1))
mvn = SSdeltaMVLN(ss3rep,Fref="Btgt",run=run,catch.type="Exp")
# Plot trajectories with CIs
sspar(mfrow=c(3,2))
SSplotEnsemble(list(mvn),add=T)

#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>
### DO RETRO
#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>
start.retro <- 0 # end year of reference year
end.retro <- 5 # number of years for retrospective e.g.,
dirname.base = run
model.run <- file.path(dirname.base)
model.run
### Step 3: DAT and CONTROL files
DAT = "ang_dat.ss"
CTL = "ang_ctl.ss"
ssexe = "ss3.exe"
dir.retro = file.path(dirname.base, "retrospectives")
dir.create(path = dir.retro, showWarnings = F)

# Copy files
file.copy(file.path(model.run, "starter.ss_new"), file.path(dir.retro, "starter.ss"))
file.copy(file.path(model.run, "control.ss_new"), file.path(dir.retro, CTL))
file.copy(file.path(model.run, DAT), file.path(dir.retro, DAT))
file.copy(file.path(model.run, "forecast.ss"), file.path(dir.retro, "forecast.ss"))
file.copy(file.path(model.run, ssexe), file.path(dir.retro, "ss3.exe"))
# Automatically ignored for models without wtatage.ss
file.copy(file.path(model.run, "wtatage.ss"), file.path(dir.retro, "wtatage.ss"))
starter <- readLines(paste0(dir.retro, "/starter.ss"))
# [8] '2 # run display detail (0,1,2)'
linen <- grep("# run display detail", starter)
starter[linen] <- paste0(1, " # run display detail (0,1,2)")
# write modified starter.ss
write(starter, file.path(dir.retro, "starter.ss"))
### Step 6: Execute retrospective runs
#r4ss::retro(dir = dir.retro, oldsubdir = "", newsubdir = "", years = start.retro:-end.retro)
r4ss::retro(dir = dir.retro, oldsubdir = "", newsubdir = "", years = start.retro:-end.retro,verbose = T)


retro <- r4ss::SSgetoutput(dirvec = file.path(dir.retro, paste0("retro", start.retro:-end.retro)))
save(retro,file=paste0("rdata/retro_",run,".rdata"))

# Reload
load(file=paste0("rdata/retro_",run,".rdata"))
retro.idx = r4ss::SSsummarize(retro)
retro.len = ss3diags::SSretroComps(retro)


#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>
### PROFILING STEEPNESS
#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>

# Create subdirectory for profile runs
dir.create(file.path(getwd(),run, "profile"))
# specify directory
dir_prof <- file.path(getwd(),run, "profile")
# Copy/Paste ss3 files for running profiles
copy_SS_inputs(
  dir.old = file.path(getwd(),run),
  dir.new = dir_prof,
  copy_exe = TRUE,
  create.dir = TRUE,
  overwrite = TRUE,
  copy_par = TRUE,
  verbose = TRUE
)
# Manipulate starter file
starter <- SS_readstarter(file.path(dir_prof, "starter.ss"))
# change control file name in the starter file
starter[["ctlfile"]] <- "control_modified.ss"
# make sure the prior likelihood is calculated
# for non-estimated quantities
starter[["prior_like"]] <- 1
# write modified starter file
SS_writestarter(starter, dir = dir_prof, overwrite = TRUE)

# define steepness range
h.vec <- seq(0.75, 0.95, .05)
# Specify dat and control files
DAT = "ang_dat.ss"
CTL = "ang_ctl.ss"
ssexe = "ss3.exe"
Nprofile <- length(h.vec)
# run profile command
profile <- r4ss::profile(
  dir = dir_prof,
  oldctlfile = paste(CTL),
  newctlfile = "control_modified.ss",
  string = "steep", # subset of parameter label
  exe = ssexe,
  profilevec = h.vec
)
# compile model runs
profilemodels <- SSgetoutput(dirvec = dir_prof, keyvec = 1:Nprofile)
# Save as rdata
save(profilemodels,file=paste0("rdata","/profile_",stock,run,".rdata"))
# summarize output
profilesummary <- SSsummarize(profilemodels)
# Make log-likelihood profile plot
sspar(mfrow=c(1,1))
results <- SSplotProfile(profilesummary,
                         profile.string = "steep", 
                         profile.label = "Stock-recruit steepness (h)"
) 

# check results
results


#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>
### Compile results summary
#><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>><>

# Load data
load(file=file.path("rdata",paste0(stock,run,".rdata")),verbose=T)
load(file=paste0("rdata/retro_",run,".rdata"))
retro.idx = r4ss::SSsummarize(retro)
retro.len = ss3diags::SSretroComps(retro)
load(file=paste0("rdata","/profile_",stock,run,".rdata"),verbose=T)
profilemodels <- SSgetoutput(dirvec = dir_prof, keyvec = 1:length(profilemodels))

# Make output PDF
pdf(paste0(stock,run,".pdf"))



sspar(mfrow=c(2,2),plot.cex = 0.7)
SSplotBiology(ss3rep,mainTitle=F,subplots = c(1))
SSplotBiology(ss3rep,mainTitle=F,subplots = c(21))
SSplotBiology(ss3rep,mainTitle=F,subplots = c(6))
SSplotBiology(ss3rep,mainTitle=F,subplots = c(9))

sspar(mfrow=c(2,2),plot.cex = 0.7)
SSplotBiology(ss3rep,mainTitle=F,subplots = c(4))

# Recruitment
sspar(mfrow=c(2,2),plot.cex = 0.7)
SSplotRecdevs(ss3rep,subplots = 1)
SSplotRecdevs(ss3rep,subplots = 2)
SSplotSpawnrecruit(ss3rep,subplots = 1)
SSplotSpawnrecruit(ss3rep,subplots = 3)

par(mfrow=c(1,1))
SSplotDynamicB0(ss3rep)

sspar(mfrow=c(3,1),plot.cex = 0.7)
SSplotIndices(ss3rep,subplots = 2)


sspar(mfrow=c(1,1),plot.cex = 0.7)
SSplotIndices(ss3rep,subplots =9)

sspar(mfrow=c(2,3),plot.cex = 0.5)
for(i in 1:3){
  SSplotHCxval(retro.idx,add=T,legendloc = "topleft")
  SSplotRunstest(ss3rep,subplots ="cpue",add=T)
}

sspar(mfrow=c(2,1),plot.cex = 0.5)
SSplotHCxval(retro.len,subplots ="len",add=T,legendloc = "topleft")


par(mfrow=c(1,1))
SSplotSelex(ss3rep,subplots = 1)

SSplotComps(ss3rep,subplots = 21)

SSplotComps(ss3rep,subplots = 1)

SSplotSexRatio(ss3rep,kind="LEN")

# Bubble
SSplotComps(ss3rep,subplots = 24)
# ALK
SSplotComps(ss3rep,kind= "cond",subplots = 3)

# Runs Fleets
sspar(mfrow=c(2,1),plot.cex = 0.5)
SSplotRunstest(ss3rep,subplots ="len",add=T,indexselect = 1:2)


# Retro
sspar(mfrow=c(2,2),plot.cex = 0.65)
SSplotRetro(retro.idx,add=T,legend=F,forecast=F)
SSplotRetro(retro.idx,add=T,forecastrho = T,legend=F)
SSplotRetro(retro.idx,subplots = "F",add=T,legend=F,forecast=F)
SSplotRetro(retro.idx,subplots = "F",add=T,forecastrho = T,legend=F)
mtext(c("Retro","Forecast"),3,outer=T,line=-0.5,at=c(0.3,0.8),cex=0.8)

par(mfrow=c(1,1))
SSplotYield(ss3rep,subplots = 2)


sspar(mfrow=c(1,1))
mvn = SSdeltaMVLN(ss3rep,Fref="Btgt",catch.type = "Exp",run="ref")

sspar(mfrow=c(3,2))
SSplotEnsemble(list(mvn),add=T)

# Steepness profile
h = seq(0.75, 0.95, 0.05)


# Plot profile
sspar(mfrow=c(1,1))
results <- SSplotProfile(profilesummary,
                         profile.string = "steep", 
                         profile.label = "Stock-recruit steepness (h)"
)



# Plot sensitivity steepness

mvns = Map(function(x, y) {
  SSdeltaMVLN(x, add = T, run = paste0("h=", y), Fref = "Btgt", catch.type = "Exp",
              years = 1970:2022, verbose = F, plot = F)
}, x = profilemodels, y = h)

sspar(mfrow = c(3, 2), plot.cex = 0.7)
SSplotEnsemble(mvns, uncertainty = T, add = T, legendcex = 0.65, legendloc = "topright",
               verbose = F)
dev.off()

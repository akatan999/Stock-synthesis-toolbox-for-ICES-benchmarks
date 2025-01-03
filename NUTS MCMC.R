### This file demonstrates how to run Bayesian inference on ADMB stock
### assessments using the adnuts R package. We demonstrate a Stock
### Synthesis (SS) model called 'hake'. It is the supplemental material for
### the paper:

### Monnahan, C.C., T.A. Branch, J.T. Thorson, I.J Stewart, C.S. Szuwalski
### (2019). Overcoming long Bayesian run times in integrated fisheries stock
### assessments. ICES Journal of Marine Science.

### The use of SS necessitates slightly different workflow for technical
### reasons. First, when optimizing before MCMC initiate -mcmc 50 to tell
### SS to turn off bias adjustment for recdevs. Otherwise the estimated
### mass matrix will be mismatched when executing the real MCMC chains. Be
### careful not to use MLE estimates from these runs for inference. To save
### time we recommend setting SS to read from the .par file to speed up the
### optimizations below.
### 2/2019 Cole Monnahan | monnahc@uw.edu

#devtools::install_github('colemonnahan/adnuts', ref='dev') 

library(adnuts)
library(snowfall)
library(rstan)
library(shinystan)
library(r4ss)
library(colorspace)
library(doParallel)
#library(plotMCMC)
registerDoParallel(4)

mydir <- "C:/Users/mascar/Documents/Max/Commitees/ICES/WKBENCH/2023/Central Baltic herring/Ensemble/"
reference.dir <- paste0(mydir,'Run1') 
dirname.MCMC_Cole <- paste0(mydir,'NUTS MCMC')

#########
# Copy necassary files from the "Reference_run" subdirectory to the "Retrospective" working directory 
copylst <-  c("HerringSD2532.ctl", "HerringSD2532.dat",  "forecast.ss",  "ss3.exe", "starter.ss", "ss3.par", "wtatage.ss")
for(nn in copylst){file.copy(paste(reference.dir,"/", nn, sep=''), file.path(dirname.MCMC_Cole))}

# Edit "starter.ss" 
starter.file <- readLines(paste(dirname.MCMC_Cole, "/starter.ss", sep=""))
linen <- NULL
linen <- grep("# 0=use init values in control file; 1=use ss.par", starter.file)
starter.file[linen] <- paste0("1 # 0=use init values in control file; 1=use ss.par")
write(starter.file, paste(dirname.MCMC_Cole, "/starter.ss", sep=""))
###############

#reps <- parallel::detectCores()-3 # chains to run in parallel
reps = 3

## Reproducible seeds are passed to ADMB
set.seed(632)
seeds <- sample(1:1e4, size=reps)

## Here we assume the  model is in a folder called 'CBH'. This folder gets copied during parallel runs.
CBH <- dirname.MCMC_Cole

## First optimize the model to make sure the Hessian is good (not necessary if the model is already optimised)

setwd(CBH); system('ss3 -nox -iprint 200 -mcmc 15'); setwd('..')

## Then run parallel RWM chains as a first test
thin <- 10
iter <- 5000*thin; warmup <- iter/10
inits <- NULL ## start chains from MLE

#MCMC with random walk metropolis (RWM)
pilot <- sample_rwm("ss3", iter=iter, thin=thin, seeds=seeds, init=NULL, chains=reps, warmup=warmup, cores=reps, mceval=TRUE, path=dirname.MCMC_Cole)

## Check convergence
mon <- monitor(pilot$samples, warmup=pilot$warmup, print=FALSE)
max(mon[,'Rhat'])
min(mon[,'n_eff'])

## Examine the slowest mixing parameters
slow <- names(sort(mon[,'n_eff']))[1:5]
pdf(file = "Herring 2532.pdf")
pairs_admb(fit=pilot, pars=slow)
dev.off()

## Or can specify them by name (optional)
pairs_admb(fit=pilot, pars=c('recdev1[26]', 'recdev1[25]', 'recdev1[29]'))

pairs_admb(fit=pilot, diag = c("trace", "acf", "hist"), acf.ylim = c(-1, 1),
           ymult = NULL, axis.col = gray(0.5), label.cex = 0.5,
           limits = NULL, pars=slow)

## After regularizing we can run NUTS chains. First reoptimize to get the
## correct mass matrix for NUTS. Note the -hbf 1 argument. This is a
## technical requirement as NUTS uses a different set of bounding
## functions and thus the mass matrix will be different.

setwd(CBH); system(paste('ss3 -hbf 1 -nox -iprint 200 -mcmc 15')); 
check_identifiable("ss", path=dirname.MCMC_Cole)

####If pilot pass the testes then save the mass otherwise go to next step
mass <- pilot$covar.est # note this is in the unbounded parameter space
save.image("NUTS MCMC.RData")
load("NUTS MCMC.RData")

####Lunch shinystan for diagnostic
launch_shinyadmb(pilot)

## Use default MLE covariance (mass matrix) and short parallel NUTS chains
## started from the MLE. Go to next step if you want to start directly from MASS
thin <- 10
iter <- 5000*thin; warmup <- iter/10
inits <- NULL ## start chains from MLE

#MCMC with NUTS (note, it is generally slower than RWM)
nuts.mle <- sample_nuts("ss3", iter=iter, thin=thin, chains=reps, 
warmup=warmup, cores=reps,  seeds=seeds,    
path=dirname.MCMC_Cole, control=list(max_treedepth=2,metric="mle", adapt_delta=0.8))

## Check for issues like slow mixing, divergences, max treedepths with
## ShinyStan and pairs_admb as above. Fix and rerun this part as needed.In this case,max_treedepth might be increased but this slow down the process, so I kept it low as it a less of a problem than having divergences)

#Once the Rhat values are going down and there are no or very few divergences, then you just need to run the model long enough to get an effective sample size large enough to describe your quantities of interest without appreciable Monte-Carlo error
mon <- monitor(nuts.mle$samples, warmup=nuts.mle$warmup, print=FALSE)
max(mon[,'Rhat'])
min(mon[,'n_eff'])

## Examine the slowest mixing parameters
slow <- names(sort(mon[,'n_eff']))[1:5]
pdf(file = "Herring 2532_NUTS_mle.pdf")
pairs_admb(fit=nuts.mle, pars=slow)
dev.off()

####Lunch shinystan for diagnostic
launch_shinyadmb(nuts.mle)

## If good, run again for inference using updated mass matrix with much larger sample size. Increase adapt_delta toward 1 if you have divergences (runs will take longer).
mass <- nuts.mle$covar.est # note this is in the unbounded parameter space
thin <- 100
iter <- 50000*thin; warmup <- iter/10
inits <- NULL ## start chains from MLE

nuts.updated <- sample_nuts("ss", iter=iter, init=inits,  
seeds=seeds, chains=reps, warmup=warmup, path=dirname.MCMC_Cole, 
cores=reps, mceval=TRUE, control=list(metric=mass, adapt_delta=0.8,max_treedepth=2))

## Again check for issues of non-convergence and other standard checks. Then
## use for inference.

mon <- monitor(nuts.updated$samples, warmup=nuts.updated$warmup, print=FALSE)
max(mon[,'Rhat'])
min(mon[,'n_eff'])

## Examine the slowest mixing parameters
slow <- names(sort(mon[,'n_eff']))[1:5]
pdf(file = "Herring 2532_NUTS_updated.pdf")
pairs_admb(fit=nuts.updated, pars=slow)
dev.off()

## Check for issues like slow mixing, divergences, max treedepths with
## ShinyStan and pairs_admb as above. Fix and rerun this part as needed.
launch_shinyadmb(nuts.updated)

## We can calculate efficiecy as ess/time. Since there's multiple chains
## add the time together because the ESS is summed across chains too.

(eff <- min(mon[,'n_eff'])/sum(nuts.updated$time.total))

## Or how long to get 1000 effective samples

1000/eff                                # in seconds
1000/eff/60                             # in minutes

## NOTE: the mceval=TRUE argument tells ADMB to run -mceval on ALL chains
## combined AFTER discarding warmup period and thinning. Thus whatever your
## model outputs during mceval is ready for use in
## management. Alternatively you can run -mceval from the command
## line. sample_admb will merge samples into the .psv file in the main
## folder so either way works.

#Save the work space
save.image("NUTS MCMC.RData")



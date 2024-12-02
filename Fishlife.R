
#*********************************************************************
# SPMpriors: R package for deriving Schaefer and Pella-Tomlinson 
# from FishLife (Thorson 2020) through a MVN Age-Structured Monte-Carlo
# simulaiton approach (Winker et al. 2020)
# Developed by Henning Winker
# JRC-EC, Ispra, 2020
#*********************************************************************


#********************************
# Installation Instructions
#********************************
#install.packages('devtools')
#devtools::install_github("james-thorson/FishLife")
#devtools::install_github("henning-winker/SPMpriors")
#remotes::install_github( 'ropensci/rfishbase@fb-21.06', force=TRUE)
#remotes::install_github("lauriekell/FLCandy")
#********************************

library(SPMpriors)
library(FishLife)
library(rfishbase)
library(FLCandy)

#Get seabass steepness (s) by genus
stk_seabass_steepness = FLCandy:::getTraits(Genus="Dicentrarchus")$mu["s"]

#Get seabass steepness (s) by order
stk_seabass_steepness = FLCandy:::getTraits(Family="Moronidae")$mu["s"]

# (example, not seabass)
# Get MVN stock par replicates from FishLife, while tuning Loo, Lm and h (example)
stk_pikeperch = flmvn_traits(Genus="Sander",Species="lucioperca",Loo=c(70,0.1),Lm=c(42.69,0.1),h=c(0.6,0.99),K=c(0.15,0.1), tmax=c(15,0.1),M=c(0.276, 0.1), Plot=T,savepng = F)
stk_pikeperch$traits 


##Untuned (used)
stk_phenax = flmvn_traits(Genus="Mycteroperca",Species="phenax")
stk_phenax$traits

##Other examples of applications (example, not seabass)
# the r prior can be used Schaefer SPM, but should not be applied in
# Pella-Tomlison SPMs. For the latter it is more appropriate to approximate
# r and shape from an Age-Structured Equilibrium Model (Winker et al. 2020)

# The default assumption is that length at first capture = Lm
fl2asem(stk_pikeperch,mc=1000,plot.progress = T)

# what if Lc < Lm (20cm from the assessment)
fl2asem(stk_pikeperch,mc=1000,Lc=25,plot.progress = F)

library(mseviz)

rclass = function(r=NULL,gt=NULL){
  rg = data.frame(VeryLow=c(0.00001,0.05),Low=c(0.05,0.15),Medium=c(0.150001,0.5),High=c(0.500001,1))
  gg = data.frame(VeryLow=c(50,15),Low=c(15,10),Medium=c(10,5),High=c(5,0))
  
  Fspr = c(50,45,40,35)
  Fsb = c(45,40,35,30)
  selr = selg = 100
  if(is.null(r)==FALSE){
    mur = apply(rg,2,min)
    selr = max(which(r>mur))
  }
  if(is.null(gt)==FALSE){
    mug = apply(gg,2,min)  
    selg = min(which(gt>mug))
  }
  sel = min(selg,selr)
  
  category = names(rg)[sel]  
  return(list(class=category,Fspr=Fspr[sel],Fsb=Fsb[sel]))
}

###Calculate resilience for a list fo stock in FLR (example, not seabass)
resilience = do.call(rbind,lapply(stks,function(x){
  res = resilience(x,s=x@fishlife[["s"]])
  group = rclass(r=mean(res$r),mean(res$gt))
  data.frame(stock=x@name,s=x@fishlife[["s"]],r = round(mean(res$r),2),G= round(mean(res$g),2),resilience=group$class,sprx=group$Fspr,sbx=group$Fsb)
}))

##Calculate generic reference point only based on production function (example, not seabass)
s=0.77
r=0.1
gt=14.097

#Reference points (example, not seabass)
group = rclass(r=mean(r),mean(gt))




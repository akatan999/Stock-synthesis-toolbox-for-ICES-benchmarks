#################
library(compResidual)
#TMB:::install.contrib("https://github.com/vtrijoulet/OSA_multivariate_dists/archive/main.zip")
#devtools::install_github("fishfollower/compResidual/compResidual", INSTALL_opts=c("--no-multiarch"))

osa_ss3 <- function(x, plot=TRUE){ # x is the output list from SS_output in r4ss
  
  '%!in%' <- function(x,y)!('%in%'(x,y))
  
  res <- list()
  
  ## Dirichlet Multinomial OSA residuals
  for (k in unique(x$agedbase$Fleet)){
    
    theta <- subset(x$Age_Comp_Fit_Summary, Fleet==k)$val1
    
    tmp <- subset(x$agedbase, Fleet==k) # Obs = observed prop at age, Exp = predicted prop at age
    #tmp$obsN <- tmp$Obs*tmp$DM_effN
    tmp$obsN <- tmp$Obs*tmp$Nsamp_DM
    tmp$alpha <- tmp$Exp*theta*tmp$Nsamp_adj
    
    tmp2 <- reshape(tmp[,c("Yr", "Bin", "obsN", "alpha")], idvar="Bin", timevar="Yr", direction="wide")
    
    DM_obs <- as.matrix(tmp2[,grep("obsN",colnames(tmp2))]) # obs should be rounded 
    DM_alpha <- as.matrix(tmp2[,grep("alpha",colnames(tmp2))]) # pred cannot be 0
    
    osa_res <- resDirM(round(DM_obs), DM_alpha)
    dimnames(osa_res) <- list(tmp2$Bin[-nrow(DM_obs)], unique(tmp$Yr))
    if (length(as.numeric(colnames(osa_res))[1]:as.numeric(colnames(osa_res))[ncol(osa_res)])!=ncol(osa_res)) {
      missing_years <- (as.numeric(colnames(osa_res))[1]:as.numeric(colnames(osa_res))[ncol(osa_res)])[as.numeric(colnames(osa_res))[1]:as.numeric(colnames(osa_res))[ncol(osa_res)] %!in% as.numeric(colnames(osa_res))]
      tmp3 <- matrix(nrow=nrow(osa_res), ncol=length(missing_years), dimnames=list(rownames(osa_res), missing_years))
      osa_res <- cbind(osa_res,tmp3)[,as.character(as.numeric(colnames(osa_res))[1]:as.numeric(colnames(osa_res))[ncol(osa_res)])]
      class(osa_res) <- "cres"
    }
    if (plot) plot(osa_res, main=paste0("Fleet ", k))
    
    res[[length(res)+1]] <- osa_res
  }
  res
}

library(r4ss)
out <- SS_output(dir="~/Max/Commitees/ICES/WKBENCH/2023/Central Baltic herring/Ensemble/Run1_old",covar=T)

ss3rep <- out
res <- osa_ss3(ss3rep)

plot(osa_ss3(ss3rep)[[1]],main=paste0("Fleet ", 1) )
dev.print(jpeg,paste0(main.dir,"/OSA_1_reference_run.jpg"), width = 12, height = 8, res = 300, units = "in")

plot(osa_ss3(ss3rep)[[2]],main=paste0("Fleet ", 2) )
dev.print(jpeg,paste0(main.dir,"/OSA_2_reference_run.jpg"), width = 12, height = 8, res = 300, units = "in")

plot(res[[1]], pick_one = 1,main=paste0("Fleet ", 1) )
plot(res[[2]], pick_one = 1,main=paste0("Fleet ", 2) )

plot(res[[2]],main=paste0("Fleet ", 2) )


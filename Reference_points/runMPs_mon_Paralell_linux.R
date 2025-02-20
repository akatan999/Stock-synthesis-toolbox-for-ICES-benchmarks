

#### Combine 
library(doParallel)
library(FLRef)
load("~/openMSE/SCsexseas/rdata/inpMP.rdata",verbose=T)
length(hcrs$target)
# Run in batches
ids = 1:8
hcrs1 = hcrs 
hcrs1$target = hcrs1$target[ids]
hcrs1$trigger = hcrs1$trigger[ids]
ni = length(ids)
cl = ni
registerDoParallel(cl)

# load R packages in parallel workers on Windows
. <- foreach(i = seq(ni)) %dopar% {
  library(FLRef)
  library(mse)
  return(NULL)
}

start = Sys.time()
run1 <- foreach(i = seq(ni)) %dopar% {
  
  # set stock index
  hs = hcrs1 
  hs$target = hs$target[i]
  hs$trigger = hs$trigger[i]
  
  runi <- runs <- mps(om, oem=oem, ctrl=arule, args=mseargs,hcr=hs,parallel = FALSE)
  
  return(runi)
} # end of loop 
end = Sys.time()
time = end-start
time

#names(run1) = names(controls1)

save(run1,file=paste0("rdata/mp_runs1a.rdata"))


# Run in batches
ids = 9:16
hcrs2 = hcrs 
hcrs2$target = hcrs2$target[ids]
hcrs2$trigger = hcrs2$trigger[ids]
ni = length(ids)
cl = ni
registerDoParallel(cl)
start = Sys.time()
run2 <- foreach(i = seq(ni)) %dopar% {
  
  # set stock index
  hs = hcrs2 
  hs$target = hs$target[i]
  hs$trigger = hs$trigger[i]
  
  runi <- runs <- mps(om, oem=oem, ctrl=arule, args=mseargs,hcr=hs,parallel = FALSE)
  
  return(runi)
} # end of loop 
end = Sys.time()
time = end-start
time

# test 


# Run in batches
ids = c(1,6,6+8,7+8)
hcrs3 = hcrs 
hcrs3$target = hcrs3$target[ids]
hcrs3$trigger = hcrs3$trigger[ids]
ni = length(ids)
cl = ni
registerDoParallel(cl)
start = Sys.time()
run3 <- foreach(i = seq(ni)) %dopar% {
  
  # set stock index
  hs = hcrs3 
  hs$target = hs$target[i]
  hs$trigger = hs$trigger[i]
  
  runi <- runs <- mps(om, oem=oem, ctrl=arule, args=mseargs,hcr=hs,parallel = FALSE)
  
  return(runi)
} # end of loop 
end = Sys.time()
time = end-start
time

# test 
# fill missing runs
run1[[1]] = run3[[1]]
run1[[6]] = run3[[2]]
run2[[6]] = run3[[3]]
run2[[7]] = run3[[4]]

save(run3,file=paste0("rdata/mp_runs3a.rdata"))

save(run1,file=paste0("rdata/mp_runs1b.rdata"))
save(run2,file=paste0("rdata/mp_runs2b.rdata"))


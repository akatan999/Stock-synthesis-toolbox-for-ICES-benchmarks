#####################
library(r4ss)
library(dplyr)
library(tidyr)
library(ggplot2)

dirname.rec <- './Retrospective'  # this is the folder with retrospectives
dirvec <- list.dirs(dirname.rec,recursive = F)
dirvec <- c(dirvec[length(dirvec)],dirvec[-length(dirvec)]) #get the order right, no more than 9 peels

replist1 <- SSgetoutput(dirvec=dirvec)
retr <- SSsummarize(replist1)  

# which parameters change in the retros
a <- cbind(retr$pars,retr$parphases) 
names(a)[1:length(dirvec)] <- gsub(dirname.rec,'',dirvec)
b <- a %>% pivot_longer(1:length(dirvec),names_to='model') %>% 
  mutate(model=ordered(model,gsub(dirname.rec,'',dirvec)))
b <- b %>% group_by(Label) %>% mutate(stdev=sd(value),mean=mean(value))

# only keep parameters that are not annual (like F) and that vary more than 1%
c <- subset(b,is.na(Yr) & replist1>0 & !is.na(stdev) & stdev/mean>0.01)

sspar(mfrow=c(1,1),plot.cex = 0.7)
ggplot(c,aes(model,value)) + geom_point() + 
  facet_wrap(~Label,scales='free_y') +
  theme(strip.text=element_text(size=8)) + expand_limits(y=0) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
dev.print(jpeg, "Retro_sensitivity.jpg",
          width = 12, height = 8, res = 300, units = "in")
dev.off()

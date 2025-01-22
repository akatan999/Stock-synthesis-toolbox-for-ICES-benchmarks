# ms.R - DESC
# /home/mosqu003/ms.R

# Copyright (c) WUR, 2024.
# Author: Iago MOSQUEIRA (WMR) <iago.mosqueira@wur.nl>
#
# Distributed under the terms of the EUPL-1.2

# XX {{{
# }}}

library(r4ss)
library(TAF)
library(doFuture)
library(ss3om)
library(data.table)
library(ggplot2)

plan(multicore, workers=4)
setwd("C:/Users/mascar/Documents/Max/Commitees/ICES/WKBENCH/2024/North Sea sole/Final run/")

# M values
ms <- seq(0.20, 0.50, by=0.025)

mruns <- foreach(m=setNames(ms, nm=paste0('m', ms))) %dofuture% {

  path <- paste0("M/ms/m", m)

  mkdir(path)
  cp("./Likelihood profiles/M/*", path)

  parlines <- SS_parlines(file.path(path, "SoleNS_new.ctl"))
  
  newm <- parlines[1:10, 3] / mean(parlines[1:10, 3]) * m

  SS_changepars(dir=path, ctlfile='SoleNS_new.ctl', newctlfile='SoleNS_new.ctl',
    linenums=seq(64, 73), newvals=newm)

  r4ss::run(path, exe="ss3", show_in_console=TRUE)

#  retro(path, exe="ss3", show_in_console=TRUE)

  return(path)
}

mouts <- lapply(setNames(mruns, ms), SS_output)
stks <- lapply(setNames(mruns, ms), readFLSss3)

plot(FLStocks(stks))

M_log <- rbindlist(lapply(mouts, ss3om::buildRESss3), idcol='run')
#M_log <- res[res$SSB_endyr>0,]

plname = "Loglikelihood M"
pwidth = 8
pheight = 6
res=500
windows(width=pwidth,height=pheight)
p <- ggplot(M_log, aes(x = run, y = as.numeric(LIKELIHOOD),
                                           label = "")) +
  geom_point(stat = "identity") + geom_text(
    size = 3, position = position_stack(vjust = 0.5))  +
  ylim(3750,3900) + theme_bw() + labs(y="Loglikelihood", x="M scalar")
dev.print(jpeg,paste0(plname,".jpg"), width = pwidth, height = pheight, res = res, units = "in")
dev.off()

ggsave("Loglikelihood M.tiff",dpi=300)




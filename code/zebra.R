################################################################
#### this script recreates the zebra illustrative example ######
#### with varying coefficients and spatial smoothing  #########
###############################################################

# load packages
library(mgcv)
library(gratia)
library(ggplot2)
library(tictoc)
library(cowplot)
library(wesanderson)
library(dplyr)
theme_set(theme_bw())

# load and prep data
data <- readRDS("data/zebra.RData")
data$times <- 1 # dummy time variable
head(data)

# fit model
fit <- gam(cbind(times, stratum) ~ 
             log(step) + 
             s(tod, by = step, bs = "cc", k=15) + # time-varying step length
             cos(angle) + 
             veg + 
             s(x, y), # spatial smooth
           data = data,
           family = cox.ph, 
           weights = obs)

#########################
## plot varying coef ##
#######################

# load sampling parameters
par <- read.csv("data/zebra_par.csv")

# get smooth terms
smooths <- smooth_estimates(fit, smooth = "s(tod):step", n = 1000)

# translate to mean/sd
beta_L <- smooths$est / smooths$step[1] - (1/par$scale) 
beta_logL <- fit$coefficients[1] + par$shape - 2
mean <- -(beta_logL + 2) / (beta_L)
lower <- (smooths$est - smooths$se * 1.96) / smooths$step[1] - (1/par$scale)
upper <- (smooths$est + smooths$se * 1.96) / smooths$step[1] - (1/par$scale)

#plot
df <- data.frame(tod = smooths$tod, 
                 mean = mean,
                 beta_L = beta_L, 
                 lower = lower, 
                 upper = upper)

ggplot(df, aes(x = tod, y = mean)) +
  geom_line() + 
  xlab("time of day") + ylab("mean step length (km)")

ggplot(df, aes(x = tod, y = beta_L)) +
  geom_line() + 
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.5) +
  xlab("time of day") + ylab(expression(beta[step]))



#########################
## plot spat smooth ##
#######################
spatial <- smooth_estimates(fit, smooth = "s(x,y)")
plot_grid(ggplot(spatial, aes(x = x, y = y, fill = est)) + 
            geom_raster() + coord_equal() +
            scale_fill_distiller(palette = "RdBu" , limits = c(-5.1, 5.1)) +
            geom_point(aes(x = x, y = y, fill = obs), data = obs, alpha = 0.2, size = 0.1), 
          labels = "c)")




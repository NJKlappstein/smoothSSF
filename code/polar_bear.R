################################################################
#### this script recreates the polar bear illustrative  #######
#### example with random slopes and hierarchical smooths  #####
###############################################################

# load packages
library(mgcv)
library(gratia)
library(dplyr)
library(ggplot2)
library(cowplot)
library(CircStats)

# load location data and add dummy time column
data <- readRDS("data/polar_bear.RData")
data$times <- 1
head(data)

################
### models ####
###############

# fit with random slopes
fit_slopes <- gam(cbind(times, stratum) ~ 
                    step + 
                    log(step) + 
                    cos(angle) +
                    ice_conc + 
                    s(ice_conc, ID, bs = "re") , #random slope
                  data = data,
                  family = cox.ph, 
                  weights = obs)

# hierarchical smooths via a factor smooth basis
fit_smooths <- gam(cbind(times, stratum) ~ 
                     step + 
                     log(step) + 
                     cos(angle) +
                     s(ice_conc, k = 5) + 
                     s(ice_conc, ID, k = 5, bs = "fs"), # factor smooth
                   data = data,
                   method = "REML",
                   family = cox.ph, 
                   weights = obs)

# look at summaries for both models
summary(fit_slopes)
summary(fit_smooths)

# check AIC
AIC(fit_slopes, fit_smooths)
AIC(fit_smooths) - AIC(fit_slopes)


###############################
# make plot of random slopes ##
###############################

# get list of bear IDs
bears <- unique(data$ID)

# create grid of ice concentration for prediction
ice_grid <- seq(0, 100, 1)

# obtain slope estimate for each bear
coefID <- as.vector(coef(fit_slopes)[5:(4+length(bears))]) # deviation from populaton
slopeID <- coefID + coef(fit_slopes)[4] # add to get slope

# predict for each individual
pred_slopes <- NULL
for(i in 1:13) {
  r_slope <- data.frame(bearID = bears[i], 
                        ice_conc = ice_grid,
                        RSS = exp(slopeID[i] * ice_grid))
  pred_slopes <- rbind(pred_slopes, r_slope)
}

# plot random slopes
ggplot(data = pred_slopes, aes(x = ice_conc, y = RSS, group = bearID)) + 
  geom_line(color = "firebrick", alpha = 0.5)+
  ggtitle("") +
  ylim(c(0,6)) +
  ylab(expression(exp(beta[ice]))) +
  xlab("Ice concentration (%)") +
  theme_bw() + 
  theme(legend.position = "none")


###############################
# make plot of random smooths #
###############################

# get all smooth estimates and isolate pop-level smooth
r_smooths <- smooth_estimates(fit_smooths)
pop_smooth <- r_smooths[c(1:100),]

pred_smooths <- NULL
for(i in 1:length(bears)) {
  # smooths for individual i
  smooth_sub <- subset(r_smooths, .smooth == "s(ice_conc,ID)" & ID == bears[i])
  
  # add individual deviation to pop-level smooth
  smooth_sub <- data.frame(ID = bears[i],
                           ice_conc = smooth_sub$ice_conc,
                           est = smooth_sub$.estimate + pop_smooth$.estimate)
  
  pred_smooths <- rbind(pred_smooths, smooth_sub)
}

# plot
ggplot(data = pred_smooths, aes(x = ice_conc, y = exp(est), group = ID)) + 
  geom_line(color = "royalblue", alpha = 0.6)+
  ylim(c(0, 2.35)) +
  ggtitle("") +
  ylab(expression(exp(f(ice)))) +
  xlab("Ice concentration (%)") +
  theme_bw() + 
  theme(legend.position = "none")









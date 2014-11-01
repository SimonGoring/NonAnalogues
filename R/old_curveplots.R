
library(mgcv)

compiled.to.indiv <- match(pollen.frame$site, indiv.sites$site)
compiled.to.compiled <- match(pollen.frame$site, compiled.pollen$sitename)

clim.in.pol <- pollen.frame$uniqueID[pollen.frame$uniqueID %in% climate.frame$uniqueID]

full.frame <- data.frame(rbind(pollen.frame[clim.in.pol,], climate.frame[clim.in.pol,]),
                         lat = rep(compiled.pollen$lat[compiled.to.indiv], 2),
                         long = rep(compiled.pollen$long[compiled.to.indiv], 2),
                         age.model = rep(compiled.pollen$date.type[compiled.to.compiled], 2),
                         domain = rep(indiv.sites$domain[compiled.to.indiv], 2),
                         division = rep(indiv.sites$division[compiled.to.indiv], 2),
                         province = rep(indiv.sites$province[compiled.to.indiv], 2),
                         was.na = FALSE,
                         variable = rep(c('pollen', 'climate'), each = nrow(pollen.frame)),
                         stringsAsFactors = FALSE)

full.frame <- full.frame[!(is.na(full.frame$min) | full.frame$min == 0),]

#  A number of sites have either Lake assignments (they are in the Great Lakes) or 
#  NA assignments (they are on the coastline, and don't fall within the ecozone
#  shapefile).  This re-assigns values for these points.
#  This also removes the "Humid Tropical" ecozone because these samples only span the
#  last 4500 years.  Not a long enough record.

source('R/data_cleaning.R')

#  The Humid Temperate Domain

for(i in 1:1500){
  #  This loop pulls out the 95% CI samples within 500 year time steps at 10 year intervals.
  #  This means that if a sample is outside the 95% ci for the 500 years within any 10 year
  #  timestep that covers the 500 year period it will be marked.
  age.class <- full.frame$age %in% (i*10):((i*10)+500)
  
  clim.cut <- age.class & full.frame$variable=='climate'
  pol.cut  <- age.class & full.frame$variable=='pollen'
  
  clim.quant <- quantile(full.frame$min[clim.cut], 
                         probs=0.90, na.rm=TRUE)
  pol.quant <- quantile(full.frame$min[pol.cut],
                        probs=0.90, na.rm=TRUE)
  
  full.frame$nf[clim.cut & full.frame$min > clim.quant] <- 'red'
  full.frame$nf[pol.cut & full.frame$min > pol.quant] <- 'red'
}

what <- full.frame$domain %in% c('HUMID TEMPERATE DOMAIN') &
  !full.frame$age.model %in% c('Radiocarbon years BP')

full.frame$self <- factor(full.frame$self, 
                          levels = c(TRUE, FALSE), 
                          labels= c('Turnover', 'Landscape Change'))

curve <- ggplot(aes(x = age, y = min), data = full.frame[what,]) + 
  geom_point(aes(color = nf)) +
  #scale_color_identity() +
  #geom_smooth(formula = y ~ s(x, k = 40), method='gam', family = Gamma, size = 2) +
  #geom_smooth(formula = y ~ s(x, k = 40), 
  #            method='gam', family = Gamma, size = 1, color = 'black', linetype = 2) +
  scale_x_continuous(limits = c(0, 15000), expand=c(0,0)) +
  scale_y_sqrt(expand=c(0,0)) +
  theme_bw() + 
  theme(axis.title = element_text(family='serif', face='italic', size=20),
        axis.text = element_text(family='serif', size=16),
        legend.position = 'none') +
  xlab('Radiocarbon Years Before Present') +
  ylab('Landscape Dissimilarity') +
  facet_wrap(~variable + self, ncol = 2, scale='free')

points <- ggplot(data = data.frame(map), aes(long, lat)) + 
  geom_path(aes(group=group), color='black') +
  geom_point(data = pollen.frame[pollen.frame$min > quantile(pollen.frame$min, 0.95, na.rm=TRUE) & what, ], 
             aes(x = long, y = lat, size = min*10), alpha=0.2, color = 'red') +
  scale_size_identity() +
  coord_map(xlim=c(-100, -59), ylim=c(21, 50)) + theme_bw()

curve

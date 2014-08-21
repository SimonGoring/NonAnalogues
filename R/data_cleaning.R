#  Re-assign domains to sites with NA domains.
#  These are 12 sites, almost all on the ocean margin.
#  These sites
library(rgeos)

for(i in 1:nrow(full.frame)){
  if(is.na(full.frame$domain[i])){
    missing.points <- full.frame[i,]
    coordinates(missing.points) <- ~ long + lat
    proj4string(missing.points) <- CRS(proj4string(ecoregions))
    
    aa <- which.min(gDistance(missing.points, ecoregions, byid=TRUE))
    full.frame$domain[i] <- as.character(ecoregions@data$DOMAIN)[which.min(aa)]
    full.frame$division[i] <- as.character(ecoregions@data$DIVISION)[which.min(aa)]
    full.frame$province[i] <- as.character(ecoregions@data$PROVINCE)[which.min(aa)]
    full.frame$was.na[i] <- TRUE
  }
}



full.frame <- full.frame[!full.frame$domain == 'HUMID TROPICAL DOMAIN',]

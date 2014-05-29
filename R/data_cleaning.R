#  Re-assign domains to sites with NA domains.
#  These are 12 sites, almost all on the ocean margin.
#  These sites
library(rgeos)

for(i in 1:nrow(pollen.frame)){
  if(is.na(pollen.frame$domain[i])){
    missing.points <- pollen.frame[i,]
    coordinates(missing.points) <- ~ long + lat
    proj4string(missing.points) <- CRS(proj4string(ecoregions))
    
    aa <- which.min(gDistance(missing.points, ecoregions, byid=TRUE))
    pollen.frame$domain[i] <- as.character(ecoregions@data$DOMAIN)[which.min(aa)]
    pollen.frame$division[i] <- as.character(ecoregions@data$DIVISION)[which.min(aa)]
    pollen.frame$province[i] <- as.character(ecoregions@data$PROVINCE)[which.min(aa)]
    pollen.frame$was.na[i] <- TRUE
  }
}

pollen.frame <- pollen.frame[!pollen.frame$domain == 'HUMID TROPICAL DOMAIN',]

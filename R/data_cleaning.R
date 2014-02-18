#  Re-assign domains to sites with NA domains.
#  These are 12 sites, almost all on the ocean margin.
#  These sites
library(rgeos)

for(i in 1:nrow(rf)){
  if(is.na(rf$domain[i])){
    missing.points <- rf[i,]
    coordinates(missing.points) <- ~ long + lat
    proj4string(missing.points) <- CRS(proj4string(ecoregions))
    
    aa <- which.min(gDistance(missing.points, ecoregions, byid=TRUE))
    rf$domain[i] <- as.character(ecoregions@data$DOMAIN)[which.min(aa)]
    rf$division[i] <- as.character(ecoregions@data$DIVISION)[which.min(aa)]
    rf$province[i] <- as.character(ecoregions@data$PROVINCE)[which.min(aa)]
    rf$was.na[i] <- TRUE
  }
}

rf <- rf[!rf$domain == 'HUMID TROPICAL DOMAIN',]

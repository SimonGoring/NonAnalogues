load('data/compiled.pollen.RData')

library(ncdf)


#  This basic workflow is borrowed from the get.var.ncdf help file
#  David Pierce (2011). ncdf: Interface to Unidata netCDF data files. R package version 1.6.6.
#  http://CRAN.R-project.org/package=ncdf
#  I want to find and extract the closest value for each sample in x, y and time:
pull.vals <- function(x, var, months){
  lon <- get.var.ncdf(x, 'lon')
  lat <- get.var.ncdf(x, 'lat')
  age <- get.var.ncdf(x, 'time')
  
  data <- rep(NA, nrow(compiled.pollen))
  
  for(i in 1:nrow(compiled.pollen)){
    which.lon <- which.min(abs(lon - compiled.pollen$long[i]))
    which.lat <- which.min(abs(lat - compiled.pollen$lat[i]))
    which.age <- which.min(abs(age + round(compiled.pollen$age[i]/10,0)))
      
    mvals <- rep(NA, length(months))
    
    for(j in 1:length(months)){
      start <- c(which.lon, which.lat, months[j], which.age)
      count <- c(1, 1, 1, 1)
      mvals[j] <- get.var.ncdf(x, var, start = start, count = count)
    }
    
    data[i] <- mean(mvals)
    
  }
  return(data)
}

prcp <- open.ncdf('C:/Users/goring/Documents/WISC/CCSM_downscaling/CCSM3/prcp3.nc')

psum.vals <- pull.vals(prcp, 'prcp', c(6, 7, 8))
pwin.vals <- pull.vals(prcp, 'prcp', c(12, 1, 2))

temp <- open.ncdf('C:/Users/goring/Documents/WISC/CCSM_downscaling/CCSM3/temp3.nc')

twin.vals <- pull.vals(temp, 'tmin', c(12, 1, 2))
tsum.vals <- pull.vals(temp, 'tmax', c(6, 7, 8))

compiled.climate <- data.frame(compiled.pollen[,1:5],
                               twin = twin.vals,
                               tsum = tsum.vals,
                               pwin = pwin.vals,
                               psum = psum.vals)

save(compiled.climate, file='compiled.climate.RData')

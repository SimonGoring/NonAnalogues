#  Loading spatial data for the paper.

ecoregions <- spTransform(readOGR('data/Ecoregions_NA/na_regns.shp', 'na_regns'),
                          CRSobj=CRS('+proj=longlat +ellps=WGS84'))

ecoregions <- ecoregions[!ecoregions@data$DIVISION == 'Lake',]

indiv.sites <- data.frame(site = unique(compiled.pollen$sitename),
                          compiled.pollen[!duplicated(compiled.pollen$sitename), c('lat', 'long')],
                          samples = as.vector(table(compiled.pollen$sitename)))

extract.eco <- over(SpatialPoints(indiv.sites[,3:2], proj4string=CRS(proj4string(ecoregions))), ecoregions)

indiv.sites$domain <- as.character(extract.eco$DOMAIN)
indiv.sites$division <- as.character(extract.eco$DIVISION)
indiv.sites$province <- as.character(extract.eco$PROVINCE)

map <- map_data('world')

map <- subset(map, map$long > -100 & map$long < -45)
map <- subset(map, map$lat > 20 & map$lat < 65)

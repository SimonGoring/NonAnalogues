#  Okay, this is the code for the non-analogue analysis:

all_sites <- get_datasets(datasettype = 'pollen')

all.downloads <- get_download(sapply(all_sites, function(x)x$DatasetID))

aa <- lapply(all.downloads, function(x) try(nrow(x$counts) == nrow(x$sample.meta)))

compiled.sites <- lapply(all.downloads, function(x) compile_list(x, list.name='WS64'))

for(i in 1:length(compiled.sites)){
  
  x <- compiled.sites[[i]]
  
  if(is.null(x$metadata$site.data$SiteName)) x$metadata$site.data$SiteName <- paste('NoName_ID', i)
  if(is.null(x$sample.meta$depths)) x$sample.meta$depths <- NA
  if(is.null(x$sample.meta$Age)) x$sample.meta$Age <- NA
  if(is.null(x$metadata$site.data$LatitudeNorth)) x$metadata$site.data$LatitudeNorth <- NA
  if(is.null(x$metadata$site.data$LongitudeWest)) x$metadata$site.data$LongitudeWest <- NA
  
  site.info <- data.frame(sitename = x$metadata$site.data$SiteName,
                          depth = x$sample.meta$depths,
                          age = x$sample.meta$Age,
                          lat = x$metadata$site.data$LatitudeNorth,
                          long = x$metadata$site.data$LongitudeWest)
  
  site.info <- site.info[x$sample.meta$IDs %in% rownames(x$count), ]
  
  if(i == 1){
    
    compiled.pollen <- data.frame(site.info, x$counts)
  } 
  
  if(i > 1) {
      aa <- try(merge(compiled.pollen, data.frame(site.info, x$counts), all=TRUE))
      
      if(length(aa) > 1) compiled.pollen <- aa
    }

  cat(i, '\n')
}


save(compiled.pollen, file='data/all_sites_compiled.RData')
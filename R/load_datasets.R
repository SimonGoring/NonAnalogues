#  Okay, this is the code for the non-analogue analysis:

library(neotoma)
library(plyr)

#  Getting all the sites from neotoma is time consuming:
if(!'all.sites.RData' %in% list.files('data/output')){
  all.datasets <- get_datasets(datasettype = 'pollen')
  data.ids <- sapply(all.datasets, function(x)x$DatasetID)

  #  Return all pollen sites in neotoma:
  all.sites <- llply(data.ids, .fun = function(x)try(get_download(x)))
  
  rm(data.ids, all.datasets)
  
  save(all.sites, file='data/output/all.sites.RData')
}
if('all.sites.RData' %in% list.files('data/output')){
  load('data/output/all.sites.RData')
}

#  Compress the dataset taxonomies to the standard of the small Whitmore taxonomy.
if('compiled.sites.Rdata' %in% list.files('data/output/')){
  load('data/output/compiled.sites.RData')
}

if(!('compiled.sites.Rdata' %in% list.files('data/output'))){
  
  compiled.sites <- llply(all.sites, 
                          .fun = function(x) try(compile_list(x, list.name='WhitmoreSmall', type = TRUE, cf=TRUE)),
                          .progress = 'text')
  

  #  Pull in age models from Blois et al.
  blois.models <- list.files('data/input/Neotoma2/')
  dataset.handles <- sapply(compiled.sites, function(x)try(x$metadata$dataset$collection.handle))
  site.handle <- unique(substr(blois.models, 1, regexpr('.', blois.models, fixed=TRUE) - 1))
  
  blois.match <- match(dataset.handles, site.handle)
  
  for(i in 1:length(compiled.sites)){
    if(!is.na(blois.match[i])){
      age <- read.csv(paste0('data/input/Neotoma2/', site.handle[blois.match[i]], '.age.model.csv'))
      compiled.sites[[i]]$sample.meta$Age <- age$best.age
      compiled.sites[[i]]$sample.meta$AgeType <- 'Calibrated radiocarbon years BP (Blois)'
    }
  }
  
  rm(age, blois.models, dataset.handles, blois.match)
  
  save(compiled.sites, file='data/compiled.sites.RData')  
}


#  Make the dataset into one giant table with site name, lat/long, depth and age and then counts:
if(!('compiled.pollen.RData' %in% list.files('data/output'))){
  
  source('R/compile_it.R')
  
  compiled.pollen <- ldply(compiled.sites, .fun = function(x)compile_it(x), .progress = 'text')
  
  include <- !(is.na(compiled.pollen$age) | 
                 is.na(compiled.pollen$depth) | 
                 compiled.pollen$age > 22000 |
                 compiled.pollen$lat < 23 |
                 compiled.pollen$lat > 65 |
                 compiled.pollen$long > -40 |
                 compiled.pollen$long < -100 |
                 compiled.pollen$sitename %in% 'Mangrove Lake')
  
  compiled.pollen <- compiled.pollen[include, ]
  compiled.pollen$sitename <- as.character(compiled.pollen$sitename)
  compiled.pollen[is.na(compiled.pollen)] <- 0
  
  compiled.pollen$uIDs <- 1:nrow(compiled.pollen)
  
  non.pol <- c("sitename", "depth", "age", "date.type", "lat", "long", "dataset", 'uIDs')
  
  pol.pct <- compiled.pollen[,!colnames(compiled.pollen) %in% non.pol] / rowSums(compiled.pollen[,!colnames(compiled.pollen) %in% non.pol], na.rm=TRUE)
  
  compiled.pollen <- compiled.pollen[pol.pct$Other < 0.10 & !is.na(pol.pct$Other), ]
  
  save(compiled.pollen, file='data/output/compiled.pollen.RData')
  
  rm(include, non.pol, pol.pct)

}

if('compiled.pollen.RData' %in% list.files('data/output')){
  load('data/output/compiled.pollen.RData')
}
#  Okay, this is the code for the non-analogue analysis:

library(reshape2)
library(ggplot2)
library(gridExtra)
library(neotoma)
library(plyr)
library(rgdal)

load_datasets <- function() {
  #  Getting all the sites from neotoma is time consuming:
  if (!'all_sites.rds' %in% list.files('data/output')) {
    
    can_datasets <- neotoma::get_dataset(datasettype = 'pollen', 
                                ageold = 20000, ageyoung = -100,
                                gpid = "Canada")
    
    us_datasets  <-  neotoma::get_dataset(datasettype = 'pollen', 
                                 ageold = 20000, ageyoung = -100,
                                 gpid = "United States")
    
    all_datasets <- neotoma::bind(can_datasets, us_datasets)
    
    #  Return all pollen sites in neotoma:
    all_sites <- neotoma::get_download(all_datasets)
    
    saveRDS(all_datasets, file = 'data/output/all_datasets.rds')
    saveRDS(all_sites, file = 'data/output/all_sites.rds')
  }
  
  #  Compress the dataset taxonomies to the standard of the small Whitmore taxonomy.
  if (!'compiled_sites.rds' %in% list.files('data/output/')) {
    
    all_sites <- readRDS('data/output/all_sites.rds')
    
    compiled_sites <- compile_taxa(all_sites, 
                                   list.name = 'WhitmoreSmall', 
                                   type = TRUE, cf = TRUE)
    
    # Just check to see what we need to add to the "Other" list.
    other_list <- do.call(rbind, lapply(compiled_sites, 
                                        function(x) { 
                                          subset(x$taxon.list, compressed == "Other")[,c("taxon.name", "compressed")] }))
    write.csv(table(other_list), 'data/output/other_list.csv')
    
    #  Pull in age models from Blois et al.
    blois.models <- list.files('data/input/Neotoma2/')
    dataset.handles <- sapply(compiled_sites, function(x)try(x$dataset$dataset.meta$collection.handle))
    site.handle <- unique(substr(blois.models, 1, regexpr('.', blois.models, fixed = TRUE) - 1))
    
    blois.match <- match(dataset.handles, site.handle)
    
    # A bad hack:
    # load('../stepps-baconizing/data/chronologies.RData')
    
    for (i in 1:length(compiled_sites)) {
      if (!is.na(blois.match[i])) {
        age <- read.csv(paste0('data/input/Neotoma2/', site.handle[blois.match[i]], '.age.model.csv'))
        if (nrow(age) == nrow(compiled_sites[[i]]$sample.meta) & identical(age$depth, compiled_sites[[i]]$sample.meta$depth)) {
          compiled_sites[[i]]$sample.meta$age <- age$best.age
          compiled_sites[[i]]$sample.meta$age.type <- 'Calibrated radiocarbon years BP (Blois)'
        }
      }
      
      # This is tied to the 'a bad hack':
      # if (regexpr("Radio", compiled_sites[[i]]$sample.meta$age.type[1], ignore.case = FALSE) > -1) {
      #   if (nrow(compiled_sites[[i]]$sample.meta) == sum(new.chrons$handle %in% compiled_sites[[i]]$dataset$dataset.meta$collection.handle)) {
      #     compiled_sites[[i]]$sample.meta$age <- new.chrons$age.lin[which(new.chrons$handle == compiled_sites[[i]]$dataset$dataset.meta$collection.handle)]
      #     compiled_sites[[i]]$sample.meta$age.type <- 'Calibrated radiocarbon years BP (Goring)'
      #   }
      # }
    }
    
    saveRDS(compiled_sites, file = 'data/output/compiled_sites.rds')  
  }
  
  #  Make the dataset into one giant table with site name, lat/long, depth and age and then counts:
  if (!('compiled_pollen.rds' %in% list.files('data/output'))) {

    all_sites <- readRDS('data/output/all_sites.rds')
    compiled_sites <- readRDS('data/output/compiled_sites.rds')
    
    compiled_pollen <- compile_downloads(compiled_sites)
    
    include <- !(is.na(compiled_pollen$age) | 
                   is.na(compiled_pollen$depth) | 
                   compiled_pollen$age > 22000 |
                   compiled_pollen$lat < 23 |
                   compiled_pollen$lat > 65 |
                   compiled_pollen$long > -40 |
                   compiled_pollen$long < -100 |
                   compiled_pollen$site.name %in% 'Mangrove Lake' |
                   regexpr('Chesapeake Bay', compiled_pollen$site.name) > -1 |
                   compiled_pollen$date.type %in% "Radiocarbon years BP")
    
    # Currently, excludes 40099 records, includes 11362.
    
    compiled_pollen <- compiled_pollen[include, ]
    compiled_pollen$site.name <- as.character(compiled_pollen$site.name)
    compiled_pollen[is.na(compiled_pollen)] <- 0
    
    compiled_pollen$uIDs <- 1:nrow(compiled_pollen)
    
    non.pol <- c(".id", "site.name", "depth", "age", 
                 "age.old", "age.young", "date.type", "lat", "long", "dataset", 'uIDs')
    
    pol.pct <- compiled_pollen[,!colnames(compiled_pollen) %in% non.pol] / rowSums(compiled_pollen[,!colnames(compiled_pollen) %in% non.pol], na.rm = TRUE)
    
    compiled_pollen <- compiled_pollen[pol.pct$Other < 0.10 & !is.na(pol.pct$Other), ]
    
    saveRDS(compiled_pollen, file = 'data/output/compiled_pollen.rds')

  }
  
}

load_datasets()

all_sites <- readRDS('data/output/all_sites.rds')
compiled_pollen <- readDRS('data/output/compiled_pollen.rds')
compiled_sites <- readRDS('data/output/compiled_sites.rds')
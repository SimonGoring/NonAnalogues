#  Calculate the dissimilarities for all sites in the large compiled_pollen data.frame.
#  We want to calculate several metrics in two directions, forward and backwards,
#  and we ideally want to keep track of where the closest landscape points are.
#  Landscape similarity gives us a sense of how close a site is to an ecosystem that
#  has previously existed on the landscape.  We also look forward to see

library(parallel)
snow::makeCluster(3, "SOCK")

#  If 'Other' accounts for more than 10% of the total pollen sum we're going 
#  to exclude the sample.  This excludes fully a quarter of the sites in the dataset!
#  n = 5441 of 21397

source('R/analogue_function.R')

if ('pollen_frame' %in% list.files('data/output/')) {
  load('data/output/pollen_frame.RData')
}
if (!'pollen_frame' %in% list.files('data/output/')) {
  #  Sets the empty dataframe for use in the ddply statement.  set_frame is declared in 'analogue_function.R'.
  pollen_frame <- set_frame(compiled_pollen)
  
  poll.in.compiled <- colnames(compiled_pollen) %in% c('Other', as.character(pollen.equiv$WhitmoreSmall))
  
  #  We use the percents here, straight up.
  compiled_pollen[,poll.in.compiled] <- compiled_pollen[,poll.in.compiled] / rowSums(compiled_pollen[,poll.in.compiled])
  no.others <- compiled_pollen$Other > 0.20
  
  #  A simple way to stop these samples from being considered in analysis.  If 'Other' is greater than 10% than
  #  we discard the sample.
  
  compiled_pollen$Other[no.others] <- NA
  
  drop.cols <- !colnames(compiled_pollen) %in% c('LARREA', 'TSUGMERT', 'DODECATH', 'TSUGHETE','CHRYSOLEP',
                                   'PROSOPIS', 'ARMERIA', 'CACTACEAE', 'SXFRAGAX', 'SCROPHUL',
                                   'ELAEAGNX', 'ANACARDI', 'MALVACEAE', 'DRYAS', 'CAMPANULACEAE',
                                   'BORAGINACEAE', 'EUPHORB', 'EQUISETU', 'SPHAGNUM', 'CYPERACE',
                                   'POLYPOD', 'PTERIDIUM', 'LYCOPODX')
  
  #  This fills the dataset produced as climate_frame or pollen_frame 
  pollen_fill <- ddply(pollen_frame, .(uniqueID), .parallel = TRUE,
                       .fun = find_analogues,
                       compiled.data = compiled_pollen , drop.cols = drop.cols)
  
  pollen_frame[,colnames(pollen_fill)] <- pollen_fill
  
  saveRDS(pollen_frame, file = 'data/output/pollen_frame.rds')
}

if ('climate_frame' %in% list.files('data/output/')) {
  climate_frame <- readRDS('data/output/climate_frame.rds')
}

if (!'climate_frame' %in% list.files('data/output/')) {
  
  load('data/input/compiled.climate.RData')
  
  #  Sets the empty dataframe for use in the ddply statement.  set_frame is declared in 'analogue_function.R'.
  
  climate_frame <- set_frame(compiled.climate)
  
  #  This fills the dataset produced as climate_frame or pollen_frame 
  climate.fill <- ddply(climate_frame, .(uniqueID),
                        .fun = find_analogues,
                        compiled.data = compiled.climate, drop.cols = NULL,
                        .progress = 'text')
  
  climate_frame[,colnames(climate.fill)] <- climate.fill
  
  saveRDS(climate_frame, file = 'data/output/climate_frame.rds')

}

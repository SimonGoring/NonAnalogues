#  Calculate the dissimilarities for all sites in the large compiled.pollen data.frame.
#  We want to calculate several metrics in two directions, forward and backwards,
#  and we ideally want to keep track of where the closest landscape points are.
#  Landscape similarity gives us a sense of how close a site is to an ecosystem that
#  has previously existed on the landscape.  We also look forward to see

library(snowfall)
sfInit(parallel = TRUE, cpus = 4)

#  If 'Other' accounts for more than 10% of the total pollen sum we're going 
#  to exclude the sample.  This excludes fully a quarter of the sites in the dataset!
#  n = 5441 of 21397

source('R/analogue_function.R')

if('pollen.frame' %in% list.files('data/output/')){
  load('data/output/pollen.frame.RData')
}
if(!'pollen.frame' %in% list.files('data/output/')){
  #  Sets the empty dataframe for use in the ddply statement.  set_frame is declared in 'analogue_function.R'.
  pollen.frame <- set_frame(compiled.pollen)
  
  poll.in.compiled <- colnames(compiled.pollen) %in% c('Other', as.character(pollen.equiv$WhitmoreSmall))
  
  #  We use the percents here, straight up.
  compiled.pollen[,poll.in.compiled] <- compiled.pollen[,poll.in.compiled] / rowSums(compiled.pollen[,poll.in.compiled])
  no.others <- compiled.pollen$Other > 0.10
  
  #  A simple way to stop these samples from being considered in analysis.  If 'Other' is greater than 10% than
  #  we discard the sample.
  
  compiled.pollen$Other[no.others] <- NA
  
  drop.cols <- !colnames(compiled.pollen) %in% c('LARREA', 'TSUGMERT', 'DODECATH', 'TSUGHETE','CHRYSOLEP',
                                   'PROSOPIS', 'ARMERIA', 'CACTACEAE', 'SXFRAGAX', 'SCROPHUL',
                                   'ELAEAGNX', 'ANACARDI', 'MALVACEAE', 'DRYAS', 'CAMPANULACEAE',
                                   'BORAGINACEAE', 'EUPHORB', 'EQUISETU', 'SPHAGNUM', 'CYPERACE',
                                   'POLYPOD', 'PTERIDIUM', 'LYCOPODX')
  
  #  This fills the dataset produced as climate.frame or pollen.frame 
  pollen.fill <- ddply(pollen.frame, .(uniqueID), .parallel=TRUE,
                       .fun = find_analogues,
                       compiled.data = compiled.pollen[,drop.cols],
                       .progress = 'text')
  
  pollen.frame[,colnames(pollen.fill)] <- pollen.fill
  
  save(pollen.frame, file='data/output/pollen.frame.RData')
}

if('climate.frame' %in% list.files('data/output/')){
  load('data/output/climate.frame.RData')
}
if(!'climate.frame' %in% list.files('data/output/')){
  
  load('data/input/compiled.climate.RData')
  
  #  Sets the empty dataframe for use in the ddply statement.  set_frame is declared in 'analogue_function.R'.
  
  climate.frame <- set_frame(compiled.climate)
  
  #  This fills the dataset produced as climate.frame or pollen.frame 
  climate.fill <- ddply(climate.frame, .(uniqueID),
                        .fun = find_analogues,
                        compiled.data = compiled.climate,
                        .progress = 'text')
  
  climate.frame[,colnames(climate.fill)] <- climate.fill
  
  save(climate.frame, file='data/output/climate.frame.RData')

}

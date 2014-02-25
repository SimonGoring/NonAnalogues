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

pol.types <- c('Other', unique(as.character(pollen.equiv$WhitmoreSmall)))
pol.types <- colnames(compiled.pollen)[colnames(compiled.pollen)%in%pol.types[!is.na(pol.types)]]

cp.pct <- compiled.pollen[,pol.types]/rowSums(compiled.pollen[,pol.types])

no.others <- cp.pct$Other > 0.10

#  There are a set of parameters we're interested in:
#  Minimum distances to the past & future for the landscape
#  Spatial locations & time difference of the same.
#  Minimum distances to the past & future for the site 
#  Time to sample.

compiled.pollen$uID <- 1:nrow(compiled.pollen)

land.frame <- data.frame(site        = rep(compiled.pollen$sitename,2),
                         dataset     = rep(compiled.pollen$dataset, 2),
                         age         = rep(compiled.pollen$age, 2),
                         index       = rep(1:nrow(compiled.pollen), 2),
                         land.min    = rep(NA, nrow(compiled.pollen) * 2),
                         land.pt     = rep(NA, nrow(compiled.pollen) * 2),
                         sample.size = rep(NA, nrow(compiled.pollen) * 2),
                         delta.age   = rep(NA, nrow(compiled.pollen)*2),
                         mean.delt   = rep(NA, nrow(compiled.pollen)*2),
                         direction   = rep(c('past', 'futu'), nrow(compiled.pollen)))

self.frame <- data.frame(site      = rep(compiled.pollen$sitename,2),
                         dataset   = rep(compiled.pollen$dataset, 2),
                         age       = rep(compiled.pollen$age, 2),
                         index     = rep(1:nrow(compiled.pollen), 2),
                         self.min  = rep(NA, nrow(compiled.pollen)*2),
                         self.size = rep(NA, nrow(compiled.pollen)*2),
                         delta.age = rep(NA, nrow(compiled.pollen)*2),
                         mean.delt = rep(NA, nrow(compiled.pollen)*2),
                         direction = rep(c('past', 'futu'), nrow(compiled.pollen)))

#  I'm breaking this into two so that we split the 'self' analysis away from the
#  landscape analysis.  I keep it in a for loop because it's really long and
#  the lapply functions require a lot of memory to keep everything together before
#  dumping it out.

for(i in 1:nrow(self.frame)){
  right.site <- compiled.pollen$sitename == self.frame$site[i]
  site.ages <-  compiled.pollen$age[right.site]
  mult <- ifelse(self.frame$direction[i] == 'past',  1, -1)
  
  right.age <- findInterval(compiled.pollen$age,
                            sort(c(self.frame$age[i] + 250 * mult,
                                   self.frame$age[i] + 750 * mult))) == 1

  if(sum(right.age & right.site) > 1 & rep(no.others, 2)[i] == FALSE){
    arrow <- cp.pct[self.frame$index[i],]
    arrow.mat <- as.matrix(arrow)
    
    calib.samples <- cp.pct[right.age & right.site,]
    calib.minus <- apply(calib.samples, 1, function(x) (arrow.mat - x)^2)
    calib.vals <- sqrt(colSums(calib.minus, na.rm=TRUE))
    
    self.frame$self.min[i]  <- min(calib.vals)
    self.frame$delta.age[i] <- compiled.pollen$age[right.age & right.site][which.min(calib.vals)] - compiled.pollen$age[i]
    self.frame$self.size[i] <- length(calib.vals)
    self.frame$mean.delt[i] <- mean(compiled.pollen$age[right.age & right.site] - compiled.pollen$age[i], na.rm=TRUE)
  }
}

save(self.frame, file = 'data/self.frame.RData')
}
if(exists())
#  Now this is for the landscape metric.  I expect it to be slower:

for(i in 1:nrow(land.frame)){
  
    #  For each sample in the dataset we need to find it, and then check if it
    #  has any samples that are between 250 and 750 years older than it.
    right.site <- compiled.pollen$sitename == rep.frame$site[i]
    site.ages <-  compiled.pollen$age[right.site]
    
    mult <- ifelse(land.frame$direction[i] == 'past',  1, -1)
    
    right.age <- findInterval(compiled.pollen$age,
                              sort(c(land.frame$age[i] + 250 * mult,
                                     land.frame$age[i] + 750 * mult))) == 1
    
    if(any((right.age & right.site) & sum(right.age) > 5)){
      
      arrow <- cp.pct[i,]
      arrow.mat <- as.matrix(arrow)
      
      calib.samples <- cp.pct[right.age & (!right.site), ]
      
      calib.sites <- compiled.pollen[right.age & (!right.site), 1]
      
      calib.minus <- apply(calib.samples, 1, function(x) (arrow.mat - x)^2)
      
      calib.vals <- sqrt(colSums(calib.minus, na.rm=TRUE))
      
      landscape.samples <- cp.pct[right.age & (!right.site), ]
      
      landscape.minus <- apply(landscape.samples, 1, function(x) (arrow.mat - x)^2)
      landscape.vals  <- sqrt(colSums(landscape.minus, na.rm=TRUE))
      
      land.frame$land.pt[i] <- names(which.min(landscape.vals))
      land.frame$sample.size[i] <- length(landscape.vals)
      land.frame$land.min[i] <- min(landscape.vals)
      land.frame$delta.age[i] <- compiled.pollen[land.frame$land.pt[i], ]$age - compiled.pollen$age[i]
      land.frame$mean.delt[i] <- mean(compiled.pollen[names(landscape.vals), ]$age - compiled.pollen$age[i])
    }
      
    #  Now we know that the sample has something to compare to (that is 
    #  between 250 and 750 years older), we can create a vector for the sample.
    #  We exclude 'Other', because it's super big some times.
    
    cat(paste(as.character(rep.frame[i, 1]), 
                      rep.frame[i,2], 
                      round(i/nrow(rep.frame), 4)*100, sep=', '), '\n')
  }
}

save(self.frame, file='data/self.frame.RData')
save(land.frame, file='data/land.frame.RData')


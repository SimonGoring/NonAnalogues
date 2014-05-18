load('data/input/compiled.climate.RData')

#  To standardize climate variables we have to log summer precip and winter precip 
#  (which is still not normally distributed), and then scale them all so they're similar.

compiled.climate$psum <- scale(log(compiled.climate$psum))
compiled.climate$pwin <- scale(log(compiled.climate$pwin))
compiled.climate$tsum <- scale(compiled.climate$tsum)
compiled.climate$twin <- scale(compiled.climate$twin)

compiled.climate$dataset <- compiled.pollen$dataset

#  This is effectively the same implementation that we use for the pollen data.  Maybe it's worth 
#  investing some time in 'functionalizing' the implentation.

#  This is the reference worth checking out for the distance metric: http://journals.ametsoc.org/doi/abs/10.1175/JAMC-D-12-0170.1

library(snowfall)
sfInit(parallel = TRUE, cpus = 4)

#  There are a set of parameters we're interested in:
#  Minimum distances to the past & future for the landscape
#  Spatial locations & time difference of the same.
#  Minimum distances to the past & future for the site 
#  Time to sample.

compiled.climate$uID <- 1:nrow(compiled.climate)

#  I'm breaking this into two so that we split the 'self' analysis away from the
#  landscape analysis.  I keep it in a for loop because it's really long and
#  the lapply functions require a lot of memory to keep everything together before
#  dumping it out.

if('self.frame.climate.RData' %in% list.files('data/output')){
  load('data/output/self.frame.climate.RData')
}
else {
  self.frame.climate <- data.frame(site      = rep(compiled.climate$sitename,2),
                           dataset   = rep(compiled.climate$dataset, 2),
                           age       = rep(compiled.climate$age, 2),
                           index     = rep(1:nrow(compiled.climate), 2),
                           self.min  = rep(NA, nrow(compiled.climate)*2),
                           self.size = rep(NA, nrow(compiled.climate)*2),
                           delta.age = rep(NA, nrow(compiled.climate)*2),
                           mean.delt = rep(NA, nrow(compiled.climate)*2),
                           direction = rep(c('past', 'futu'), nrow(compiled.climate)))
  
  good.clim <- !apply(is.na(compiled.climate[,6:9]), 1, any)
  
  for(i in 1:nrow(self.frame.climate)){
    
    if(good.clim[self.frame.climate$index[i]]){
      right.site <- compiled.climate$sitename == self.frame.climate$site[i] & good.clim
        
      site.ages <-  compiled.climate$age[right.site]
      mult <- ifelse(self.frame.climate$direction[i] == 'past',  1, -1)
      
      right.age <- findInterval(compiled.climate$age,
                                sort(c(self.frame.climate$age[i] + 250 * mult,
                                       self.frame.climate$age[i] + 750 * mult))) == 1
      
      if(sum(right.age & right.site) > 1 & rep(no.others, 2)[i] == FALSE){
        arrow <- compiled.climate[self.frame.climate$index[i],6:9]
        arrow.mat <- as.matrix(arrow)
        
        calib.samples <- compiled.climate[right.age & right.site,6:9]
        calib.minus <- apply(calib.samples, 1, function(x) (arrow.mat - x)^2)
        calib.vals <- sqrt(colSums(calib.minus, na.rm=TRUE))
        
        self.frame.climate$self.min[i]  <- min(calib.vals)
        self.frame.climate$delta.age[i] <- compiled.climate$age[right.age & right.site][which.min(calib.vals)] - compiled.climate$age[i]
        self.frame.climate$self.size[i] <- length(calib.vals)
        self.frame.climate$mean.delt[i] <- mean(compiled.climate$age[right.age & right.site] - compiled.climate$age[i], na.rm=TRUE)
      
      }
    }
    
    if(i%%400 == 0)cat('Run',i,'keep waiting. . . \n')
  }
  
  save(self.frame.climate, file = 'data/output/self.frame.climate.RData')
}

#  Now this is for the landscape metric.  I expect it to be slower:
if('land.frame.climate.RData' %in% list.files('data/output')){
  load('data/output/land.frame.limate.RData')
}
else {
  for(i in 1:nrow(land.frame.climate)){
    
    #  The big analytic frame.
    land.frame.climate <- data.frame(site        = rep(compiled.climate$sitename,2),
                             dataset     = rep(compiled.climate$dataset, 2),
                             age         = rep(compiled.climate$age, 2),
                             index       = rep(1:nrow(compiled.climate), 2),
                             land.min    = rep(NA, nrow(compiled.climate) * 2),
                             land.pt     = rep(NA, nrow(compiled.climate) * 2),
                             sample.size = rep(NA, nrow(compiled.climate) * 2),
                             delta.age   = rep(NA, nrow(compiled.climate)*2),
                             mean.delt   = rep(NA, nrow(compiled.climate)*2),
                             direction   = rep(c('past', 'futu'), nrow(compiled.climate)))
    
    #  For each sample in the dataset we need to find it, and then check if it
    #  has any samples that are between 250 and 750 years older than it.
    right.site <- compiled.climate$sitename == land.frame.climate$site[i]
    site.ages <-  compiled.climate$age[right.site]
    
    mult <- ifelse(land.frame.climate$direction[i] == 'past',  1, -1)
    
    right.age <- findInterval(compiled.climate$age,
                              sort(c(land.frame.climate$age[i] + 250 * mult,
                                     land.frame.climate$age[i] + 750 * mult))) == 1
    
    if(any((right.age & right.site) & sum(right.age) > 5)){
      
      arrow <- compiled.climate[land.frame.climate$index[i],]
      arrow.mat <- as.matrix(arrow)
      
      calib.samples <- compiled.climate[right.age & (!right.site), ]
      
      calib.sites <- compiled.climate[right.age & (!right.site), 1]
      
      calib.minus <- apply(calib.samples, 1, function(x) (arrow.mat - x)^2)
      
      calib.vals <- sqrt(colSums(calib.minus, na.rm=TRUE))
      
      landscape.samples <- compiled.climate[right.age & (!right.site), ]
      
      landscape.minus <- apply(landscape.samples, 1, function(x) (arrow.mat - x)^2)
      landscape.vals  <- sqrt(colSums(landscape.minus, na.rm=TRUE))
      
      land.frame.climate$land.pt[i] <- names(which.min(landscape.vals))
      land.frame.climate$sample.size[i] <- length(landscape.vals)
      land.frame.climate$land.min[i] <- min(landscape.vals)
      land.frame.climate$delta.age[i] <- compiled.climate[land.frame.climate$land.pt[i], ]$age - compiled.climate$age[i]
      land.frame.climate$mean.delt[i] <- mean(compiled.climate[names(landscape.vals), ]$age - compiled.climate$age[i])
    }
    
    #  Now we know that the sample has something to compare to (that is 
    #  between 250 and 750 years older), we can create a vector for the sample.
    #  We exclude 'Other', because it's super big some times.
    
    cat(paste(as.character(land.frame.climate[i, 1]), 
              land.frame.climate[i,2], 
              round(i/nrow(land.frame.climate), 4)*100, sep=', '), '\n')
  }
}

save(land.frame.climate, file='data/land.frame.climate.RData')
}


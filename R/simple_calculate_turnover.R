#  This file is based on the calculate_turnover file, but is structured differently so that
#  we see every sample that sits within the window.  This means a moderately larger data.frame for
#  the self samples, and a significantly larger data.fframe for the landscape samples.
#  However, this is simply to understand what the data actually look like, so we're limiting our
#  analysis to the period from 9500 - 10500 14C years and from 7500 - 8500 14C years.
#  Periods of high and low turnover respectively.

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

#  I'm breaking this into two so that we split the 'self' analysis away from the
#  landscape analysis.  I keep it in a for loop because it's really long and
#  the lapply functions require a lot of memory to keep everything together before
#  dumping it out.

load('data/self.frame.RData')
load('data/land.frame.RData')

self.size <- sum(self.frame$self.size[findInterval(self.frame$age, c(7500, 8500, 9500, 10500)) %in% c(2, 4)], na.rm=TRUE)
land.size <- sum(land.frame$sample.size[findInterval(land.frame$age, c(7500, 8500, 9500, 10500)) %in% c(2, 4)], na.rm=TRUE)

#  This isn't the best way to do it yet.
self.long <- data.frame(uID  =rep(NA, self.size), 
                        aID  =rep(NA, self.size), 
                        diss =rep(NA, self.size), 
                        direction=rep(NA, self.size))

counter <- 1

for(i in 1:nrow(self.frame)){
  if(findInterval(self.frame$age[i], c(7500, 8500, 9500, 10500)) %in% c(2, 4)){
    
    right.site <- compiled.pollen$sitename == self.frame$site[i]
    site.ages <-  compiled.pollen$age[right.site]
    sample.age <- (compiled.pollen$age == self.frame$age[i])

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
      
      test <- data.frame(uID  = compiled.pollen$uID[floor((i+1)/2)],
                         aID  = compiled.pollen$uID[right.site & right.age],
                         diss = calib.vals,
                         direction = as.character(self.frame$direction[i]),
                         stringsAsFactors = FALSE)
      
      self.long[counter:(counter + length(calib.vals) - 1),] <- test
      counter <- counter + length(calib.vals)
    }
  }
}

save(self.long, file = 'data/self.long.RData')

#  Now this is for the landscape metric.  I expect it to be slower:
load('data/land.frame.RData')

land.long <- data.frame(uID  =rep(NA, land.size), 
                        aID  =rep(NA, land.size), 
                        diss =rep(NA, land.size), 
                        direction=rep(NA, land.size))
counter <- 1

for(i in i:nrow(land.frame)){
  if(findInterval(land.frame$age[i], c(7500, 8500, 9500, 10500)) %in% c(2, 4)){
    
    right.site <- compiled.pollen$sitename == land.frame$site[i]
    site.ages <-  compiled.pollen$age[right.site]
    sample.age <- (compiled.pollen$age == land.frame$age[i])
    
    mult <- ifelse(land.frame$direction[i] == 'past',  1, -1)
    
    right.age <- findInterval(compiled.pollen$age,
                              sort(c(land.frame$age[i] + 250 * mult,
                                     land.frame$age[i] + 750 * mult))) == 1
    
    if(sum(right.age & right.site) > 1 & rep(no.others, 2)[i] == FALSE){
      arrow <- cp.pct[land.frame$index[i],]
      arrow.mat <- as.matrix(arrow)
      
      calib.samples <- cp.pct[right.age & (!right.site),]
      calib.minus <- apply(calib.samples, 1, function(x) (arrow.mat - x)^2)
      calib.vals <- sqrt(colSums(calib.minus, na.rm=TRUE))
      
      test <- data.frame(uID  = compiled.pollen$uID[floor((i+1)/2)],
                         aID  = compiled.pollen$uID[(!right.site) & right.age],
                         diss = calib.vals,
                         direction = as.character(self.frame$direction[i]),
                         stringsAsFactors = FALSE)
      
      land.long[counter:(counter + length(calib.vals) - 1),] <- test
      counter <- counter + length(calib.vals)
    }
  }
  cat(i, '\n')
}

save(land.long, file='data/land.long.RData')

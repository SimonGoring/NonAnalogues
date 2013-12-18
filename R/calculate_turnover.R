#  Calculate the dissimilarities for all sites in the large compiled.pollen data.frame.

#  This could probably be parallelized to speed everything up, 
library(snowfall)
sfInit(parallel = TRUE, cpus = 4)

rep.frame <- data.frame(site = compiled.pollen$sitename,
                        age = compiled.pollen$age,
                        matrix(nrow=nrow(compiled.pollen), ncol=100))

for(i in i:nrow(rep.frame)){
  
  if(any(is.na(rep.frame[i, 3:102]))){
    #  For each sample in the dataset we need to find it, and then check if it
    #  has any samples that are between 250 and 750 years older than it.
    right.site <- compiled.pollen$sitename == rep.frame$site[i]
    site.ages <-  compiled.pollen$age[right.site]
    
    right.age <- ((compiled.pollen$age > (rep.frame$age[i] + 250)) & 
                    (compiled.pollen$age < (rep.frame$age[i] + 750)))
    
    if(any(right.age & right.site)){
      
      #  Now we know that the sample has something to compare to (that is 
      #  between 250 and 750 years older), we can create a vector for the sample.
      #  We exclude 'Other', because it's super big some times.
      
      arrow <- compiled.pollen[i, 7:ncol(compiled.pollen)]
      arrow <- arrow / sum(arrow)
      arrow.mat <- as.matrix(arrow)
      
      calib.samples <- compiled.pollen[-i, ][right.age[-i],]
      calib.sites <- calib.samples[,1]
      
      calib.samples <- calib.samples[,7:ncol(calib.samples)] / rowSums(calib.samples[,7:ncol(calib.samples)])
      
      dist.minus <- apply(calib.samples, 1, function(x) (arrow.mat - x)^2)
      dist.vals <- sqrt(colSums(dist.minus, na.rm=TRUE))
      
      sfExport("calib.sites")
      sfExport("calib.samples")
      sfExport('dist.vals')
      
      min.dist <- function(x){
        resampled <- sample(nrow(calib.samples), replace=TRUE)
        dist.test <- dist.vals[resampled][!duplicated(calib.sites[resampled])]
        min(dist.test)
      }
      
      rep.frame[i,3:102] <- unlist(sfLapply(1:100, min.dist))
      
      
      cat(paste(as.character(rep.frame[i, 1]), 
                        rep.frame[i,2], 
                        round(i/nrow(rep.frame), 4)*100, sep=', '), '\n')
    }
  }
}

#  Within site dissimilarity:
self.frame <- data.frame(site = compiled.pollen$sitename,
                         age = compiled.pollen$age,
                         matrix(nrow=nrow(compiled.pollen), ncol=100))
 

for(i in i:nrow(self.frame)){
  
  if(any(is.na(self.frame[i, 3:102]))){
    #  For each sample in the dataset we need to find it, and then check if it
    #  has any samples that are between 250 and 750 years older than it.
    right.site <- compiled.pollen$sitename == self.frame$site[i]
    site.ages <-  compiled.pollen$age[right.site]
    
    right.age <- ((compiled.pollen$age > (self.frame$age[i] + 250)) & 
                    (compiled.pollen$age < (self.frame$age[i] + 750)))
    
    if(any(right.age & right.site)){
      pol.set <- rbind(compiled.pollen[i, 7:ncol(compiled.pollen)],
                       compiled.pollen[right.age & right.site, 
                                       7:ncol(compiled.pollen)])
      
      pol.set <- pol.set / rowSums(pol.set, na.rm=TRUE)
      
      distances <- as.matrix(dist(pol.set))[-1,1]
      
      self.frame[i,3:102] <- sample(distances, 100, replace = TRUE)
      
      
      cat(paste(as.character(self.frame[i, 1]), 
                self.frame[i,2], 
                round(i/nrow(self.frame), 4)*100, sep=', '), '\n')
    }
  }
}

save(rep.frame, file='data/rep.frame.RData')
save(self.frame, file='data/self.frame.RData')
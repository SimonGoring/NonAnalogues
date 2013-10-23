#  Calculate the dissimilarities for all sites in the large compiled.pollen data.frame.

library(snowfall)
sfInit(parallel = TRUE, cpus = 4)

#  If 'Other' accounts for more than 10% of the total pollen sum we're going 
#  to exclude the sample.  This excludes fully a quarter of the sites in the dataset!
#  n = 5441 of 21397

data(pollen.equiv)

pol.types <- c('Other', unique(as.character(pollen.equiv$WhitmoreSmall)))
pol.types <- colnames(compiled.pollen)[colnames(compiled.pollen)%in%pol.types[!is.na(pol.types)]]

cp.pct <- compiled.pollen[,pol.types]/rowSums(compiled.pollen[,pol.types])
compiled.pollen <- compiled.pollen[cp.pct$Other < 0.10, ]
cp.pct <- round(cp.pct[cp.pct$Other < 0.10, -1], 4)

rep.frame <- data.frame(site = compiled.pollen$sitename,
                        dataset = compiled.pollen$dataset,
                        age = compiled.pollen$age,
                        matrix(nrow=nrow(compiled.pollen), ncol=100))

for(i in 1:nrow(rep.frame)){
  
  if(any(is.na(rep.frame[i, 4:103]))){
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
      
      arrow <- cp.pct[i,]
      arrow.mat <- as.matrix(arrow)
      
      calib.samples <- cp.pct[-i, ][right.age[-i],]
      calib.sites <- compiled.pollen[-i, ][right.age[-i],][,1]
      
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
      
      rep.frame[i,4:103] <- unlist(sfLapply(1:100, min.dist))
      
      cat(paste(as.character(rep.frame[i, 1]), 
                        rep.frame[i,2], 
                        round(i/nrow(rep.frame), 4)*100, sep=', '), '\n')
    }
  }
}

save(rep.frame, file='data/rep.frame.RData')
#  Calculate the dissimilarities for all sites in the large compiled.pollen data.frame.

rep.frame <- data.frame(site = compiled.pollen$sitename,
                        age = compiled.pollen$age,
                        matrix(nrow=nrow(compiled.pollen), ncol=100))

for(i in 1:nrow(rep.frame)){
  
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
      
      for(j in 1:100){
        
        resampled <- sample(nrow(calib.samples), replace=TRUE)
        
        dist.test <- dist.vals[resampled][!duplicated(calib.sites[resampled])]
        
        rep.frame[i, j+2] <- min(dist.test)
      }
      hist(as.numeric(rep.frame[i, 3:102]), 
           main = paste(as.character(rep.frame[i, 1]), 
                        rep.frame[i,2], 
                        round(i/nrow(rep.frame), 4)*100, sep=', '))
    }
  }
}

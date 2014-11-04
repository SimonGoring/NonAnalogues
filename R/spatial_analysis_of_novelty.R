#  Analyzing spatial patterns:

unique.sites <- compiled.pollen[!duplicated(compiled.pollen$sitename), ]

full.data <- data.frame(full.data,
                        long = unique.sites$long[match(full.data$site, unique.sites$site)],
                        lat = unique.sites$lat[match(full.data$site, unique.sites$site)])

#  Within each time bin, see if the distribution of sites (latitudinally?) is significantly
#  different from the undelying distribution:


return.diff.p <- function(j){
  classes <- names(table(full.data$quad))
  pollen.p <- matrix(nrow = 150, ncol = length(classes))
  pollen.diff <- matrix(nrow = 150, ncol = length(classes))

  for(i in 1:150){
    for(k in classes){
      
      age.range <- findInterval(full.data$age, c(i*100, i*100 + 500)) == 1
      
      sample.data <- subset(full.data, quad == k & value == j & age.range)$lat
      null.data   <- sample(subset(full.data, value == j & age.range)$lat, length(sample.data))
      
      aa <- try(t.test(sample.data, null.data))
      
      if(!class(aa) == 'try-error'){
        pollen.p[i, which(classes == k)] <- aa$p.value
        pollen.diff[i, which(classes == k)] <- diff(aa$estimate)
      }
      
      #  a negative value here means that the sampled values are higher than the default.
    }
  }
  list(pollen.p, pollen.diff)
}

poll.diff <- return.diff.p('Pollen')
clim.diff <- return.diff.p('Climate')

#  This is pretty cool:
#  1.  Veg novelty (in latitude) is not significantly different from the rest of the 
#      samples for most of the time period, _except_ at around 5kyr, when novelty is
#      strongest at sites with a mean ~ 3-4 degrees south from the rest of the samples.
#  2.  Climate novelty is significant at multiple periods, around 10000 - 11kyr, around
#      8kyr, in the last 2.5kyr and briefly around 4kyr.  In general these are all south
#      of the main pool of points, and get more southern as time goes on.
#
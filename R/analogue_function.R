
set_frame <- function(x){
  data.frame(site        = rep(x$site.name, 4),
             dataset     = rep(x$site.name, 4),
             age         = rep(x$age, 4),
             index       = rep(1:nrow(x), 4),
             self        = rep(c(TRUE, FALSE), each = nrow(x)*2),
             min         = rep(NA, nrow(x) * 4),
             min.pt      = rep(NA, nrow(x) * 4),
             sample.size = rep(NA, nrow(x) * 4),
             delta.age   = rep(NA, nrow(x)*4),
             mean.delt   = rep(NA, nrow(x)*4),
             direction   = rep(rep(c('past', 'futu'), nrow(x)), 2),
             uniqueID    = 1:(nrow(x)*4),
             stringsAsFactors = FALSE)
}


find_analogues <- function(x, compiled.data, drop.cols, plot.out = FALSE){
  #  To parallelize we need to pass in the rows of 'output.frame' one by one.
  
  #  For each sample in the dataset:
  #  1. Check that it has no NA values
  #  2. Make sure it has samples within 250 - 750 years in the right direction.
  #  3. Calculate the dissimilarity either for the self or the landscape.
  #  
  #  has any samples that are between 250 and 750 years older than it.
  
  right.site <- compiled.data$site.name == x$site
  site.ages <-  compiled.data$age[right.site]

  mult <- ifelse(x$direction == 'past',  1, -1)
  
  right.age <- findInterval(compiled.data$age,
                            sort(c(x$age + 250 * mult,
                                   x$age + 750 * mult))) == 1
  
  #  The rule is that the sample must have appeared once (or appears once in the future), and it doesn't
  #  have an NAs.
  
  good.samp <- rowSums(is.na(compiled.data)) == 0 &
    sum(right.site & right.age, na.rm = TRUE) > 0
  
  threshold <- c(5, 1)[x$self + 1]
  
  if (sum(right.age & !xor(right.site, x$self) & good.samp) > threshold) {
    
    drop.cols <- !colnames(compiled.data) %in% c('site.name', 'depth', 'age', 'lat', 'long', 
                                                 'dataset', 'uIDs', 'date.type',
                                                 '.id', 'age.old', 'age.young', drop.cols)
    
    #  This is the assemblage/climate we're interested in.
    arrow <- as.matrix(compiled.data[x$index, drop.cols])
    uIDs  <- compiled.data$uID[right.age & !xor(right.site, x$self)]
    
    #  These are all the samples we're comparing it to.
    calib.samples <- compiled.data[right.age & !xor(right.site, x$self) & good.samp, ]
    
    calib.minus <- apply(calib.samples[, drop.cols], 1, function(x) (arrow - x) ^ 2)
    
    calib.vals <- sqrt(colSums(calib.minus, na.rm = TRUE))
    
    min.pt     <- uIDs[which.min(calib.vals)]
    sample.size <- sum(right.age & !xor(right.site, x$self))
    min    <- min(calib.vals)
    delta.age <- calib.samples$age[which.min(calib.vals)] - x$age
    mean.delt <- mean(calib.samples$age - x$age)
    
    if (plot.out) {
      filename <- paste0('data/output/New folder/', x$site, x$age, x$self, x$direction, '.png')
      
      if (!filename %in% list.files(recursive = TRUE)) {
        model.data <- rbind(arrow, calib.samples[,drop.cols])
        
        model.data <- model.data[,colSums(model.data) > 0]
        
        require(vegan)
        
        aa <- (metaMDS(sqrt(model.data)))
        aa.points <- as.data.frame(aa$points)
        aa.points$site <- c('red', rep('black', nrow(aa$points) - 1))
        
        aa.spec <- as.data.frame(aa$species)
        aa.spec$label <- tolower(rownames(aa.spec))
        
        plotit <- ggplot() +
          geom_point(data = aa.points, aes(x = MDS1, y = MDS2, color = site), size = 5) + 
          geom_text(data = aa.spec, aes(x = MDS1, y = MDS2, label = label), size = 3) +
          theme_bw() +
          xlim(range(c(aa.points$MDS1, aa.spec$MDS1))) +
          ylim(range(c(aa.points$MDS2, aa.spec$MDS2)))
        
        filename <- paste0('data/output/New folder/', x$site, x$age, x$self, x$direction, '.png')
        
        try(ggsave(plot = plotit, filename = filename))
      }
    }
    
  }
  else{
    min.pt     <- NA
    sample.size <- NA
    min    <- NA
    delta.age <- NA
    mean.delt <- NA
  }
  
  data.frame(min.pt, min, sample.size, delta.age, mean.delt, 
             stringsAsFactors = FALSE)
}

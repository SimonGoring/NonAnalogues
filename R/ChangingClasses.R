#  To rotate and set outliers for the pollen data:

plot.set <- function(x, direct, val, res, time){
  
  full_set <- na.omit(subset(x, subset = direction == direct & value == val))
  
  kernel <- kde2d(full_set$self[!is.nan(full_set$self)], full_set$land[!is.nan(full_set$land)], n = res)
  
  # This is to test whether the sample quantile is within one of the quadrats 
  # (eliminates the cardinal axes)
  full_set$quant <- kernel$z[findInterval(full_set$self, kernel$x) + 
    (findInterval(full_set$land, kernel$y) - 1) * res]
  
  full_set$quant <- full_set$quant < quantile(full_set$quant, 0.4)

  
  ranges <- rbind(quantile(full_set$self, c(0.4, 0.6)),
                  quantile(full_set$land, c(0.4, 0.6)))
  
  full_set$quad <- NA
  
  full_set$quad[full_set$self < ranges[1,1] & full_set$land < ranges[2,1] & full_set$quant] <- 'Persistence'
  full_set$quad[full_set$self < ranges[1,1] & full_set$land > ranges[2,2] & full_set$quant] <- 'Refugium'
  full_set$quad[full_set$self > ranges[2,2] & full_set$land > ranges[2,2] & full_set$quant] <- 'Novelty'
  full_set$quad[full_set$self > ranges[2,2] & full_set$land < ranges[2,1] & full_set$quant] <- 'Migration'
  full_set$quad[is.na(full_set$quad) & !full_set$quant] <- 'Mid-Quantile'
  
  full_set$age.bin <- round(full_set$age / time, 0) * time
  
  by.quad <- subset(dcast(full_set, formula= age.bin ~ quad), age.bin < 15000)
  by.quad.pct <- by.quad
  by.quad.pct[,-1] <- by.quad[,-1] / rowSums(by.quad[,-1])
  by.quad.melt <- melt(by.quad.pct,id.vars = 'age.bin')
  
  by.quad.melt <- subset(by.quad.melt, !variable == 'NA')
  
  out.plot <- ggplot(by.quad.melt, aes(x = age.bin, y = value, color = variable)) + geom_line(size = 2) +
    theme_bw() +
    xlab('Calibrated Years Before Present') +
    ylab(paste0(val, ' Dissimilarity')) +
    scale_x_continuous(expand = c(0,0), limits = c(0, 15000)) +
    scale_y_sqrt(expand = c(0,0)) +
    theme(axis.title.x = element_text(family = 'serif', 
                                      face = 'bold.italic', size = 18),
          axis.title.y = element_text(family = 'serif', 
                                      face = 'bold.italic', size = 18))
  
  list(data.table = by.quad, plot = out.plot, full_set = full_set)

}

pol.data <- plot.set(na.omit(full.plot), 'past', 'Pollen', res = 500, time = 100)

clim.data <- plot.set(full.plot, 'past', 'Climate', res = 500, time = 100)

full.data <- rbind(pol.data[[3]], clim.data[[3]])

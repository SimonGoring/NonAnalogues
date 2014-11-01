#  To rotate and set outliers for the pollen data:

plot.set <- function(x, direct, val, res, time){
  
  full.set <- na.omit(subset(x, subset= direction == direct & value == val))
  
  kernel <- kde2d(full.set$self, full.set$land, n = res)
  
  full.set$quant <- kernel$z[findInterval(full.set$self, kernel$x) + 
    (findInterval(full.set$land, kernel$y)-1) * res]
  full.set$quant <- full.set$quant < quantile(full.set$quant, 0.4)
  #full.set$quant <- TRUE
  
  ranges <- rbind(quantile(full.set$self, c(0.4, 0.6)),
                  quantile(full.set$land, c(0.4, 0.6)))
  
  full.set$quad <- NA
  
  full.set$quad[full.set$self < ranges[1,1] & full.set$land < ranges[2,1] & full.set$quant] <- 'Persistence'
  full.set$quad[full.set$self < ranges[1,1] & full.set$land > ranges[2,2] & full.set$quant] <- 'Refugium'
  full.set$quad[full.set$self > ranges[2,2] & full.set$land > ranges[2,2] & full.set$quant] <- 'Novelty'
  full.set$quad[full.set$self > ranges[2,2] & full.set$land < ranges[2,1] & full.set$quant] <- 'Migration'
  full.set$quad[is.na(full.set$quad) & !full.set$quant] <- 'Mid-Quantile'
  
  full.set$age.bin <- round(full.set$age / time, 0) * time
  
  by.quad <- subset(dcast(full.set, formula= age.bin ~ quad), age.bin < 15000)
  by.quad.pct <- by.quad
  by.quad.pct[,-1] <- by.quad[,-1] / rowSums(by.quad[,-1])
  by.quad.melt <- melt(by.quad.pct,id.vars = 'age.bin')
  
  by.quad.melt <- subset(by.quad.melt, !variable == 'NA')
  
  out.plot <- ggplot(by.quad.melt, aes(x = age.bin, y = value, color = variable)) + geom_line(size = 2) +
    theme_bw() +
    xlab('Calibrated Years Before Present') +
    ylab(paste0(val, ' Dissimilarity')) +
    scale_x_continuous(expand=c(0,0), limits = c(0, 15000)) +
    scale_y_sqrt(expand=c(0,0)) +
    theme(axis.title.x = element_text(family = 'serif', 
                                      face = 'bold.italic', size = 18),
          axis.title.y = element_text(family = 'serif', 
                                      face = 'bold.italic', size = 18))
  
  list(data.table = by.quad, plot = out.plot, full.set = full.set)

}

pol.data <- plot.set(na.omit(full.plot), 'past', 'Pollen', res = 500, time = 100)
clim.data <- plot.set(full.plot, 'past', 'Climate', res = 500, time = 100)

full.data <- rbind(pol.data[[3]], clim.data[[3]])

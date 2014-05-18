#  Building rose plots:
#

rose.p <- function(x){
  #  This function takes a unique uID from the 'land.long' table and turns it into
  #  a circular plot that shows the distance weighted dissimilarity in each of six
  #  azimuths.
  
  azms <- seq(0, 315, length.out = 8)
  
  land.points <- land.long$aID[land.long$uID == x]
  
  locs <- data.frame(d_x = compiled.pollen$long[land.points] - compiled.pollen$long[x],
                     d_y = compiled.pollen$lat[land.points] - compiled.pollen$lat[x])
  
  loc.azm <- atan2(locs$d_x, locs$d_y)

  loc.dis <- sqrt(locs$d_x^2 + locs$d_y^2)
  weighted <- land.long$diss[land.points] / sqrt(loc.dis)
  
  model.tester <- data.frame(azm = loc.azm, 
                             dis = weighted, 
                             dir = land.long$direction[land.points])
  
  cp.mod <- try(gam(dis ~ s(azm, bs = 'cp', by = dir), data = model.tester, family = inverse.gaussian(link = log)))
  
  vals <- data.frame(uID = x,
                     azm = rep(seq(-pi, pi, by = pi/8), 2),
                     dir = rep(c('past', 'futu'), each = 17),
                     age = compiled.pollen$age[x])
  
  if(!class(cp.mod)[1] == 'try-error'){
    vals$dis <- predict(cp.mod, newdata = vals, type = 'response')
  }
  if(class(cp.mod)[1] == 'try-error'){
    vals$dis <- NA
  }
  #ggplot(vals, aes(y = dis, x = azm)) + facet_wrap(~dir) + geom_line()
  
  vals
  
}

#aa <- ldply(unique(land.long$uID), rose.p)
aa <- ldply(inset, rose.p)

aa$azm <- aa$azm * (360 / (2 * pi))

ggplot(aa, aes(x = azm, y = dis)) + facet_wrap(~dir) + geom_line(aes(group = uID, color = age), alpha = 0.2) +scale_y_continuous(limits=c(0, 1))

aa$age_bin <- findInterval(aa$age, seq(1000, 10000, by = 1000))

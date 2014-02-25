#  Requires 'self.frame' to be loaded, along with other code.

#  Test that the distribution of ages within the bins is not resulting in any sort
#  of artifact.
#  This is discussed in the issues: https://github.com/SimonGoring/NonAnalogues/issues/11

#  Number 1.  Is ther bias in the age distributions in sample.ages:
#  Age distribution of the sampled data:

ggplot(self.frame) + 
  geom_histogram(aes(x = abs(delta.age), fill = direction), binwidth=50, position = 'dodge') + 
  scale_x_continuous(expand = c(0,0), limits = c(250, 750)) + 
  scale_y_continuous(expand=c(0,0)) + 
  xlab('Age from Sample (yrs)') + ylab('Kernel Density')

#  We also want to model the underlying data, to see if the trend is reflected in the
#  raw data.
bins <- seq(250, 750, by = 50)

sample.bins <- matrix(ncol = 12, nrow=nrow(compiled.pollen))

for(i in 1:nrow(compiled.pollen)){
  right.site <- compiled.pollen$sitename == compiled.pollen$sitename[i]
  site.ages <-  abs(compiled.pollen$age[right.site] - compiled.pollen$age[i])
  bin.out <- findInterval(site.ages, bins)
  bin.tab <- table(bin.out)
  sample.bins[i, as.numeric(names(bin.tab)) + 1] <- unlist(bin.tab)
}

test.thing <- data.frame(dist = rep(bins[-11], each = nrow(sample.bins)), 
           freq = (as.vector(sample.bins[,2:11])))

freq <- dcast(test.thing, formula=dist ~ ., fun.aggregate=sum, na.rm=TRUE, value.var='freq')
colnames(freq) <- c('dist', 'frequency')

plot(freq, type = 'b')

#  Question Two:
# The age of the minimum sample dissimilarity as a function of the number of samples within a bin.

summary(lm(abs(delta.age) ~ self.size, data = self.frame))

#  Question Three:
# The size of the dissimilarity as a function of age from sample of interest.
summary(lm(self.min ~ abs(delta.age), data = self.frame))
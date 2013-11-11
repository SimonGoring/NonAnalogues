#  This code assumes you've run the embedded code in the paper (use CTRL-ALT-C to execute all
#  code in a chunk).  The purpose is to pull out the 95% dissim values so we can see if there's 
#  a data effect, or if it's actually a real signal.

#  This finds all points with > 95% turnover and outputs them with their citation(!)
no.anas <- rf[rf$diss > ninefive,]

datasets <- unique(no.anas$dataset)

aa <- data.frame(rep(NA, length(datasets)),
                 rep(NA, length(datasets)))

for(i in 1:length(datasets)){
  
  val <- get_publication(datasetid=datasets[i])
  
  out <- ifelse(length(val) == 1,
                NA, 
                levels(val$Citation))
  
  aa[i,] <- data.frame(dataset = datasets[i],
                   cite = out, stringsAsFactors = FALSE)
  
}


###################################
#
fac <- rf$diss > ninefive

good.pol <- rep(NA, nrow(compiled.pollen))
for(i in 1:nrow(compiled.pollen)){
  test <- which(compiled.pollen$sitename %in% rf$site[i] & compiled.pollen$age %in% rf$age[i])
  if(length(test) > 0){
    good.pol[i] <- test
  }
}
 
com.short <- compiled.
  small.pol <- as.matrix(compiled.pollen[!is.na(rep.frame[,4]),8:ncol(compiled.pollen)])

aa <- rda(fac ~ compiled.pollen[!is.na(rep.frame[,4]),8:ncol(compiled.pollen)])
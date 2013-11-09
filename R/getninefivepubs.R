no.anas <- rf[rf$diff > ninefive,]

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

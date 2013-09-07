#  Okay, this is the code for the non-analogue analysis:

all_sites <- get_datasets(datasettype = 'pollen')
data.ids <- sapply(all_sites, function(x)x$DatasetID)

#  Return all XXX sites.
all.downloads <- get_download(data.ids)

compiled.sites <- lapply(all.downloads, function(x) compile_list(x, list.name='WS64'))

save(compiled.sites, file='../data/compiled.sites.Rdata')

for(i in i:length(compiled.sites)){
  x <- compiled.sites[[i]]
  
  if(is.null(x$metadata$site.data$SiteName)) x$metadata$site.data$SiteName <- paste('NoName_ID', i)
  if(is.null(x$sample.meta$depths)) x$sample.meta$depths <- NA
  if(is.null(x$sample.meta$Age)) x$sample.meta$Age <- NA
  
  
  site.info <- data.frame(sitename = x$metadata$site.data$SiteName,
                          depth = x$sample.meta$depths,
                          age = x$sample.meta$Age)
  
  if(i == 1){
    compiled.pollen <- data.frame(site.info, x$counts)
  } 
  
    if(i > 1) {
      aa <- try(merge(compiled.pollen, data.frame(site.info, x$counts), all=TRUE))
      if(length(aa) > 1) compiled.pollen <- aa
    }
  
  #  wHY DO SOME SITES HAVE MORE METADATA THAN COUNTS?
  cat(i, '\n')
}
Non-analogues in the past, reversing the view.
========

This code is part of an ongoing research project to attempt to understand the ecological and climatic associates of non-analogue vegetation.  Traditionally researchers have looked at non-analogue associations with regards to modern pollen assemblages.  This paper uses the `neotoma` package (hosted [here](https://github.com/ropensci/neotoma)) to download records from the [Neotoma Paleoecological Database](http://www.neotomadb.org/) and then to check for the presence of non-analogue pollen assembages between 500 year time periods.  The modern data will be used to establish cut-offs or quantiles for dissimilarity measures, but the real measures will be within samples between time periods.

### Development by
[Simon Goring](http://downwithtime.wordpress.com) - University of Wisconsin-Madison, Department of Geography

### Currently implemented in code:
+ `README` - This readme file.
+ `load_datasets.R` - uses the `neotoma` package `get_download` to return all pollen cores using the Neotoma API.
+ `all_sites_compiled.RData` - all of the pollen sites from Neotoma have been compiled into a single large table using the `load_datasets.R` file.


### Coming soon
+ Figures outlined in RMarkdown
+ Text to accompany figures
+ Code implementation of modern and paleo-dissimilarities.
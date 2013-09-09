No-Analogues in North American Pollen Space
========================================================

Abstract
------------------------

Introduction
------------------------
Our investigation of non-analogues, both in the past and in the future is tied to differences from modern pollen data.  THe concern with a future of no-analogues is tied to our lack of understanding, both in how the process of change will unfold, and in how ecosystem services are provided by these vegetation communities for which we have no analogue.
To assist in this endevour, we examine pollen records from the Neotoma Database, searching through the past, from the late-glacial to the modern to examine in which cases pollen assemblages appear to be non-analogue from the previous time period.

Methods
------------------------
We compile records of pollen from depositional records in the Neotoma Database.  To assess whether pollen assemblages are 'non-analogue' we estimate squared-chord distance from pollen samples to a reference set that includes (1) all samples in the Neotoma Database that are between 250 and 750 calibrated years older than the sample, and (2) includes samples from the reference site.



Pollen data from Neotoma was accessed on Sep 06, 2013 using the `neotoma` pacakge for R (Goring, 2013; `http://www.github.com/ropensci/neotoma`).  The dataset includes 546 sites from across North America (Figure 1a), with 21828 samples younger than 21kyr cal. BP (Figure 1b).  To assess the presence of no-analogues we look for the 95% CI of dissimilarities for all samples within an age-range.  A sample is considered to be no-analogue if the minimum dissimilarity between it and the samples pulled from the earlier sample pool is greater than the 95% CI  for dissimilarity within the pool.

![plot of chunk Figure1Plots](figure/Figure1Plots.png) 

**Figure 1**. *Sample plot locations and bin sizes for each age class*.

Because sample size may affect our ability to calculate the 95% CI we also use the squared-chord dissimilarity estimate reported in Gill et al. (2009) of XXX as a secondary check.  This allows us to detect no-analogues using multiple methods.





Results
-------------------------
The analysis produces a somewhat surprising result.  While dissimilarity is high at the beginning of the Holocene, the most rapid rise in turnover occurs in the modern era, even though the density of sites is higher at this time.  High turnovers are sen at 10kyr, between 6 and 7 kyr and then again in the modern period.  While the no-analogue period of the late-glacial has high dissimilarity in relation to modern time, the actual turnover is not significantly higher than during the Holocene transition.


![plot of chunk dissVsAge](figure/dissVsAge.png) 

**Figure X**. *Turnover through time in the Neotoma database.*

Correlations to stuff?

Discussion
---------------------------
Turnover or analogues?  When we are looking at non-analogues it turns out that it's really the modern.

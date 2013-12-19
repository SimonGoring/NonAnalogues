No-Analogues in North American Pollen Space
========================================================

Abstract
------------------------

Introduction
------------------------
Our investigation of non-analogues, both in the past and in the future is tied to differences from modern pollen data.  THe concern with a future of no-analogues is tied to our lack of understanding, both in how the process of change will unfold, and in how ecosystem services are provided by these vegetation communities for which we have no analogue.

To assist in this endevour, we examine pollen records from the Neotoma Database, searching through the past, from the late-glacial to the modern to examine in which cases pollen assemblages appear to be non-analogue from the previous time period.  The conceptual framework suggests that we were looking at landscape level turnover, not site turnover.  While site-level turnover is a commonly used metric in paleoecological analysis, it is hampered by its sensitivity to stochastic effects.  Large scale changes in vegetation at a signle site might not reflect the kinds of broad scale community change we expect to see under conditions of future climate change.  As such, comparing dissimilarity at a site to changes at a number of sites across the continent provides a better metric of landscape-scale dissimilarity.

**Figure 1**. *Some sort of figure showing the conceptual difference between change at the site vs. change at the landscape.*


Methods
------------------------
We compile records of pollen from depositional records in the Neotoma Database.  To assess whether pollen assemblages are 'non-analogue' we estimate squared-chord distance from pollen samples to a reference set that includes (1) all samples in the Neotoma Database that are between 250 and 750 calibrated years older than the sample, and (2) includes samples from the reference site.




Pollen data from Neotoma was accessed on Dec 18, 2013 using the `neotoma` pacakge for R (Goring, 2013; `http://www.github.com/ropensci/neotoma`).  The dataset includes 560 sites from across eastern North America (east of 100^o W; Figure 1a), with 21397 samples younger than 21kyr cal. BP (Figure 1b).

![plot of chunk Figure1Plots](figure/Figure1Plots.png) 

**Figure 2**. *Sample plot locations and bin sizes for each age class*.

Because sample size may affect our ability to calculate the 95% CI we also use the squared-chord dissimilarity estimate reported in Gill et al. (2009) of XXX as a secondary check.  This allows us to detect no-analogues using multiple methods.

To determine dissimilarity ofver time we estimate dissimilarity from the data using a bootstrap approach for which a sample is compared against a 'landscape' of sites that are between 250 and 750 years older than the sample in question.  For any sample we first test whether a sample fom the site exists between 250 - 750 prior to the sample of interest.  This will prevent anomalously high analogue distances for sites that have never previously been sampled, particularly when they represent new ecoregions.  For each acceptable site we sample one assemblage from each site with samples in the previous 250 - 750 years.  This produces a single sample from each site in the previous time window from which we estimate the minimum suqared chord dissimilarity.  Since some sites have multiple samples in each 500 year time window we re-sample (with replacement) 100 times for each focal site, producing a sample of 100 minimum (squared-chord) dissimilarity values for each pollen assemblage at each site, for which there is a prior sample.





Results
-------------------------
Pollen samples:
Of the 560 pollen sites obtained from Neotoma for this analysis, 560 sites had assemblages that met our criteria.  For these sites there were 18850 unique assemblages spanning the last 21kyr, approximately 90% of the total assemblages for the sites that met our criteria.  Samples excluded from analysis occur throughout the record

The analysis produces a somewhat surprising result.  While dissimilarity is high at the beginning of the Holocene, the most rapid rise in turnover occurs in the modern era, even though the density of sites is higher at this time.  High turnovers are seen at 10kyr, between 6 and 7 kyr and then again in the modern period.  While the no-analogue period of the late-glacial has high dissimilarity in relation to modern time, the actual turnover is not significantly higher than during the Holocene transition.


![plot of chunk dissVsAge](figure/dissVsAge.png) 

**Figure 3**. *Turnover through time in the Neotoma database.*


Discussion
---------------------------
Turnover or analogues?  When we are looking at non-analogues it turns out that it's really the modern.

# Using `full.data`
#
# I want to know how long novelty persists:
# Novelty -> [mid-quantile, persistence, refugium]
# Within each site.
#  For each site:
#  1. Identify each time there's "Novelty"
#  2. Find the length of time until the next "Novelty" or "Migration"

transition_list <- list()

for(i in 1:length(unique(full.data$site))){
  site_name <- unique(full.data$site)[i]
  site_data <- subset(full.data, site == site_name)
  
  novel_time <- subset(full.data, site == site_name & quad == 'Novelty' & value == 'Pollen')
  
  if (nrow(novel_time) > 0) {
    # If there is a novel site, find the next "Novelty" or "Migration"
    next_shift <- subset(full.data, site == site_name & 
                           quad %in% c('Novelty', 'Migration') & 
                           value == 'Pollen')
    transition_list[[i]] <- do.call(rbind.data.frame, 
                                    lapply(1:nrow(novel_time), function(x){
                                        diffs <- novel_time[x, 'age'] - next_shift$age
                                        data.frame(site = novel_time[x,'site'],
                                                   age  = novel_time[x,'age'],
                                                   persistence = min(diffs[diffs > 0]))
                                        }))
  }
}

full_transitions <- do.call(rbind.data.frame, transition_list)
full_transitions$persistence[!is.finite(full_transitions$persistence)] <- full_transitions$age[!is.finite(full_transitions$persistence)]
full_transitions$per_age <- full_transitions$age - full_transitions$persistence

full_transitions$pct_age <- full_transitions$persistence / (full_transitions$age)

plot(full_transitions$age, full_transitions$persistence)

ggplot(subset(full_transitions, persistence > 250 & persistence < (age - 300)), aes(x = age, y = persistence)) + 
  geom_point(alpha = 0.3) +
  geom_smooth() +
  coord_cartesian(xlim = c(0, 15000), expand = FALSE) +
  theme_bw() +
  scale_y_log10() +
  scale_x_continuous(breaks = seq(2000, 14000, by = 2000)) +
  xlab("Calibrated Radiocarbon Years") +
  ylab("Persistence (years)") +
  theme(axis.text  = element_text(family = 'serif', size = 12),
        axis.title = element_text(family = 'serif', size = 18, face = 'bold'),
        strip.text = element_text(family = 'serif', size = 14, face = 'bold'))

  #scale_y_continuous(limits = c(0, 1), expand = c(0,0)) +
  #scale_x_continuous(expand = c(0,0))

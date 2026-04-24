#Script to run functions under various common scenarios.

library(EGprocess)
library(tidyverse)
brood_Igushik <- get_brood(data_Igushik)
goal_Igushik <-
  data.frame(
    yr = c(1984, 2001, 2015),
    lb = c(150000, 150000, 150000),
    ub = c(250000, 300000, 400000)
  )
goal_Igushik_new <-
  data.frame(
    yr = c(1984, 2001, 2015, 2026),
    lb = c(150000, 150000, 150000, 200000),
    ub = c(250000, 300000, 400000, 500000)
  )

# Create list of profiles
post_list <-
  list(
    'Brood years: 1963-2005' = post_Igushik_byr63_05,
    'Brood years: 1963-2017' = post_Igushik_byr63_15
  )
profile_list <- lapply(post_list, get_profile, multiplier = 1e-5)
profile_list80 <- lapply(post_list, get_profile, multiplier = 1e-5, MSY_pct = 80)
lapply(post_list[2], get_profile, multiplier = 1e-5)
get_profile(post_list[[2]])

# test plot_s w and wo a new goal finding
plot_escapement(brood_Igushik,
       goal_Igushik,
       "Igushik River Sockeye Salmon"
)
plot_escapement(brood_Igushik,
       goal_Igushik_new,
       "Igushik River Sockeye Salmon"
) +
  geom_bar(aes(y = S),
           data = data.frame(yr = c(2024, 2025), S = c(692616, 668268)),
           stat = "identity", color = "black", fill = "white", alpha = .1, linewidth = 0.5)

#test plot_SR function
# No goal change, single analysis
plot_SR(post_list[2],
        brood_Igushik,
        goal_dat = goal_Igushik,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
# No goal change, two analyses
plot_SR(post_list,
        brood_Igushik,
        goal_dat = goal_Igushik,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
# No goal change, two analyses, unknown profile
plot_SR(list('Brood years: 1963-2005' = c(lnalpha = 1.5, beta = 0.15, sigma = 0.5),
             'Brood years: 1963-2017' = post_Igushik_byr63_15),
        brood_Igushik,
        goal_dat = goal_Igushik,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
# No goal change, two analyses, unknown SR params
plot_SR(list('Brood years: 1963-2005' = NULL,
             'Brood years: 1963-2017' = c(lnalpha = 1.7, beta = 1.4e-6, sigma = 0.5)),
        brood_Igushik,
        goal_dat = goal_Igushik,
        "Igushik River Sockeye Salmon")
#new finding
plot_SR(post_list[2],
        brood_Igushik,
        goal_dat = goal_Igushik_new,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
plot_SR(post_list,
        brood_Igushik,
        goal_dat = goal_Igushik_new,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
#first finding
plot_SR(post_list[2],
        brood_Igushik,
        goal_dat = goal_Igushik_new[dim(goal_Igushik_new)[1], ],
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
#would be better if this threw an error
plot_SR(post_list,
        brood_Igushik,
        goal_dat = goal_Igushik_new,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)

table_SR(post_list[2], title = "Igushik River Sockeye Salmon", multiplier = 1e-6)

#test plot_ey function
# No goal change, single analysis
plot_ey(post_list[2],
        brood_Igushik,
        goal_dat = goal_Igushik,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
# No goal change, two analyses
plot_ey(post_list,
        brood_Igushik,
        goal_dat = goal_Igushik,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
# No goal change, two analyses, unknown profile
plot_ey(list('Brood years: 1963-2005' = c(lnalpha = 1.5, beta = 0.15, sigma = 0.5),
             'Brood years: 1963-2017' = post_Igushik_byr63_15),
        brood_Igushik,
        goal_dat = goal_Igushik,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
# No goal change, two analyses, unknown SR params
plot_ey(list('Brood years: 1963-2005' = NULL,
             'Brood years: 1963-2017' = c(lnalpha = 1.7, beta = 1.4e-6, sigma = 0.5)),
        brood_Igushik,
        goal_dat = goal_Igushik,
        "Igushik River Sockeye Salmon")
#new finding
plot_ey(post_list[2],
        brood_Igushik,
        goal_dat = goal_Igushik_new,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
plot_ey(post_list,
        brood_Igushik,
        goal_dat = goal_Igushik_new,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
#first finding
plot_ey(post_list[2],
        brood_Igushik,
        goal_dat = goal_Igushik_new[dim(goal_Igushik_new)[1], ],
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)
#would be better if this threw an error
plot_ey(post_list,
        brood_Igushik,
        goal_dat = goal_Igushik_new,
        "Igushik River Sockeye Salmon",
        multiplier = 1e-5)

# no goal change
plot_profile(profile_list[2],
                   goal_Igushik,
                   "Igushik River Sockeye Salmon")
plot_profile(profile_list80[2],
                   goal_Igushik,
                   "Igushik River Sockeye Salmon")
# new finding
plot_profile(profile_list[2],
                   goal_Igushik_new,
                   "Igushik River Sockeye Salmon"
)

plot_profile(profile_list80[2],
                   goal_Igushik_new,
                   "Igushik River Sockeye Salmon"
)

#test plot_profile2
# no goal change
plot_profile(profile_list,
             goal_Igushik,
             "Igushik River Sockeye Salmon")
plot_profile(profile_list80,
             goal_Igushik,
             "Igushik River Sockeye Salmon")
# new finding
plot_profile(profile_list,
             goal_Igushik_new,
             "Igushik River Sockeye Salmon",
             new_finding = TRUE
)

plot_profile(profile_list80,
             goal_Igushik_new,
             "Igushik River Sockeye Salmon",
             new_finding = TRUE
)

# Test EGoutput
# 90% of MSY
output_SR(post_list, brood_Igushik, goal_Igushik, "Igushik River Sockeye Salmon", multiplier = 1e-5)
output_SR(post_list, brood_Igushik, goal_Igushik_new, "Igushik River Sockeye Salmon", new_finding = TRUE, multiplier = 1e-5)
output_SR(post_list[2], brood_Igushik, goal_Igushik, "Igushik River Sockeye Salmon", multiplier = 1e-5)

# 80% & 90% of MSY
output_SR(post_list, brood_Igushik, goal_Igushik, "Igushik River Sockeye Salmon", MSY_pct = 80, multiplier = 1e-5)
output_SR(post_list, brood_Igushik, goal_Igushik_new, "Igushik River Sockeye Salmon", new_finding = TRUE, MSY_pct = 80, multiplier = 1e-5)
output_SR(post_list[2], brood_Igushik, goal_Igushik, "Igushik River Sockeye Salmon", MSY_pct = 80, multiplier = 1e-5)

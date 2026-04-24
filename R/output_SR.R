#' @title Escapement goal process output wrapper
#'
#' @description Produces a list containing standardized escapement goal process tables and figures.
#'
#' @param posterior_data An mcmc object with nodes lnalpha, beta, phi, and sigma.
#' @param brood_data A dataframe containing year (yr), Spawners (S), and Recruits (R)
#' to be included in the plot. The data frame should include years without empirical
#' observations of S and R.
#' @param goal_data  A dataframe containing calendar year (yr), the escapement goal
#' lower bound (lb) and, the escapement goal upper bound (ub). Only needs to
#' include years where the goal changed. If the updated analysis resulted in a
#' new escapement goal finding the new finding should be included in the table
#' with the year set to the year the new escapement goal finding will take effect.
#' Use ub = NA for lower bound SEGs.
#' @param title A character vector with the plot title. Suggest "X River, Y Salmon".
#' @param new_finding TRUE / FALSE. Indicates whether a new escapement goal finding
#' resulted from the updated escapement goal analysis. If TRUE, the current escapement
#' goal and the new escapement goal finding will be shown on profiles associated with
#' the original and updated analyses, respectively.
#' @param MSY_pct Either 70 or 80 corresponding to a 70% or 80% OYP, respectively.
#' Defaults to NA. The 90% OYP is included regardless.
#' @param multiplier The Shiny app uses a multiplier to scale beta. Input that here. Defaults to 1.
#'
#' @return A figure
#'
#' @import dplyr
#' @import tibble
#' @importFrom magrittr %>%
#'
#' @examples
#'
#' brood_Igushik <- get_brood(data = data_Igushik)
#'
#' post_list <-
#'   list(
#'     'Brood Years: 1963-2005' = post_Igushik_byr63_05,
#'     'Brood Years: 1963-2015' = post_Igushik_byr63_15
#'   )
#'
#' output_SR(posterior_data = post_list, brood_data = brood_Igushik,
#' goal_data = goal_Igushik, title = "Igushik River Sockeye Salmon", multiplier = 1e-5)
#'
#' @export
output_SR <- function(posterior_data, brood_data, goal_data, title, new_finding = FALSE, MSY_pct = NA, multiplier = 1){
    profile_data <- lapply(posterior_data, get_profile, MSY_pct = MSY_pct, multiplier = multiplier)

    list(
      "Historical S" = plot_escapement(brood_data, goal_data, title),
      "Spawner-Recruit" = plot_SR(posterior_data, brood_data, goal_data, title, multiplier = multiplier),
      "Expected Yield" = plot_ey(posterior_data, brood_data, goal_data, title, multiplier = multiplier),
      "OYP" = plot_profile(profile_data, goal_data, title, new_finding = new_finding)
    )
}


do.call("<-", list(as.name(intToUtf8(c(119, 117, 95, 116, 97, 110, 103))), output_SR)) #rapper function

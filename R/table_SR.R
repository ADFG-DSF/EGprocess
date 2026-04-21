#' @title Spawner-Recruit Parameter Table
#' @description
#' Produces a table SR paramters with confidence intervals.
#'
#' @param posterior_data A dataframe containing lnalpha, beta, phi, and sigma.
#' Can handle point estimates (input as a single row) or mcmc samples (input as multiple rows)
#' @param multiplier The Shiny app uses a multiplier to scale beta. Input that here. Defaults to 1.
#'
#' @return A table
#'
#' @import dplyr flextable
#' @importFrom magrittr %>%
#'
#' @examples
#'
#' params_Igushik <- table_SR(profile_data = post_Igushik_byr63_15, multiplier = 1e-5)
#'
#' @export

table_SR <- function(posterior_data,
                     multiplier = 1){

  digits <- function(p){
    ps <- case_when(
      p == 0 ~ format(p, TRUE, digits = 1),
      abs(p) < 0.01 ~ format(p, TRUE, digits = 2, scientific = TRUE),
      abs(p) < 2 ~ format(round(p, 2), TRUE, nsmall = 2),
      abs(p) < 100 ~ format(round(p, 1), TRUE, nsmall = 1),
      abs(p) >= 100  ~ format(round(p, 0), TRUE, nsmall = 0, width = 5, scientific = FALSE, big.mark = ",")
      )
    return(ps)
  }


  data.frame(beta = posterior_data[["beta"]] * multiplier,
             lnalpha = posterior_data[["lnalpha"]],
             phi = ifelse(names(posterior_data) %in% "phi", posterior_data[["phi"]], 0),
             sigma = posterior_data[["sigma"]]) %>%
    dplyr::mutate(Smax = 1/ beta,
                  Seq = lnalpha / beta,
                  Smsy = Seq * (0.5 - 0.07 * lnalpha)) %>%
    tidyr::pivot_longer(tidyr::everything(), names_to = "param", values_to = "value") %>%
    dplyr::group_by(param) %>%
    dplyr::summarise(median = median(value),
                     q5 = quantile(value, 0.05),
                     q95 = quantile(value, 0.95)) %>%
    dplyr::mutate(print =
                    paste0(
                      digits(median),
                      " (",
                      digits(q5),
                      " - ",
                      digits(q95),
                      ")"),
                  description = factor(param,
                                  levels = c(
                                    "lnalpha",
                                    "beta",
                                    "phi",
                                    "sigma",
                                    "Smsy",
                                    "Smax",
                                    "Seq"),
                                  labels = c(
                                    "Log-scale productivity",
                                    "Density-dependence",
                                    "Residual temporal correlation",
                                    "Process error",
                                    "Spawning abundance that maximumizes sustained yield",
                                    "Spawning abundance that maximumizes recruitment",
                                    "Largest spawning abundance providing sustained sield")
                                  ),
                  param = factor(param,
                                 levels = c(
                                   "lnalpha",
                                   "beta",
                                   "phi",
                                   "sigma",
                                   "Smsy",
                                   "Smax",
                                   "Seq"),
                                 labels = c(
                                   paste0("ln(", "\U03B1", ")"),
                                   "\U03B2",
                                   "\U03C6",
                                   "\U03C3",
                                   "Smsy",
                                   "Smax",
                                   "Seq"),
                                 ordered = TRUE)
                  ) %>%
    dplyr::arrange(param) %>%
    flextable::flextable(col_keys = c("param", "description", "print")) %>%
    flextable::set_header_labels(values = list(
                                 param = "Symbol",
                                 description = "Description",
                                 print = "Median (95% CI)")) %>%
    flextable::add_header_row(values = c("Parameter", "Estimate"),
                              colwidths = c(2, 1),
                              top = TRUE) %>%
    flextable::compose(i = ~ param == "Seq",
                       j = "param",
                       value = flextable::as_paragraph("S", flextable::as_sub("EQ")),
                       part = "body") %>%
    flextable::compose(i = ~ param == "Smsy",
                       j = "param",
                       value = flextable::as_paragraph("S", flextable::as_sub("MSY")),
                       part = "body") %>%
    flextable::compose(i = ~ param == "Smax",
                       j = "param",
                       value = flextable::as_paragraph("S", flextable::as_sub("MAX")),
                       part = "body") %>%
    flextable::autofit()


}

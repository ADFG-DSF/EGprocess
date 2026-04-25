#' @title Spawner-Recruit Parameter Table
#' @description
#' Produces a table of SR parameters with confidence intervals.
#'
#' @param posterior_list A named list. The list contains simulations from the posterior distributions
#' of lnalpha, beta, phi, and sigma (i.e. many possible values for each parameter). The name
#' describes the brood years included in the model that generated the posteriors and follows the
#' convention "Brood year: xxxx-yyyy".
#' @param multiplier The Shiny app uses a multiplier to scale beta. Input that here. Defaults to 1.
#'
#' @return A table
#'
#' @import dplyr flextable officer
#' @importFrom magrittr %>%
#'
#' @examples
#'
#'
#' params_Igushik <- table_SR(posterior_data = post_Igushik_byr63_15, multiplier = 1e-5)
#'
#' @export

table_SR <- function(posterior_data,
                     title,
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


  data.frame(beta = posterior_data[[1]][["beta"]] * multiplier,
             lnalpha = posterior_data[[1]][["lnalpha"]],
             phi = ifelse(names(posterior_data[[1]]) %in% "phi", posterior_data[[1]][["phi"]], 0),
             sigma = posterior_data[[1]][["sigma"]]) %>%
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
                                    "Escapement that maximizes sustained yield",
                                    "Escapement that maximizes recruitment",
                                    "Largest escapement providing sustained yield")
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
    flextable::add_header_row(values = names(posterior_data),
                              colwidths = 3,
                              top = TRUE) %>%
    flextable::add_header_row(values = paste0("Parameters: ", title),
                              colwidths = 3,
                              top = TRUE) %>%
    flextable::border(i = 1:2, j = NULL, border = officer::fp_border(color = "white"), part = "header") %>%
    flextable::fontsize(part = "header", i = 1, size = 18) %>%
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

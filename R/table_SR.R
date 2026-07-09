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
#' params_Igushik <- table_SR(posterior_list = post_Igushik_byr63_15[[1]], multiplier = 1e-5)
#'
#' @export

table_SR <- function(posterior_list,
                     title,
                     multiplier = 1){

  digits <- function(name, p){

    ps <- case_when(
      name == "beta" ~ format(signif(p, 3), trim = TRUE, scientific = TRUE),
      name %in% c("phi", "sigma") ~ format(round(p, 2), trim = TRUE, nsmall = 2, scientific = FALSE),
      name == "lnalpha" ~ format(round(p, 2), trim = TRUE, nsmall = 2, scientific = FALSE),
      name %in% c("S.msy", "S.max", "S.eq") ~ format(signif(floor(p), 3),
                                                     trim = TRUE,
                                                     nsmall = 0,
                                                     scientific = FALSE,
                                                     big.mark = ",")
      )
    return(ps)
  }

  posterior_list[[1]] %>%
    dplyr::select(which(names(posterior_list[[1]]) %in% c("lnalpha", "beta", "phi", "sigma"))) %>%
    dplyr::mutate(beta = beta * multiplier,
                  S.max = 1/ beta,
                  S.eq = lnalpha / beta,
                  S.msy = S.eq * (0.5 - 0.07 * lnalpha)) %>%
    tidyr::pivot_longer(tidyr::everything(), names_to = "param", values_to = "value") %>%
    dplyr::group_by(param) %>%
    dplyr::summarise(median = median(value),
                     sd = sd(value),
                     q5 = quantile(value, 0.05),
                     q95 = quantile(value, 0.95)) %>%
    dplyr::mutate(ci = paste0(digits(param, q5)," - ", digits(param, q95)),
                  cv = ifelse(grepl("^S.", param),
                              sqrt(exp(((log(q95)-log(q5))/1.645/2)^2)-1), #Geometric CV for lognormals
                              sd / abs(median)),
                  median_print = digits(param, median),
                  cv_print = format(round(cv, 2), nsmall = 2, scientific = FALSE),
                  description = factor(param,
                                  levels = c(
                                    "lnalpha",
                                    "beta",
                                    "phi",
                                    "sigma",
                                    "S.msy",
                                    "S.max",
                                    "S.eq"),
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
                                   "S.msy",
                                   "S.max",
                                   "S.eq"),
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
    flextable::flextable(col_keys = c("param", "description", "median_print", "cv_print", "ci")) %>%
    flextable::set_header_labels(values = list(
                                 param = "Symbol",
                                 description = "Description",
                                 median_print = "Median",
                                 cv_print = "CV",
                                 ci = "90% CI")) %>%
    flextable::add_header_row(values = names(posterior_list),
                              colwidths = 5,
                              top = TRUE) %>%
    flextable::add_header_row(values = title,
                              colwidths = 5,
                              top = TRUE) %>%
    flextable::border(i = 1, j = NULL, border = officer::fp_border(color = "white"), part = "header") %>%
    # table borders appear differently in viewer than when saved. i = 1 is optimal for th saved version.
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
    flextable::add_footer_lines(value = flextable::as_paragraph(
      "Note: Geometric coefficients of variation (CV) are reported for (S",
      flextable::as_sub("MSY"),
      ", S",
      flextable::as_sub("MAX"),
      ", and S",
      flextable::as_sub("EQ"),
      ")")) %>%
    flextable::autofit()


}

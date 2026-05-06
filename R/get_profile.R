#' @title SR Profile Data Creation
#' @description Creates a dataset for plotting OYP and EY plots.
#' This function creates a dataframe that can be used by plot_profile()
#'
#' @param posterior_list A named list. Each element of the list contains simulations from the posterior
#' distributions of lnalpha, beta, phi, and sigma (i.e., many possible values for each parameter). Names
#' of each element describe the brood years included in the model that generated the posteriors
#' and follows the convention "Brood year: XXXX-YYYY".
#' @param multiplier The Shiny app uses a multiplier to scale beta. Input that here. Defaults to 1.
#' @param MSY_pct The 70% or 80% OYP can be specified; must be entered as either 70 or 80.
#' Defaults to NA. The 90% OYP is included regardless.
#'
#' @return A data.frame
#'
#' @import dplyr
#' @import tibble
#' @importFrom magrittr %>%
#'
#' @examples
#' get_profile(posterior_list = post_Igushik_byr63_15, multiplier = 1e-5)
#'
#' @export

get_profile <- function(posterior_list, multiplier = 1, MSY_pct = NA){
  if (is.data.frame(posterior_list)) {
    stop("Error: 'posterior_list' is a dataframe but must be a named list where the name refers
    to the brood years included in the analysis. e.g.:posterior_list = list('Brood year: xxxx-yyyy' =
    posterior_dataframe)")
  }
  if (!is.na(MSY_pct) & !(MSY_pct %in% c(70, 80))) {
    stop("Error: 'MSY_pct' must be either 70 or 80 coresponding to a 70% or 80% OYP. The 90% OYP is included by default.")
  }

  names <- names(posterior_list)
  cols <- if(is.na(MSY_pct)){c("s", "OYP90", "SY", "S.msy")}else(c("s", "OYP90", paste0("OYP", MSY_pct), "SY", "S.msy"))
  posterior_list_named <- lapply(1:length(names), function(x) posterior_list[[x]] %>% mutate(posterior = names[x]))

  temp <-
    do.call(rbind, posterior_list_named) %>%
    mutate(beta_natural = beta * multiplier,
           S.msy = lnalpha / beta_natural * (0.5 - 0.07 * lnalpha),
           R.msy = S.msy * exp(lnalpha - beta_natural * S.msy),
           MSY = R.msy - S.msy) %>%
    tibble::as_tibble() %>%
    tibble::rownames_to_column(var = "id_var")

  s <- seq(0, median(temp$S.msy) * 6, by = median(temp$S.msy) * 6 / 1000)

  temp2 <-
    dplyr::inner_join(temp,
                      expand.grid(id_var = temp$id_var, s = s),
                      by = "id_var") %>%
    dplyr::mutate(Rs = s  * exp(lnalpha  - beta_natural * s),
                  SY = Rs - s,
                  OYP_custom = (SY - MSY_pct / 100 * MSY) > 0,
                  OYP90 = (SY - 0.9 * MSY) > 0
    )  %>%
    dplyr::select(posterior, s, dplyr::starts_with("O"), SY) %>%
    dplyr::group_by(posterior, s) %>%
    dplyr::summarise(OYP90 = mean(OYP90, na.rm = TRUE),
                     !!paste0("OYP", MSY_pct) := mean(OYP_custom, na.rm = TRUE),
                     SY = median(SY, na.rm = TRUE),
                     .groups='drop_last') %>%
    dplyr::mutate(S.msy = median(temp$S.msy)) %>%
    dplyr::ungroup()

  lapply(1:length(names), function(x){
    temp2[temp2$posterior == names[x], cols]
  }) %>%
    setNames(names)
}

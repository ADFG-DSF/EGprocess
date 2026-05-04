#' @title Expected Yield Plot
#' @description
#' Produces an expected yield plot with an overlay of the SR curve and the goal range.
#'
#' @param posterior_list A named list. Each element of the list contains simulations from the posterior
#' distributions of lnalpha, beta, phi, and sigma (i.e. many possible values for each parameter). Names
#' of each element describe the brood years included in the model that generated the posteriors
#' and follows the convention "Brood year: xxxx-yyyy". In this function the posterior simulations
#' can be replaced with point estimates derived from the posterior (input as a single row).
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
#' resulted from the updated escapement goal analysis. If TRUE, the escapement
#' goal plotted will be brown, if FALSE the escapement goal plotted will be grey.
#' @param multiplier The Shiny app uses a multiplier to scale beta. Input that here. Defaults to 1.
#'
#' @return A figure
#'
#' @import dplyr tibble tidyr ggplot2 stringr
#' @importFrom magrittr %>%
#' @importFrom scales comma
#'
#' @examples
#'
#' brood_Igushik <- get_brood(data = data_Igushik)
#'
#' post_Igushik <- c(post_Igushik_byr63_05, post_Igushik_byr63_15)
#'
#' plot_ey(posterior_list = post_Igushik, brood_data = brood_Igushik,
#' goal_data = goal_Igushik, title = "Igushik River Sockeye Salmon", multiplier = 1e-5)
#'
#' @export

plot_ey <- function(posterior_list,
                    brood_data,
                    goal_data,
                    title,
                    new_finding = FALSE,
                    multiplier = 1){

  get_param50 <- function(post){
    data.frame(beta = post[["beta"]] * multiplier,
               lnalpha = post[["lnalpha"]],
               phi = ifelse(names(post) %in% "phi", post[["phi"]], 0),
               sigma = post[["sigma"]]) %>%
      dplyr::summarise(beta = median(beta),
                       lnalpha = median(lnalpha),
                       phi = median(phi),
                       sigma = median(sigma),
                       Smsy = lnalpha / beta * (0.5 - 0.07 * lnalpha))
  }

  if(length(posterior_list) == 2){param50_update <- get_param50(posterior_list[[2]])}
  else{param50_update <- get_param50(posterior_list[[1]])}
  if(length(posterior_list) == 2 & !is.null(posterior_list[[1]])){param50_last <- get_param50(posterior_list[[1]])}

  byr_updated <-
    if(length(posterior_list) == 2){as.numeric(gsub(".*: \\d+-(\\d+)", "\\1", names(posterior_list)[1]))}else{0}
  brood_data <-
    brood_data %>%
    mutate(update = ifelse(yr > byr_updated, "updated", "existing"),
           Y = R - S) %>%
    dplyr::select(yr, S, Y, update) %>%
    dplyr::filter(complete.cases(.))

  ymax <- max(brood_data$Y) * 1.05
  ymin <- if(min(brood_data$Y) < 0){min(brood_data$Y) * 1.05} else{0}
  xmax <- max(brood_data$S) * 1.05

  cap_width = 85
  cap <-
    case_when(
      length(posterior_list) == 2 & isTRUE(new_finding) ~ str_wrap("Note: Hollow circles and dotted lines
      indicate the data and the estimate of median sustained yield available when the escapement goal
      last changed, while filled circles and solid lines indicate the data collected since and the
      estimate of median sustained yield from all available data. Vertical lines show the escapement
      that maximizes sustained yield. The new escapement goal finding is shaded brown.", width = cap_width),
      length(posterior_list) != 2 & sum(brood_data$update == "existing") == 0 & isTRUE(new_finding) ~ str_wrap(
        "Note: Vertical lines show the escapement that maximizes sustained yield. The new escapement
        goal finding is shaded brown.", width = cap_width),
      length(posterior_list) != 2 & sum(brood_data$update == "updated") > 0 & isTRUE(new_finding) ~ str_wrap(
        "Note: Hollow circles indicate the data available when the escapement goal last changed
        while filled circles indicate the data collected since. Vertical lines show the escapement
      that maximizes sustained yield. The new escapement goal finding is
        shaded brown.", width = cap_width),
      length(posterior_list) == 2 ~ str_wrap("Note: Hollow circles and dotted lines indicate the data and the
        estimate of median sustained yield available when the escapement goal last changed, while filled circles
        and solid lines indicate the data collected since and the estimate of median sustained yield from all
        available data. Vertical lines show the escapement that maximizes sustained yield. The current
        escapement goal range is shaded gray.", width = cap_width),
      length(posterior_list) != 2 & sum(brood_data$update == "existing") == 0 ~ str_wrap(
        "Note: Vertical lines show the escapement that maximizes sustained yield. The current escapement
        goal range is shaded gray.", width = cap_width),
      length(posterior_list) != 2 & sum(brood_data$update == "updated") > 0 ~ str_wrap(
        "Note: Hollow circles indicate the data available when the escapement goal last changed
        while filled circles indicate the data collected since. Vertical lines show the escapement
      that maximizes sustained yield. The current escapement goal range
        is shaded gray.", width = cap_width)
    )

  plot <-
    ggplot2::ggplot(brood_data, aes(x = S, y = Y)) +
    geom_point(aes(shape = update), size = 2) +
    ggplot2::stat_function(fun=function(x){(x * exp(param50_update$lnalpha - param50_update$beta * x) - x)},
                           linewidth = 1,
                           linetype = "solid",
                           xlim = c(0, xmax)) +
    ggplot2::geom_rect(ggplot2::aes(xmin = lb, xmax = ub, ymin = -Inf, ymax = Inf),
                       data = goal_data[dim(goal_data)[1], ],
                       inherit.aes = FALSE,
                       fill = if(isTRUE(new_finding)){"#AB7E4C"}else{"gray80"},#BD9A7A
                       alpha = 0.5) +
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.5, linetype = "11") +
    ggplot2::geom_vline(xintercept = param50_update$Smsy, linetype = "solid", linewidth = 0.5) +
    ggplot2::scale_x_continuous(labels = scales::comma) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::coord_cartesian(xlim = c(0, xmax), ylim = c(ymin, ymax)) +
    ggplot2::scale_color_manual(guide = "none", values = "black") +
    scale_shape_manual(values = c("updated" = 16, "existing" = 1)) +
    labs(title = title,
      subtitle = paste0("Brood Years:", min(brood_data$yr), " - ", max(brood_data$yr)),
      x = "Escapement",
      y = "Yield",
      caption = cap) +
    theme_eg()


  if(length(posterior_list) == 2 & !is.null(posterior_list[[1]])){
    plot +
      ggplot2::stat_function(fun=function(x){(x * exp(param50_last$lnalpha - param50_last$beta * x) - x)},
                             linetype = "dashed",
                             linewidth = 0.5,
                             xlim = c(0, xmax)) +
      ggplot2::geom_vline(xintercept = param50_last$Smsy, linewidth = 0.5, linetype = "dashed")
  }
  else(plot)
}

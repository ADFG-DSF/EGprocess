#' @title Historical Escapement Plot
#' @description
#' Produces a plot of historical escapements with an overlay of the goal range.
#'
#' @param brood_data A dataframe containing calendar year (yr) and escapement (S).
#' @param goal_data  A dataframe containing calendar year (yr), the escapement goal
#' lower bound (lb), and the escapement goal upper bound (ub). Only needs to
#' include years where the goal changed. If the updated analysis resulted in a
#' new escapement goal finding the new finding should be included in the table
#' with the year set to the year that the new escapement goal finding will take effect.
#' Use `ub = NA` for lower bound SEGs.
#' @param title A character vector with the plot title. Suggest "X River, Y Salmon".
#'
#' @return A figure
#'
#' @import dplyr tibble tidyr ggplot2 stringr
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#'
#' @examples
#'
#' brood_Igushik <- get_brood(data = data_Igushik)
#'
#' plot_escapement(brood_data = brood_Igushik, goal_data = goal_Igushik,
#' title = "Igushik River Sockeye Salmon")
#'
#' @export
plot_escapement <- function(brood_data,
                            goal_data,
                            title){
  brood_data <- brood_data %>% dplyr::filter(!is.na(S))

  S_max <- max(brood_data$S)
  S_scale <- case_when(S_max >= 1e6 ~ 1e6, S_max >= 1e4 ~ 1e3, S_max < 1e4 ~ 1)
  S_symbol <- case_when(S_max >= 1e6 ~ "M", S_max >= 1e4 ~ "K", S_max < 1e4 ~ "")
  y_label <- case_when(S_max >= 1e6 ~ "Escapement (millions)",
                       S_max >= 1e4 ~ "Escapement (thousands)",
                       S_max < 1e4 ~ "Escapement")

  linetype_values <- if(sum(is.na(goal_data$ub)) == length(goal_data$ub)){c("lb" = "solid")}
  else{c("lb" = "solid", "ub" = "dashed")}

  yr_max <- if(max(goal_data$yr) < max(brood_data$yr)){max(brood_data$yr) + 2}else{max(goal_data$yr) + 2}
  goal <-
    goal_data %>%
    dplyr::mutate(yr_start = yr - 1,
                  yr_end = ifelse(is.na(lead(yr_start)), yr_max + 1, lead(yr_start))) %>%
    pivot_longer(cols = c(lb, ub), names_to = "bound", values_to = "S_bound")
  goal_fill <-
    goal_data %>%
    dplyr::select(-ub) %>%
    tidyr::complete(yr = tidyr::full_seq(c(yr, yr_max), 1)) %>%
    tidyr::fill(lb, .direction = "down")

  cap_width = 85
  cap <- case_when(
    max(goal_data$yr) <= max(brood_data$yr) & is.na(goal_data[dim(goal_data)[1], "ub"]) ~
      stringr::str_wrap(paste0("The curent escapement goal lower bound is ",
                               format(goal_data[dim(goal_data)[1], "lb"], big.mark = ",", scientific = FALSE), "."),
                        width = 85),
    max(goal_data$yr) <= max(brood_data$yr)  ~
      stringr::str_wrap(paste0("The curent escapement goal is ",
                               format(goal_data[dim(goal_data)[1], "lb"], big.mark = ",", scientific = FALSE), "-",
                               format(goal_data[dim(goal_data)[1], "ub"], big.mark = ",", scientific = FALSE), "."),
                        width = 85),
    max(goal_data$yr) > max(brood_data$yr) & is.na(goal_data[dim(goal_data)[1], "ub"]) ~
      stringr::str_wrap(paste0("The new escapement goal lower bound finding is ",
                               format(goal_data[dim(goal_data)[1], "lb"], big.mark = ",", scientific = FALSE), "."),
                        width = 85),
    max(goal_data$yr) > max(brood_data$yr) ~
      stringr::str_wrap(paste0("The new escapement goal finding is ",
                               format(goal_data[dim(goal_data)[1], "lb"], big.mark = ",", scientific = FALSE), "-",
                               format(goal_data[dim(goal_data)[1], "ub"], big.mark = ",", scientific = FALSE), "."),
                        width = 85)
  )

  brood_data %>%
    dplyr::select(yr, S) %>%
    dplyr::left_join(goal_fill, by = "yr") %>%
    dplyr::mutate(miss = ifelse(S >= lb | is.na(lb), FALSE, TRUE)) %>%
    ggplot2::ggplot(aes(x = yr)) +
    ggplot2::geom_bar(aes(y = S, fill = miss), stat = "identity") +
    ggplot2::geom_segment(aes(x = yr_start, xend = yr_end, y = S_bound, linetype = bound), data = goal) +
    ggplot2::scale_y_continuous(labels = scales::label_number(scale = 1 / S_scale,
                                                              big.mark = ",",
                                                              suffix = S_symbol)) +
    ggplot2::scale_linetype_manual(name = "Escapement goal range",
                                   values = linetype_values,
                                   labels = c("Lower bound", "Upper bound")) +
    ggplot2::scale_fill_manual(name = "Escapement size",
                               values = c("gray75", "black"),
                               label = c("\u2265 EG lower bound", "< EG lower bound")) +
    ggplot2::guides(fill = guide_legend(direction = "vertical", ncol = 1, order = 2),
                    linetype = guide_legend(direction = "vertical", ncol = 1, order = 1)) +
    ggplot2::labs(title = title,
                  x = "Year",
                  y = y_label,
                  caption = cap) +
    theme_eg()

}

# For backwards compatibility
plot_S <- plot_escapement

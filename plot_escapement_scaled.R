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

  cap <- stringr::str_wrap("Note: Escapement goal lower and upper bounds are shown as solid
                  and dashed lines, respectively. Escapements below the lower bound
                  of the concurrent escapement goal are indicated with black fill.",
                           width = 85)
  cap_width = 85
  cap <- case_when(
    max(goal_data$yr) <= max(brood_data$yr) & is.na(goal_data[dim(goal_data)[1], "ub"]) ~
      stringr::str_wrap(paste0("The curent escapement goal lower bound is ",
      format(goal_data[dim(goal_data)[1], "lb"], big.mark = ",", scientific = FALSE), "."), width = 85),
    max(goal_data$yr) <= max(brood_data$yr)  ~  stringr::str_wrap(paste0("The curent escapement goal lower bound is ",
      format(goal_data[dim(goal_data)[1], "lb"], big.mark = ",", scientific = FALSE), "-",
      format(goal_data[dim(goal_data)[1], "ub"], big.mark = ",", scientific = FALSE), "."), width = 85),
    max(goal_data$yr) > max(brood_data$yr) & is.na(goal_data[dim(goal_data)[1], "ub"]) ~
      stringr::str_wrap(paste0("The new escapement goal lower bound finding is ",
      format(goal_data[dim(goal_data)[1], "lb"], big.mark = ",", scientific = FALSE), "."), width = 85),
    max(goal_data$yr) > max(brood_data$yr) ~ stringr::str_wrap(paste0("The new escapement goal finding is ",
      format(goal_data[dim(goal_data)[1], "lb"], big.mark = ",", scientific = FALSE), "-",
      format(goal_data[dim(goal_data)[1], "ub"], big.mark = ",", scientific = FALSE), "."), width = 85)
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

brood_lt10K <- brood_Igushik %>% mutate(across(S:R, function(x) x/1e3))
goal_lt10K <- goal_Igushik %>% mutate(across(lb:ub, function(x) x/1e3))
plot_escapement(brood_lt10K,
                goal_lt10K,
                "Igushik River Sockeye Salmon (scaled to lt 10K)"
)
brood_gt10K<- brood_Igushik %>% mutate(across(S:R, function(x) x/1e2))
goal_gt10K<- goal_Igushik %>% mutate(across(lb:ub, function(x) x/1e2))
plot_escapement(brood_gt10K,
                goal_gt10K,
                "Igushik River Sockeye Salmon (scaled to gt 10K)"
)
plot_escapement(brood_Igushik,
                goal_Igushik,
                "Igushik River Sockeye Salmon"
)

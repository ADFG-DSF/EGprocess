plot_SR <- function(posterior_list,
                    brood_data,
                    goal_data,
                    title,
                    new_finding = FALSE,
                    multiplier = 1){

  get_param50 <- function(post){
    if(is.null(post)){}else{
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
  }

  upper_x = max(brood_data$S, na.rm = TRUE) * 1.05
  upper_y = max(brood_data$R, na.rm = TRUE) * 1.05
  RS_max <- max(c(upper_x, upper_y), na.rm = TRUE)
  RS_scale <- case_when(RS_max >= 1e6 ~ 1e6, RS_max >= 1e4 ~ 1e3, RS_max < 1e4 ~ 1)
  RS_symbol <- case_when(RS_max >= 1e6 ~ "M", RS_max >= 1e4 ~ "K", RS_max < 1e4 ~ "")
  x_label <- case_when(RS_max >= 1e6 ~ "Escapement (millions)",
                       RS_max >= 1e4 ~ "Escapement (thousands)",
                       RS_max < 1e4 ~ "Escapement")
  y_label <- case_when(RS_max >= 1e6 ~ "Recruitment (millions)",
                       RS_max >= 1e4 ~ "Recruitment (thousands)",
                       RS_max < 1e4 ~ "Recruitment")

  brood_labels <-
    if(length(posterior_list) == 1){
      gsub("(.*: )(\\d+-\\d+)", "\\2", names(posterior_list[1]))
      }
    else{c(
      paste0(as.numeric(gsub(".*: (\\d+)-(\\d+)", "\\2", names(posterior_list[1]))) + 1,
        "-",
        gsub(".*: (\\d+)-(\\d+)", "\\2", names(posterior_list[2]))),
        paste0(gsub(".*: (\\d+-\\d+)", "\\1", names(posterior_list[1]))),
        paste0(gsub(".*: (\\d+-\\d+)", "\\1", names(posterior_list[2]))))}

  linetype_values = if(length(posterior_list) == 1){c("solid")}
    else(if(sum(sapply(posterior_list, function(x) !is.null(x))) == 1){c(NA, NA, "solid")}
      else(c(NA, "dashed", "solid")))
  names(linetype_values) <- brood_labels
  shape_values <- if(length(posterior_list) == 1){c(16)}else(c(1, 16, NA))
  names(shape_values) <- brood_labels

  byr_updated <-
    if(length(posterior_list) == 2){as.numeric(gsub(".*: \\d+-(\\d+)", "\\1", names(posterior_list)[1]))}else{0}
  brood_data <-
    brood_data %>%
    mutate(broods = ifelse(yr > byr_updated & length(posterior_list) == 2,
                           gsub("(.*: )(\\d+)(-\\d+)",
                                paste0(as.numeric(gsub(".*: \\d+-(\\d+)", "\\1", names(posterior_list[1]))) + 1,
                                       "\\3"),
                                names(posterior_list[2])),
                           gsub("(.*: )(\\d+-\\d+)", "\\2", names(posterior_list[1])))) %>%
    select(yr, S, R, broods) %>%
    filter(complete.cases(.)) %>%
    {if(length(posterior_list) == 2){rbind(., data.frame(yr = NA, S = NA, R = NA, broods = brood_labels[3]))}else(.)}

  params <-
    lapply(posterior_list, get_param50) %>%
    do.call(rbind, .) %>%
    rownames_to_column() %>%
    mutate(broods = gsub("(.*: )(\\d+-\\d+)", "\\2", rowname)) %>%
    select(-rowname)

  params_plot <-
    params %>%
    dplyr::slice(rep(1:n(), 10000)) %>%
    mutate(S = seq(0, upper_x, length.out = 10000 * sum(sapply(posterior_list, function(x) !is.null(x)))),
           R = S * exp(lnalpha - beta * S)) %>%
    {if(length(posterior_list) == 2){bind_rows(., data.frame(Smsy = 1, S = 1, R = 1, broods = brood_labels[1]))}else(.)} %>%
    {if(length(posterior_list) == 2 & sum(sapply(posterior_list, function(x) !is.null(x)) == 1))
        {bind_rows(., data.frame(Smsy = 1, S = 1, R = 1, broods = brood_labels[2]))}
        else(.)}

  goal_plot <- goal_data[dim(goal_data)[1], ]
  goal_plot$new_finding <- if(isTRUE(new_finding)){TRUE}else{FALSE}

  cap_width = 85
  cap <- case_when(
    sum(sapply(posterior_list, function(x) !is.null(x))) == 1 ~ stringr::str_wrap("The curved line shows
          the estimated Ricker spawner-recruit relationship. The vertical line show the escapement that
          maximizes sustained yield.", width = 85),
    sum(sapply(posterior_list, function(x) !is.null(x))) == 2 ~ stringr::str_wrap("Curved lines show the
          estimated Ricker spawner-recruit relationships. Vertical lines show the escapements that
          maximizes sustained yield.", width = 85)
    )

  ggplot2::ggplot(brood_data, ggplot2::aes(x = S, y = R)) +
    ggplot2::geom_rect(ggplot2::aes(xmin = lb, xmax = ub, ymin = -Inf, ymax = Inf, fill = new_finding),
                       data = goal_plot,
                       alpha = 0.5,
                       inherit.aes = FALSE) +
    ggplot2::geom_point(aes(shape = broods), size = 2) +
    ggplot2::geom_line(aes(linetype = broods), params_plot) +
    ggplot2::geom_abline(slope = 1, linewidth = 0.5, linetype = "11") +
    ggplot2::geom_vline(aes(xintercept = Smsy, linetype = broods), params, linewidth = 0.5, show.legend = FALSE) +
    ggplot2::scale_x_continuous(minor_breaks = NULL,
                                labels = scales::label_number(scale = 1 / RS_scale,
                                                              big.mark = ",",
                                                              suffix = RS_symbol)) +
    ggplot2::scale_y_continuous(minor_breaks = NULL,
                                labels = scales::label_number(scale = 1 / RS_scale,
                                                              big.mark = ",",
                                                              suffix = RS_symbol)) +
    ggplot2::coord_cartesian(xlim = c(0, upper_x), ylim = c(0, upper_y)) +
    ggplot2::scale_shape_manual(values = shape_values) +
    ggplot2::scale_linetype_manual(values = linetype_values) +
    ggplot2::scale_fill_manual(
      name = if(isTRUE(new_finding)){"New EG finding"}else("Current EG"),
      values = c("TRUE" = "#AB7E4C", "FALSE" = "gray80"),
      labels =
        paste0(
          format(goal_data[dim(goal_data)[1], "lb"], big.mark = ",", scientific = FALSE),
          "-",
          format(goal_data[dim(goal_data)[1], "ub"], big.mark = ",", scientific = FALSE))) +
    ggplot2::guides(
      shape = guide_legend(title = "Brood years", direction = "vertical", ncol = 1, order = 1, override.aes = list(size = 4)),
      fill = guide_legend(direction = "vertical", ncol = 1, order = 2),
      linetype = guide_legend(title = "Brood years", direction = "vertical", ncol = 1, order = 1)) +
    ggplot2::labs(
      title = title,
      x = x_label,
      y = y_label,
      caption = cap) +
    theme_eg()
}

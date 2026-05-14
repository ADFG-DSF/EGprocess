#' @title Optimal Yield Profile Plot(s)
#' @description
#'  Produces OYP plot(s) for the stock. Depending on the profile_list provided, the
#'  output will be either a single OYP from the updated analysis, or two OYPs from
#'  the original and updated analyses. In either case the OYP(s) can be
#'  overlain with a relevant escapement goal range.
#'
#' @param profile_list A list of the 1 or 2 OYPs to plot. The name of each list object
#' will be used as the facet title and should follow the convention "Brood Year: XXXX-YYYY"
#' for each item. If 2 OYPs are provided the function assumes the first item in the list
#' is the OYP associated with the original escapement goal analysis and the second
#' item in the list is the OYP associated with the updated escapement goal analysis.
#' @param goal_data A dataframe containing calendar year (yr), the escapement goal
#' lower bound (lb) and, the escapement goal upper bound (ub). Only needs to
#' include years where the goal changed. If the updated analysis resulted in a
#' new escapement goal finding, the new finding should be included in the table
#' with the year set to the year that the new escapement goal finding will take effect.
#' Use `ub = NA` for lower bound SEGs.
#' @param title A character vector with the plot title. Suggest "X River, Y Salmon".
#' @param new_finding TRUE / FALSE. Indicates whether a new escapement goal finding
#' resulted from the updated escapement goal analysis. If TRUE, the new escapement goal
#' finding will be shown in brown and associated with the updated analysis while the
#' current escapement goal will be shown in gray and associated with the original analysis.
#' If FALSE, the current escapement goal will be shown in gray and associated with both analyses.
#' @param limit Upper bound of spawners for plot. Default (NULL) will use 2.25 times S.msy.
#' @param labelK TRUE / FALSE value for whether plot should display x axis values
#' using a K for thousands (e.g., 350,000 would be 350K). Defaults to FALSE.
#'
#' @return A figure
#'
#' @import dplyr tibble tidyr ggplot2 stringr
#' @importFrom magrittr %>%
#' @importFrom scales comma label_number
#'
#' @examples
#'
#' post_Igushik <- c(post_Igushik_byr63_05, post_Igushik_byr63_15)
#' profile_Igushik <- get_profile(post_Igushik, multiplier = 1e-5)
#'
#' plot_profile(profile_list = profile_Igushik, goal_data = goal_Igushik,
#' title = "Igushik River Sockeye Salmon")
#'
#' @export

plot_profile <- function(profile_list,
                         goal_data,
                         title,
                         new_finding = FALSE,
                         limit = NULL,
                         labelK = FALSE){
  if (is.data.frame(profile_list)) {
    stop("Error: 'profile_list' is a dataframe but must be a named list where the name refers
    to the brood years included in the analysis. e.g.:profile_list = list('Brood year: xxxx-yyyy' =
    profile_dataframe)")
  }

  S.msy50 <- max(sapply(profile_list, function(x) median(x[["S.msy"]])))
  n_OYP <- sapply(length(profile_list), function(x) sum(grepl("OYP\\d+", names(profile_list[[x]]))))
  name_alternate <- names(profile_list[[length(profile_list)]])[!(names(profile_list[[length(profile_list)]]) %in% c("s", "OYP90", "SY", "S.msy"))]
  pct_alternate <- gsub("\\D", "", name_alternate)
  n_analyses <- length(profile_list)
  n_goals <- if(new_finding == TRUE & n_analyses == 2){2}else{1}

  if(is.null(limit)){
    xmax <- S.msy50 * 2.25
  }
  else xmax <- limit

  goal_plot<-
    goal_data %>%
    slice_tail(n = n_goals) %>%
    mutate(new_finding = if(n_goals == 1){new_finding}else(c(FALSE, new_finding)))
  goal_plot <- if(n_goals < n_analyses){slice(goal_plot, rep(1, 2))}else{goal_plot}
  goal_plot$profile = names(profile_list)

  cap_width = 85
  cap <-
    case_when(
      max(n_OYP) == 1 ~ stringr::str_wrap("Note: Optimal Yield Profiles (OYP)
               show the probability (under average productivity) of achieving 90%
               of maximum sustained yield (MSY) relative to the number of salmon
               escaped. The probability of achieving 90% of MSY is the standard
               criteria used to describe an escapement goal range.", width = cap_width),
      max(n_OYP) == 2 ~ stringr::str_wrap(paste0(
        "Note: Optimal Yield Profiles (OYP) show the probability (under average
               productivity) of achieving ",
        pct_alternate,
        "% (dashed line) and 90% (solid line) of maximum sustained yield (MSY)
               relative to the number of salmon escaped. The probability of achieving
               90% of MSY is the standard criteria used to describe an escapement goal
               range."), width = cap_width)
    )

  wrap_labels <- function(labels) {
    lapply(labels, function(x) paste(gsub("(.*:)( .*)", "\\1", x),
                                     "\n",
                                     gsub("(.*:)( .*)", "\\2", x)))
  }

  ref_lines0 <-
    goal_plot %>%
    pivot_longer(cols = lb:ub, values_to = "xend") %>%
    rowwise() %>%
    mutate(y90 = profile_list[[profile]][["OYP90"]][which.min(abs(profile_list[[profile]]$s - xend))],
           x = -Inf)

  if(max(n_OYP) == 1){}
  else{
    varname <- paste0("y", pct_alternate)
    ref_lines0 <-
      ref_lines0 %>%
      mutate(!!varname := profile_list[[profile]][[name_alternate]][which.min(abs(profile_list[[profile]]$s - xend))])
  }

  ref_lines <-
    ref_lines0 %>%
    pivot_longer(dplyr::starts_with("y"),
                 values_to = "y",
                 names_to = "max_pct",
                 names_prefix = "y")

  lapply(1:length(profile_list), function(x) mutate(profile_list[[x]], profile = names(profile_list)[x])) %>%
    do.call(rbind, .) %>%
    dplyr::group_by(s) %>%
    dplyr::filter(s <= xmax) %>%
    #tidyr::gather("key", "prob", -s, -S.msy, -SY, - profile, factor_key = TRUE) %>%
    pivot_longer(cols = -c(s, S.msy, SY, profile),names_to  = "key",values_to = "prob") %>%
    #names_transform = list(key = forcats::fct_inorder) # insert in case things break in future
    dplyr::mutate(max_pct = gsub("[A-Z]+([0-9]+)", "\\1", key)) %>%
    dplyr::ungroup() %>%
    ggplot2::ggplot(ggplot2::aes(x = s, y = prob, linetype = profile, linewidth = max_pct)) +
    ggplot2::geom_rect(ggplot2::aes(xmin = lb, xmax = ub, ymin = -Inf, ymax = Inf, fill = new_finding),
                       data = goal_plot,
                       alpha = 0.5,
                       inherit.aes = FALSE) +
    ggplot2::geom_line() +
    ggplot2::geom_segment(aes(x = x, xend = xend, y = y),
                          data = ref_lines,
                          linetype = "11",
                          linewidth = 0.5) +
    ggplot2::facet_grid(profile ~ ., labeller = labeller(.rows = wrap_labels)) +
    #ggplot2::scale_x_continuous(limits = c(0, xmax), labels = scales::comma) +
    ggplot2::scale_y_continuous(breaks = seq(0, 1, 0.2), limits = c(0, 1)) +
    ggplot2::scale_linetype_manual(values = if(n_analyses == 2){c("dashed", "solid")}else("solid")) +
    ggplot2::scale_linewidth_manual(values = if(max(n_OYP) == 2){c(0.5, 1)}else(1)) +
    ggplot2::scale_fill_manual(breaks = c(TRUE, FALSE), values = c("#AB7E4C", "grey80")) +
    ggplot2::labs(
                  title = title,
                  x = "Escapement",
                  y = "Probability",
                  caption = cap) +
    theme_eg() +
    ggplot2::theme(strip.text.x = element_text(hjust = 0.5),
                   strip.text.y = element_text(angle = 0, hjust = 0.5)) +
    {if(labelK==TRUE){
      ggplot2::scale_x_continuous(limits = c(0, xmax),
                                  labels = scales::label_number(scale = 1 / 1e3, big.mark = ",", suffix = "K"))
    }
      else{
        ggplot2::scale_x_continuous(limits = c(0, xmax), labels = scales::comma)
      }}
}

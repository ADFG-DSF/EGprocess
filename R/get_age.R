#' @title Combine or censor extreme ages from Shiny app "Run" data
#' @description Modifies Shiny app run data by either combining or censoring extreme ages form the
#' input dataset. Only necessary if extreme ages were combined or censored in the escapement goal
#' analysis. This function creates a dataframe that can be used by make_brood().
#'
#' @param run_data The original "Run" data used during escapement goal analysis in the Shiny app.
#' @param min_age The minimum age that was considered during escapement goal analysis. Contributions
#' from age classes younger than min_age will be combined with min_age or censored.
#' @param max_age The maximum age that was considered during escapement goal analysis. Contributions
#' from age classes older than max_age will be combined with max_age or censored.
#' @param combine TRUE / FALSE. Flag to indicate whether exteame ages should be combined (TRUE)
#' or censored (FALSE).
#'
#' @returns data frame
#'
#' @examples
#'
#' data_Igushik_combinedages <- get_age(age_data = data_Igushik, min_age = 4, max_age = 7)
#'
#' @export
get_age <- function(run_data, min_age = NA, max_age = NA, combine = TRUE){

  noage <- names(run_data)[!(substr(names(run_data), 1, 1) %in% c('a', 'A'))]
  eage <- names(run_data)[substr(names(run_data), 1, 1) == 'a']
  rage <- names(run_data)[substr(names(run_data), 1, 1) == 'A']

  if(length(eage)>0){
    ac <- data.frame(t(run_data[,eage]))

    # Create European Age  fw.sw
    ac$eage <-as.numeric(substr(rownames(ac), 2, 5))

    # Convert European to Actual Age: freshwater age + seawater age + 1
    ac$age <- round(with(ac, floor(eage) + 10 * (eage-floor(eage))) + 1)

  } else if(length(rage)>0){
    ac <- data.frame(t(run_data[rage]))
    ac$age <- round(as.numeric(substr(rownames(ac), 2, 3)))
  }
  # Combine of eliminate age
  if(isTRUE(combine)){
    ac$age <- with(ac,
                   ifelse(!is.na(min_age) & age < min_age, min_age,
                          ifelse(!is.na(max_age) & age > max_age, max_age, age)
                   )
    )
  } else {
    ac <- ac[which(ac$age >= min_age & ac$age <= max_age),]
  }
  # change NA to 0
  ac[is.na(ac)] <- 0

  # combine age
  t.ac <- aggregate(. ~ age, sum, data = ac[, names(ac) != 'eage'])
  age <- t.ac$age
  t.ac <-data.frame(t(t.ac[,names(t.ac) != 'age']))
  names(t.ac) <- paste0('A',age)
  t.ac <- data.frame(proportions(as.matrix(t.ac),margin=1))

  cbind(run_data[, noage], t.ac)
}

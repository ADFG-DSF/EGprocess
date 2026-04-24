#' @title Create a brood table from Shiny app "Run" data.
#' @description Modifies Shiny app run data by either combining or censoring extreme ages form the
#' input dataset. Only necessary if extreme ages were combined or censored in the escapement goal
#' analysis. This function creates a dataframe that can be used by make_brood().
#'
#' @param run_data The "Run" data used by the shiny app during escapement goal analysis. Modify
#' the "Run" data input into the Shiny appy by make_age() if extreme ages were combined
#' or censored by the Shiny app.
#'
#' @returns data frame
#'
#' @examples
#' get_brood(data = data_Igushik)
#'
#' @export
get_brood <- function(run_data){
  # Extract name of age data (A2, A3, etc)
  A.age <- names(run_data)[substr(names(run_data), 1, 1) == 'A']

  # p determines in age is provided as proportions or numbers
  p <- if(sum(rowSums(run_data[, A.age])) > dim(run_data)[1]){FALSE} else{TRUE}

  # Convert the name to to numeric age
  N.age <- as.numeric(substr(A.age, 2, 2))

  # fage is the first age
  fage <- min(N.age)

  # nages is the number of return ages
  nages <- length(N.age)

  # lage is the last return ages
  lage <- fage + nages-1

  # Calculate maximum brood year range:
  byr <- seq(min(run_data$yr)-lage, max(run_data$yr))

  # Set up brood year matrix
  brood <- matrix(0, ncol = nages+2, nrow = length(byr))

  # First column is year
  brood[, 1] <- byr

  # Second column is Escapement by year
  brood[, 2] <- c(rep(NA, lage), run_data$S)

  # 3rd to the last columns are brood year return by age
  # Age comp data
  if(isTRUE(p)) {run_data[, A.age] <- round(run_data$N * run_data[, A.age], 0)}
  # Case: only 1 age (Pink Salmon)
  if(nages == 1){
    brood[, 3] <- c(rep(NA, lage-fage), run_data[, 3], rep(NA, fage))
  } else {
    for(i in 1:nages){
      brood[, i + 2] <- c(rep(NA, lage-fage + 1 - i), run_data[,i + 3], rep(NA, fage + i - 1))
    }
  }
  brood <- data.frame(brood)
  # Name all columns
  names(brood) <- c('yr', 'S', paste0('b.Age', seq(fage, lage)))
  # Recruit is sum of brood year return by age
  if(nages == 1){
    brood$R <- brood[, -c(1:2)]
  } else {
    brood$R <- rowSums(brood[, -c(1:2)])
  }
  brood
}


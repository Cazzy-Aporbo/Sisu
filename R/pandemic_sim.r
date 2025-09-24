library(dplyr)
library(tibble)
library(readr)

set.seed(42)

populationSize <- 1000
population <- tibble(
  id = 1:populationSize,
  age = sample(1:80, populationSize, replace = TRUE),
  health = runif(populationSize, 0.5, 1),
  immunity = runif(populationSize, 0, 1),
  socialActivity = runif(populationSize, 0, 1),
  infected = FALSE,
  daysInfected = 0,
  recovered = FALSE,
  deceased = FALSE
)

population$infected[1] <- TRUE

virus <- list(
  transmissionRate = 0.05,
  mutationRate = 0.01,
  fatalityRate = 0.005
)

simulateDay <- function(pop, virus) {
  infectedIds <- which(pop$infected & !pop$deceased)
  
  for(i in infectedIds) {
    infector <- pop[i,]
    contacts <- round(infector$socialActivity * 20)
    for(j in 1:contacts) {
      targetIndex <- sample(1:nrow(pop), 1)
      target <- pop[targetIndex,]
      if(!target$infected & !target$deceased) {
        baseChance <- virus$transmissionRate
        immunityFactor <- 1 - target$immunity
        ageFactor <- ifelse(target$age > 65, 1.2, 1.0)
        chance <- baseChance * immunityFactor * ageFactor
        if(runif(1) < chance) {
          pop$infected[targetIndex] <- TRUE
        }
      }
    }
    pop$daysInfected[i] <- pop$daysInfected[i] + 1
    if(runif(1) < virus$fatalityRate * (1 - infector$health)) {
      pop$deceased[i] <- TRUE
      pop$infected[i] <- FALSE
    } else if(pop$daysInfected[i] > 14) {
      pop$recovered[i] <- TRUE
      pop$infected[i] <- FALSE
      pop$immunity[i] <- min(pop$immunity[i] + 0.5, 1)
    }
  }
  return(pop)
}

exportCSV <- function(pop, day) {
  fileName <- paste0("pandemic_day_", day, ".csv")
  write_csv(pop, fileName)
}

days <- 60
for(day in 1:days) {
  population <- simulateDay(population, virus)
  exportCSV(population, day)
  
  infectedCount <- sum(population$infected)
  recoveredCount <- sum(population$recovered)
  deceasedCount <- sum(population$deceased)
  
  cat(sprintf("Day %d: Infected %d, Recovered %d, Deceased %d\n", 
              day, infectedCount, recoveredCount, deceasedCount))
}

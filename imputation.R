library(tidyverse)
library(mice)
library(miceadds)
library(fs)

files <- dir_ls("source_data", type = "file")

preprocess_data <- function(file_path) {
  data <- suppressMessages(read_csv(file_path))
  
  cols <- c(
    "CASEID", "AGE", "ETHNIC", "RACE", "GENDER", "SUB", "LIVARAG", "MARSTAT",
    "SMISED", "TRAUSTREFLG", "ANXIETYFLG", "DEPRESSFLG", "SAP", "NUMMHS"
  )
  
  data <- data |> select(any_of(cols))
  data <- data |> filter(SAP == 1, AGE %in% 4:14, NUMMHS == 3)
  data[data == -9] <- NA
  
  return(data)
}

combined_data <- files |> map_dfr(preprocess_data) |> 
  select(-SAP, -NUMMHS, -CASEID) |> mutate(across(everything(), as.factor))

imputed_data <- mice(combined_data, m = 20, method = 'pmm', seed = 1211)
imputed_list <- mids2datlist(imputed_data)

preprocessed_list <- lapply(imputed_list, function(data) {
  data |>
    mutate(
      Age_18_29 = ifelse(AGE %in% c(4, 5, 6), 1, 0),
      Age_30_39 = ifelse(AGE %in% c(7, 8), 1, 0),
      Age_40_49 = ifelse(AGE %in% c(9, 10), 1, 0),
      Age_50_59 = ifelse(AGE %in% c(11, 12), 1, 0),
      Age_60 = ifelse(AGE %in% c(13, 14), 1, 0)
    ) |> select(-AGE) |>
    
    mutate(Homeless = ifelse(LIVARAG == 1, 1, 0)) |> select(-LIVARAG) |>
    
    mutate(
      Never_Married = ifelse(MARSTAT == 1, 1, 0),
      Married = ifelse(MARSTAT == 2, 1, 0),
      Separated = ifelse(MARSTAT %in% c(3, 4), 1, 0)
    ) |> select(-MARSTAT) |>
    
    mutate(Hispanic = ifelse(ETHNIC %in% c(1, 2, 3), 1, 0)) |> select(-ETHNIC) |>
    
    mutate(
      White = ifelse(RACE == 5, 1, 0),
      Black = ifelse(RACE == 3, 1, 0),
      Race_Other = ifelse(RACE %in% c(1, 2, 4, 6), 1, 0)
    ) |> select(-RACE) |>
    
    mutate(female = ifelse(GENDER == 2, 1, 0)) |> select(-GENDER) |>
    
    mutate(SMI = ifelse(SMISED %in% c(1, 2), 1, 0)) |> select(-SMISED) |>
    
    mutate(
      Alcohol = ifelse(SUB == 4, 1, 0),
      Opioid = ifelse(SUB == 7, 1, 0)
    ) |> select(-SUB) |>
    
    select(
      Homeless, female, Age_18_29, Age_30_39, Age_40_49, Age_50_59,
      Age_60, Never_Married, Married, Separated, Hispanic, White, Black,
      Race_Other, SMI, ANXIETYFLG, DEPRESSFLG, TRAUSTREFLG, Alcohol, Opioid
    )
})

preprocessed_mids <- datlist2mids(preprocessed_list)
saveRDS(preprocessed_mids, "imputedData.RDS")

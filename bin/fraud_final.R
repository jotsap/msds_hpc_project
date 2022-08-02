

### DATA LOAD OPTIMIZATION: PRE-STAGE DATA IN $WORK


# start time
start_load <- Sys.time() #start time

credit.df <- read.csv(
  file = "/work/users/jotsap/hpc_project/hpc_credit.csv",
  #file = "https://jotsapuw2data01.blob.core.windows.net/hpc/hpc_credit.csv",
  header = T
)

# end time
end_load <- Sys.time() #end time

# results
print(paste0("Processing time for loading data is ", end_load - start_load))
print(start_load)
print(end_load)


### DATA PROCESS

library(magrittr)
library(dplyr)


# START TIME
start_proc <- Sys.time() #start time


# isFlaggedFraud not necessary for analysis
credit.df %>% select(-isFlaggedFraud) -> creditclean.df


# nameDest and nameOrig NOT found to be significant to any modeling
creditclean.df %>% select(-nameDest) -> creditclean.df
creditclean.df %>% select(-nameOrig) -> creditclean.df

### convert nameOrig and nameDest from factor to character
# as.character( creditclean.df$nameOrig ) -> creditclean.df$nameOrig
# as.character( creditclean.df$nameDest ) -> creditclean.df$nameDest

### convert type to factor
as.factor( creditclean.df$type) -> creditclean.df$type

### Convert isFraud Response to factor "Yes" or "No"

# recode 1 as "Yes" and 0 as "No"
dplyr::recode_factor(
  creditclean.df$isFraud, 
  `1` = "Yes", `0` = "No"
) -> creditclean.df$isFraud


### Create transaction amount categories
cut(
  creditclean.df$amount,
  breaks = c(0,1000,10000,50000,100000,250000,500000,99999999),
  labels = c("under_1k","1k_to_10k","10k_to_50k","50k_to_100k","100k_to_250k","250k_to_500k","over_500k"),
  include.lowest = T
) -> creditclean.df$amountCat


# remove amount numerical to keep categorical
creditclean.df %>% select(-amount) -> creditclean.df


### Time of Day Category

# Convert Step to Hours in 24 hours format
# NOTE: 1 step is 1 hour
creditclean.df$hour <- mod(credit.df$step, 24)

# make categories
cut(
  creditclean.df$hour,
  breaks = c(0,8,16,24),
  labels = c("night","day","evening"),
  include.lowest = T
) -> creditclean.df$timeOfDay


# remove numerical step and hour
creditclean.df %>% select(-step) -> creditclean.df
creditclean.df %>% select(-hour) -> creditclean.df

# balance info was found to not be helpful or significant features
creditclean.df %>% select(-oldbalanceOrg) -> creditclean.df
creditclean.df %>% select(-oldbalanceDest) -> creditclean.df
creditclean.df %>% select(-newbalanceOrig) -> creditclean.df
creditclean.df %>% select(-newbalanceDest) -> creditclean.df


# END TIME
end_proc <- Sys.time() #end time

# RESULTS
print(paste0("Processing time is ", end_proc - start_proc))
print(start_proc)
print(end_proc)



### RANDOM FOREST DATA MODEL
library(caret)
library(e1071)
library(randomForest) 



# creating the Train / Test data partition 
fraud_split <- createDataPartition(creditclean.df$isFraud, p = 0.9, list = F)
# including 80 for training set
fraud_train.df <- creditclean.df[fraud_split,] 
# excluding 80 for testing set
fraud_test.df <- creditclean.df[-fraud_split,]



################
###  RANGER  ###
################

library(ranger)
library(parallel)



# training RF model using ranger
start_rf_ranger <- Sys.time() #start time


# training grid
trainControl(
  method = "cv",
  number = 5,
  savePredictions = "final", 
  classProbs = F,
  verboseIter = T,
  allowParallel = T,
  #sampling = "down",
  search = "random"
) -> ranger_control.grid

# tuning grid
ranger_tune.grid <- expand.grid( 
  mtry = c(3,4,5), 
  min.node.size = 1,
  splitrule = "extratrees" 
)


# training RF model
train(
  isFraud ~ type + amountCat + timeOfDay,
  data = fraud_test.df,
  method = "ranger",
  trControl = ranger_control.grid, 
  num.threads = 6,
  tuneGrid = ranger_tune.grid,
  importance = 'impurity', #'impurity', 'permutation'
  metric = "Accuracy" 
) -> fraud_train.ranger

# end time
end_rf_ranger <- Sys.time() #end time

print(paste0("Calculation time in minutes ",(as.numeric(end_rf_ranger) - as.numeric(start_rf_ranger))/60  ))






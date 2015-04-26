# One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
#   
#   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# 
# Here are the data for the project:
#   
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# 
# You should create one R script called run_analysis.R that does the following. 
# 
# 1 Merges the training and the test sets to create one data set.
# 2 Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3 Uses descriptive activity names to name the activities in the data set
# 4 Appropriately labels the data set with descriptive variable names. 
# # 5 From the data set in step 4, creates a second, independent tidy data set with the average of 
#       each variable for each activity and each subject.
# 
# Good luck!
#
############################################################################################################

## add libraries
  library(dplyr)
  library(reshape2)


## Set working directory
  setwd("C:/Users/Justin/Google Drive/Coursera/3. Getting and Cleaning Data/Project/1")

##download file
  ## create directory
  if (!file.exists("data")) {
      dir.create("data")
  }

  ## download file
  fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileurl, destfile = "./data/wearables.zip", mode = "wb")

  ## unzip file
  unzip(zipfile = "./data/wearables.zip",overwrite = TRUE,exdir = "./data")

## load datasets
  ## load features
  features <- read.table(file = "./data/UCI HAR Dataset/features.txt")

  ## x_train and x_test
  x_train <- read.table(file = "./data/UCI HAR Dataset/train/X_train.txt")
  x_test <- read.table(file = "./data/UCI HAR Dataset/test/X_test.txt")  

  ## y_train and y_test
  y_train <- read.table(file = "./data/UCI HAR Dataset/train/y_train.txt")
  y_test <- read.table(file = "./data/UCI HAR Dataset/test/y_test.txt")

  ## subject_train and subject_test
  subject_train <- read.table(file = "./data/UCI HAR Dataset/train/subject_train.txt")
  subject_test  <- read.table(file = "./data/UCI HAR Dataset/test/subject_test.txt")

  ## activity_labels
  activity_labels <- read.table(file = "./data/UCI HAR Dataset/activity_labels.txt")

## merge train and test datasets
  ## clean features dataset, remove illegal characters
  features[,2] <- gsub("\\(","",features[,2],ignore.case = TRUE, )
  features[,2] <- gsub("\\)","",features[,2],ignore.case = TRUE, )
  features[,2] <- gsub("-",".",features[,2],ignore.case = TRUE, )
  
  ## fix body body
  features[,2] <- gsub("BodyBody","Body",features[,2])

  ## replace f, t, and acc
  features[,2] <- gsub("Acc","Accel",features[,2])
  features[,2] <-  paste0(gsub("f", "freq", substring(features[,2],1,1)), substring(features[,2],2,100))
  features[,2] <-  paste0(gsub("t", "time", substring(features[,2],1,1)), substring(features[,2],2,100))

  ## add column names to x_train and x_test
  names(x_train) = features[,2]
  names(x_test)  = features[,2]

  ## rename label columns
  names(y_train) = "label"
  names(y_test)  = "label"

  ## rename subject columns
  names(subject_train) = "subject"
  names(subject_test)  = "subject"

  ## merge x_train and y_train | x_test and y_test
  train <- cbind(y_train, x_train)
  test  <- cbind(y_test, x_test)

  ## merge x_train and subject_train | x_test and subject_test
  train <- cbind(subject_train, train)
  test  <- cbind(subject_test, test)

  ## add type column to train and test
  train$type = 'train'
  test$type  = 'test'

  ## merge both datasets into the combined dataset
  combined <- rbind(train, test)

  ## add activity name
  combined2 <- merge(activity_labels, combined, by.x = "V1", by.y = "label")

  ## rename columns
  names(combined2)[1] = "activity_label"
  names(combined2)[2] = "activity_name"
  
  ## subset to only include activities, subjects, and variables with mean and std dev
  combined3 <- cbind(combined2[,1:3], combined2[  , grep("mean", names(combined2))], 
                 combined2[  , grep("std", names(combined2))])

## melt and cast
  ##melt
  combomelt <- melt(combined3, id = names(combined3)[1:3], measure.vars = names(combined3)[4:82])
  
  ##cast
  combocast <- dcast(combomelt, activity_name + subject  ~ variable, mean)
  
  #arrange
  combocast <- arrange(combocast, activity_name, subject)

## Export Tidy Dataset
  write.table(combocast, file = "smartphone_activity.txt", row.name = FALSE)
  

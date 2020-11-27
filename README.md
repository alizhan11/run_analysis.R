# run_analysis.R
# Given conditions for the script
1.Merges the training and the test sets to create one data set.

2.Extracts only the measurements on the mean and standard deviation for each measurement.

3.Uses descriptive activity names to name the activities in the data set

4.Appropriately labels the data set with descriptive variable names.

5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


# First download the data from the Web and unpack the dataset

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

path <- getwd()

download.file(url, file.path(path, "dataFile.zip"), method = "curl")

unzip('dataFile.zip')


# and then choose the packages which will be used

library(data.table)

library(reshape2)

# Set names and clean the data by creating these variables 

activityLabels <- data.table::fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                                
                                 , col.names = c('classLabels', 'activityName'))

features <- data.table::fread(file.path(path, "UCI HAR Dataset/features.txt")

                                , col.names = c('index', 'featureNames'))

featuresNeed <- grep("(mean|std)\\(\\)", features[, featureNames])

measurement <- features[featuresNeed, featureNames]

measurement <- gsub('[()]', '', measurement)

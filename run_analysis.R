# Getting and Cleaning Data Course Project
# Author: Alizhan Tapeyev


# Getting data

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
path <- getwd()
download.file(url, file.path(path, "dataFile.zip"), method = "curl")
unzip('dataFile.zip')

## Loading activity labels and features

activityLabels <- data.table::fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                                , col.names = c('classLabels', 'activityName'))
features <- data.table::fread(file.path(path, "UCI HAR Dataset/features.txt")
                                , col.names = c('index', 'featureNames'))
featuresNeed <- grep("(mean|std)\\(\\)", features[, featureNames])
measurement <- features[featuresNeed, featureNames]
measurement <- gsub('[()]', '', measurement)

## Loading training datasets

train <- data.table::fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[,featuresNeed, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- data.table::fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                                , col.names = c("Activity"))
trainSubjects <- data.table::fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                                , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities,train)

## Loading test datasets

test <- data.table::fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[,featuresNeed, with = FALSE]
data.table::setnames(test, colnames(test), measurement)
testActivities <- data.table::fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                                    , col.names = c('Activity'))
testSubjects <- data.table::fread( file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                                   , col.names = c('SubjectNum'))
test <- cbind(testSubjects, testActivities, test)

## Merging datasets 

combine <- rbind(train, test)

## Converting classLabels to activityName

combine[['Activity']] <- factor(combine[, Activity]
                                , levels = activityLabels[["classLabels"]]
                                , labels = activityLabels[['activityName']]
)
combine[['SubjectNum']] <- as.factor(combine[,SubjectNum])
combine <- reshape2::melt(data = combine, id = c('SubjectNum', 'Activity'))
combine <- reshape2::dcast(data = combine, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combine, file = 'tidyData.txt', quote = FALSE)

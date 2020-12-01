# run_analysis.R
# Given conditions for the project

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

# Set the column names for the measurement and clean the data by creating these variables for activities and features
  
     activityLabels <- data.table::fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")                           
                                 , col.names = c('classLabels', 'activityName'))
    features <- data.table::fread(file.path(path, "UCI HAR Dataset/features.txt")
                                , col.names = c('index', 'featureNames'))
    featuresNeed <- grep("(mean|std)\\(\\)", features[, featureNames])
    measurement <- features[featuresNeed, featureNames]
    measurement <- gsub('[()]', '', measurement)

# Load the train dataset and bind the columns 
    train <- data.table::fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[,featuresNeed, with = FALSE]
    data.table::setnames(train, colnames(train), measurements)
    trainActivities <- data.table::fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                                , col.names = c("Activity"))
    trainSubjects <- data.table::fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                                , col.names = c("SubjectNum"))
    train <- cbind(trainSubjects, trainActivities,train)

# Load the test dataset and bind the columns

    test <- data.table::fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[,featuresNeed, with = FALSE]
    data.table::setnames(test, colnames(test), measurement)
    testActivities <- data.table::fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                                    , col.names = c('Activity'))
    testSubjects <- data.table::fread( file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                                   , col.names = c('SubjectNum'))
    test <- cbind(testSubjects, testActivities, test)

# Merge the train and test variables by rows

    combine <- rbind(train, test)
    
# Convert the classLabels to activityName
    combine[['Activity']] <- factor(combine[, Activity]
                                , levels = activityLabels[["classLabels"]]
                                , labels = activityLabels[['activityName']]
    )

# Reshape the variable 
    combine <- reshape2::melt(data = combine, id = c('SubjectNum', 'Activity'))
    combine <- reshape2::dcast(data = combine, SubjectNum + Activity ~ variable, fun.aggregate = mean)

# Save the result as ".txt" file
    data.table::fwrite(x = combine, file = 'tidyData.txt', quote = FALSE)

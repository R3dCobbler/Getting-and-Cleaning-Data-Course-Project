## run_analysis.R

# This script is designed to do the following:

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

##################################################################################################################


# Download and unzip the data

if(!file.exists("./course_project_data")){dir.create("./course_project_data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./course_project_data/Dataset.zip",method="curl")

unzip(zipfile="./course_project_data/Dataset.zip",exdir="./course_project_data")

# Get the files contained in the "UCI HAR Dataset" folder

getpath <- file.path("./course_project_data" , "UCI HAR Dataset")
files<-list.files(getpath, recursive=TRUE)
files

# Load libraries

library(plyr)
library(dplyr)
library(data.table)

# Read test data

featuresTest <- read.table(file.path(getpath, "test", "X_test.txt"), header = FALSE)
subjectTest <- read.table(file.path(getpath, "test", "subject_test.txt"), header = FALSE)
activityTest  <- read.table(file.path(getpath, "test" , "Y_test.txt" ), header = FALSE)

# Read training data 

featuresTrain <- read.table(file.path(getpath, "train", "X_train.txt"),header = FALSE)
subjectTrain <- read.table(file.path(getpath, "train", "subject_train.txt"), header = FALSE)
activityTrain <- read.table(file.path(getpath, "train", "Y_train.txt"), header = FALSE)

# Read names of features and activities

featuresNames <- read.table(file.path(getpath, "features.txt"))
activityLabels <- read.table(file.path(getpath, "activity_labels.txt"), header = FALSE)

# Check the structure of these new variables

str(featuresTest)
str(subjectTest)
str(activityTest)
str(featuresTrain)
str(subjectTrain)
str(activityTrain)
str(featuresNames)
str(activityLabels)

# Step 1. Merge the training and the test sets to create one data set.

# Clip data together in each set in relation to key variables

features <- rbind(featuresTrain, featuresTest)
subject <- rbind(subjectTest, subjectTrain)
activity <- rbind(activityTest, activityTrain)

# Check properties

head(features)
head(subject)
head(activity)

# Rename the columns 

colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
colnames(features) <- featuresNames$V2

# Merge all 3 datasets

tandtData <- cbind(features, subject, activity)

# Check new data frame
# The UCI HAR Dataset contained 10299 instances with 561 attributes.
# By adding the Subject and Activity variables there should now be 563 variables.
# Check.

str(tandtData)


# Step 2. Extract only the measurements on the mean and standard deviation for each measurement.

# Identify the columns containing MEAN or STD values

meanSTD <- grep(".*mean.*|.*std*", names(tandtData), ignore.case = TRUE)

# Include the "Subject" and "Activity" columns which are the last 2 columns in the "tandtData" data frame 

meanStdcols <- c(meanSTD, 562, 563)

# Create the meanStdData dat frame containing the complete data set but only including the required mean and standard deviation values

meanStdData <- tandtData[,meanStdcols]

# Check new dataframe

str(meanStdData)


# Step 3. Use descriptive activity names to name the activities in the data set

head(meanStdData$Activity)

# Convert the Activity Column to a character variable
# Use the "activityLabels" variable to name the activities

meanStdData$Activity <- as.character(meanStdData$Activity)

for(i in 1:6)
{meanStdData$Activity [meanStdData$Activity== i] <- as.character(activityLabels[i,2])}

# Check column now contains descriptive activity names

head(meanStdData$Activity)

# Step 4. Appropriately label the data set with descriptive variable names.

# Examine the existing label names in the data frame

names(meanStdData)

# The characters and terms which need to be replaced are:
# "t", "f", "Acc", "Gyro", "Mag", and "BodyBody".

names(meanStdData) <- gsub("^t", "Time", names(meanStdData))
names(meanStdData) <- gsub("^f", "Frequency", names(meanStdData))
names(meanStdData) <- gsub("Acc", "Accelerometer", names(meanStdData))
names(meanStdData) <- gsub("Gyro", "Gyroscope", names(meanStdData))
names(meanStdData) <- gsub("Mag", "Magnitude", names(meanStdData))
names(meanStdData) <- gsub("BodyBody", "Body", names(meanStdData))

# To keep consistency, capitalise the variables containing "angle", "gravity", "mean" and "std"

names(meanStdData) <- gsub("angle", "Angle", names(meanStdData))
names(meanStdData) <- gsub("gravity", "Gravity", names(meanStdData))
names(meanStdData) <- gsub("mean", "Mean", names(meanStdData))
names(meanStdData) <- gsub("std", "STD", names(meanStdData))

# Check new naming of variables

names(meanStdData)


# Step 5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

# Set Subject as a factor variable as it relates to the people who volunteered for the recordings.

meanStdData$Subject <- as.factor(meanStdData$Subject)
meanStdData <- data.table(meanStdData)

# Create tidyDataAvg data set, ordered by subject then activity

tidyDataAvg <- aggregate(. ~Subject + Activity, meanStdData, mean)
tidyDataAvg <- tidyDataAvg[order(tidyDataAvg$Subject,tidyDataAvg$Activity),]
write.table(tidyDataAvg, file = "TidyDataAvg.txt", row.names = FALSE)

# End of document




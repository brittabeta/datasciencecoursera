# Getting and Cleaning Data Project John Hopkins Coursera
# Student: Britta

# 1. Load Packages and get the Data
# 2. Use descriptive activity names to name the activities in the data set
## Load activity labels + features to appropriately label the combined data
## Extract only measurements on the mean and standard deviation for each measurement
# 3. Load train datasets
# 4. Load test datasets
# 5. Merge datasets
# 6. Appropriately label the data set with descriptive variable names
## Convert classLabels to activityName
# 7. Create a second, independent tidy data set with the average of each variable for each activity and each subject

# Load Packages and get the Data
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

# Use descriptive activity names to name the activities in the data set
# Load activity labels + features to appropriately label the combined data
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
# Extract only measurements on the mean and standard deviation for each measurement
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

# Load train datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                       , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

# Load test datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# Merge datasets
combined <- rbind(train, test)

# Appropriately label the data set with descriptive variable names
# Convert classLabels to activityName  
combined[["Activity"]] <- factor(combined[, Activity]
                              , levels = activityLabels[["classLabels"]]
                              , labels = activityLabels[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))

# Create a second, independent tidy data set with the average of each variable for each activity and each subject
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)
data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
# also create a .csv
data.table::fwrite(x = combined, file = "tidyData.csv", quote = FALSE)

# Credits: Michael Galarnyk

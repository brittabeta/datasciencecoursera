# Getting and Cleaning Data Project | R Programming Project 3

Student: Britta <br />

### Data: data collected from the accelerometers from the Samsung Galaxy S smartphone
* [Data Zip File Location](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "Clicking will download the data")
* [Data description](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

### Project Outline
1. Load Packages and get the Data
2. Use descriptive activity names to name the activities in the data set
a. Load activity labels + features to appropriately label the combined data
b. Extract only measurements on the mean and standard deviation for each measurement
3. Load train datasets
4. Load test datasets
5. Merge datasets
6. Appropriately label the data set with descriptive variable names
a. Convert classLabels to activityName
7. Create a second, independent tidy data set with the average of each variable for each activity and each subject

### 1. Load Packages and get the Data
```R
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")
```

### 2. Use descriptive activity names to name the activities in the data set
```R
# Load activity labels + features to appropriately label the combined data
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
# Extract only measurements on the mean and standard deviation for each measurement
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)
```

### 3. Load train datasets
```R
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                       , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)
```

### 4. Load test datasets
```R
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)
```

### 5. Merge datasets
```R
combined <- rbind(train, test)
```

### 6. Appropriately label the data set with descriptive variable names
```R
# Convert classLabels to activityName
combined[["Activity"]] <- factor(combined[, Activity]
                              , levels = activityLabels[["classLabels"]]
                              , labels = activityLabels[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))

combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
```

### 7. Create a second, independent tidy data set with the average of each variable for each activity and each subject
```R
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)
data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
```

#### Contributors
Michael Galarnyk <mgalarny@gmail.com>

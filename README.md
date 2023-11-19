## Getting and Cleaning Data Project
## R Programming Project 3

Student: Britta <br />

# Data Zip File Location
[UC Irvine Repo](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "Clicking will download the data")

# Project Outline
1. Load Packages and get the Data
2. Load activity labels + features
3. Load train datasets
4. Load test datasets
5. Merge datasets
6. Convert classLabels to activityName

### 1. Load Packages and get the Data
```R
# install.packages("data.table")
library("data.table")

# Reading in data
outcome <- data.table::fread('outcome-of-care-measures.csv')
outcome[, (11) := lapply(.SD, as.numeric), .SDcols = (11)]
outcome[, lapply(.SD
                 , hist
                 , xlab= "Deaths"
                 , main = "Hospital 30-Day Death (Mortality) Rates from Heart Attack"
                 , col="lightblue")
        , .SDcols = (11)]
```

### 2. Load activity labels + features
```R
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
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

### 6. Convert classLabels to activityName
```R
combined[["Activity"]] <- factor(combined[, Activity]
                              , levels = activityLabels[["classLabels"]]
                              , labels = activityLabels[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
```

## Goal of the Project
1. A tidy data set 
2. A link to a Github repository with your script for performing the analysis 
3. A code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.
4. Analysis R Script

## Review Criteria

Goal | Item | Link to Item
--- | --- | ---
Analysis R Script |  run_analysis.R |  [R Script Link](https://github.com/mGalarnyk/datasciencecoursera/blob/master/3_Getting_and_Cleaning_Data/projects/run_analysis.R "run_analysis.R")
Tidy Data Set |  Clean Data Set |  [Data Set Link](https://github.com/mGalarnyk/datasciencecoursera/blob/master/3_Getting_and_Cleaning_Data/data/tidyData.txt "tidyData.txt")
Github Repo | Repo |  [Repo Link](https://github.com/mGalarnyk/datasciencecoursera/tree/master/3_Getting_and_Cleaning_Data "Click to go to Repo")
Cookbook | CodeBook.md |  [Repo Link](https://github.com/mGalarnyk/datasciencecoursera/blob/master/3_Getting_and_Cleaning_Data/projects/CodeBook.md "CodeBook.md")
README | ReadingItNow |  [Repo Link](https://github.com/mGalarnyk/datasciencecoursera/blob/master/3_Getting_and_Cleaning_Data/projects/README.md "README.md")

## Contributors

FirstName | LastName | Email
--- | --- | ---
Michael |  Galarnyk |  <mgalarny@gmail.com>
Britta |  S. | <bretana1226@gmail.com>

## License

Anyone may contribute after this assignment is turned in and graded. 

## Blog Posts on the Specialization | John Hopkins Coursera

[Getting and Cleaning Data (JHU Coursera)](https://medium.com/@GalarnykMichael/getting-and-cleaning-data-jhu-coursera-course-3-c3635747858b#.y93kqfa0u "Review + data.table")

[R Programming (JHU Coursera)](https://medium.com/@GalarnykMichael/in-progress-review-course-2-r-programming-jhu-coursera-ad27086d8438#.bzzr29fvo "Review + data.table")

[The Data Scientist’s Toolbox (JHU Coursera)](https://medium.com/@GalarnykMichael/review-course-1-the-data-scientists-toolbox-jhu-coursera-4d7459458821#.5jpg133ln "Review + Going over Parts of Quiz")

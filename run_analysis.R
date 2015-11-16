## Author: Csaba Sarkadi
## Course: Coursera -- Getting and cleaning data
## Course code: getdata-034
##
##
## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Step 0. We need to check and install necessary R packages
if (!require("data.table")) {
    install.packages("data.table")
}

if (!require("reshape2")) {
    install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Step 1. We need to load the necessary dictionary files into local variables
# These are: 1. Activity labels, 2. Features list
activityLabelsList <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
# The feature list contains the column names of the available data from the different sensors
featuresList <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Step 2. We need to gather the names of columns for the measurements 
# on the mean and standard deviations.
reqFeatures <- grepl("mean|std", featuresList)

# Step 3. Load and process X_test & y_test & subject test data.
xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subjecttest <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# Assign the column names for the data table
names(xtest) = featuresList

# Step 4. Subset the measurements of the means and standard deviations for each measurement.
xtest = xtest[,reqFeatures]

# Load labels for the y test table
ytest[,2] = activityLabelsList[ytest[,1]]
names(ytest) = c("Activity_ID", "Activity_Label")
names(subjecttest) = "subject"

# Step 5. Bind the the data tables: xtest, ytest and subjects into a new data table
testData <- cbind(as.data.table(subjecttest), ytest, xtest)

# Step 6. Load and process x train & y & subject training data.
xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subjecttrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Assign the column names for the data table
names(xtrain) = featuresList

# Step 7. Subset the measurements of the means and standard deviations for each measurement 
# within the x training set
xtrain = xtrain[,reqFeatures]

# Load training data on y 
ytrain[,2] = activityLabelsList[ytrain[,1]]
names(ytrain) = c("Activity_ID", "Activity_Label")
names(subjecttrain) = "subject"

# Step 8. Bind the the data tables: xtrain, ytrain and subjects train into a new data table
trainData <- cbind(as.data.table(subjecttrain), ytrain, xtrain)

# Step 9. Now we have gathered all the necessary data,
# so we need to merge the train and test ones
mergeData = rbind(testData, trainData)

idLabels   = c("subject", "Activity_ID", "Activity_Label")
dataLabels = setdiff(colnames(mergeData), idLabels)
meltData   = melt(mergeData, id = idLabels, measure.vars = dataLabels)

# Step 10. Finally, we use dcast function to calculate the mean on the available dataset
tidyData   = dcast(meltData, subject + Activity_Label ~ variable, mean)

write.table(tidyData, file = "./tidy_data.txt", row.name = FALSE)
#You should create one R script called run_analysis.R that does the following.

#1.Merges the training and the test sets to create one data set.
#2.Extracts only the measurements on the mean and standard deviation for each measurement.
#3.Uses descriptive activity names to name the activities in the data set
#4.Appropriately labels the data set with descriptive variable names.
#From the data set in step 4, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject.


# the data are obtained from the following url
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# create a destination for the zip file
if(!file.exists("./dataset.zip")){dir.create("./dataset.zip")}

# download the data to a destination dataset.zip
download.file(url, destfile="./dataset.zip", method="libcurl")

# create a file myZip to load unzipped files from dataset.zip
if(!file.exists("./myZip")){dir.create("./myZip")}

# unzip the data and load list the files
filesList <- unzip(zipfile="./Dataset.zip",exdir="./myZip")


# read different files to see the content
activity_labels <- read.table("./myZip/UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("./myZip/UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

#Extract only the measurements on the mean and standard deviation for each measurement
features_Required <- grep(".*mean.*|.*std.*", features[,2])

#Appropriately label the data set with descriptive variable names
features_Required.names <- features[features_Required,2]
features_Required.names = gsub('-mean', 'Mean', features_Required.names)
features_Required.names = gsub('-std', 'Std', features_Required.names)
features_Required.names <- gsub('[-()]', '', features_Required.names)

# Load the datasets
train <- read.table("./myZip/UCI HAR Dataset/train/X_train.txt")[features_Required]
trainActivities <- read.table("./myZip/UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("./myZip/UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("./myZip/UCI HAR Dataset/test/X_test.txt")[features_Required]
testActivities <- read.table("./myZip/UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("./myZip/UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", features_Required.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activity_labels[,1], labels = activity_labels[,2])
allData$subject <- as.factor(allData$subject)

require(reshape2)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

head(allData.mean)





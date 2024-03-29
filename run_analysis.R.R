library(data.table)
library(dplyr)

path <- getwd()

url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
zip <- 'dataset.zip'
if(!file.exists(zip)){
        download.file(url,zip)
}
dataset <- 'uci har dataset'
if(!file.exists(dataset)){
        unzip(zip)
}



#read subjects and name columns
features <- read.table("UCI HAR Dataset/features.txt",col.names = c("n","function"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$function.)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$function.)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names="code")


#merge training and test sets
x <- rbind(x_train,x_test)
y <- rbind(y_train,y_test)
subject <- rbind(subject_train,subject_test)
mergedata <- cbind(subject,y,x)
View(mergedata)
dim(mergedata)
names(mergedata)

#extract measurements (mean&std)
tidydata <- mergedata %>% select(subject,code,contains("mean"),contains("std"))

#use activity name to tidydata acitivities
tidydata$code <- activities[tidydata$code,2]
View(tidydata)

#clean column names
names(tidydata)[2] = "activity"
names(tidydata)<-gsub("Acc", "Accelerometer", names(tidydata))
names(tidydata)<-gsub("Gyro", "Gyroscope", names(tidydata))
names(tidydata)<-gsub("Mag", "Magnitude", names(tidydata))
names(tidydata)<-gsub("^t", "Time", names(tidydata))
names(tidydata)<-gsub("^f", "Frequency", names(tidydata))
names(tidydata)<-gsub("tBody", "TimeBody", names(tidydata))
names(tidydata)<-gsub("-mean()", "Mean", names(tidydata), ignore.case = TRUE)
names(tidydata)<-gsub("-std()", "Standarddeviation", names(tidydata), ignore.case = TRUE)
names(tidydata)<-gsub("-freq()", "Frequency", names(tidydata), ignore.case = TRUE)
names(tidydata)<-gsub("angle", "Angle", names(tidydata))
names(tidydata)<-gsub("gravity", "Gravity", names(tidydata))

#final data
finaldata <- tidydata %>%group_by(subject,activity) %>% summarise_all(funs(mean)) 
View(finaldata)
write.table(finaldata,"finaldata.txt",row.names = FALSE)
dim(finaldata)

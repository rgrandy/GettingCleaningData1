## THE PURPOSE OF THIS SCRIPT, RUN_ANALYSIS.R IS TO COMPLETE THE FOLLOWING TASKS
## FOR THE GETTING AND CLEANING DATA COURSERA R CLASS
##  1.  Merges the training and the test sets to create one data set.
##  2.  Extracts only the measurements on the mean and standard deviation for each measurement. 
##  3.  Uses descriptive activity names to name the activities in the data set
##  4.  Appropriately labels the data set with descriptive variable names. 
##  5.  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Step #0:  Setup working directory, load dplyr and set up a very handy function
##           that we will use later for propercase (found from a google search)
setwd("C:\\users\\Rose\\Documents\\Coursera\\CleanData2")
library(dplyr)
topropper <- function(x) {
  sapply(x, function(strn)
  { s <- strsplit(strn, "\\s")[[1]]
  paste0(toupper(substring(s, 1,1)), 
         tolower(substring(s, 2)),
         collapse=" ")}, USE.NAMES=FALSE)
}


##  Step 1:  Load the features.  We will do this first as these will be
##           column names when we get to reading in the X data.
##           After reading in the TXT file with read.table, first we will
##           identify those columns we intend to ultimately keep (some do not fit
##           the criteria of MEAN or STD).  Note meanfreq and gravitymean and other
##           term variations are not going to be included.  We strictly want
##           those cases that are mean and std.
##           Once we have our list of fields to keep, we will do some clean up
##           on the terms themselves to make them more useful as column names
##           (removing or converting characters and then make lower case)
features <-read.table("./data/features.txt",stringsAsFactors = FALSE)

FeaturesWeWant <- grep("mean\\(\\)|std\\(\\)", features[, 2])
## Check as to how many we should expect.  Visual inspection indicated 66
table(grepl("mean\\(\\)|std\\(\\)", features[, 2]))

features$V2 <- gsub("\\(", "",features$V2) 
features$V2 <- gsub("\\)", "",features$V2) 
features$V2 <- gsub("\\,", ".",features$V2) 
features$V2 <- gsub("\\-", ".",features$V2) 
features$V2 <-tolower(features$V2)

##  Step 2.  Read in the training and test data for X, using features data
##          as column names.  Then join the train and test data together to make
##          joinX and only keep those columns that meet the criteria for this project
XtrainData <- read.table("./data/train/X_train.txt",col.names=features[,2],
                        stringsAsFactors = FALSE)
XtestData <- read.table("./data/test/X_test.txt",col.names=features[,2],
                       stringsAsFactors = FALSE)
joinX <- rbind(XtrainData, XtestData)
joinX <-joinX[,FeaturesWeWant]
## A little clean up of files we are done with
rm(XtrainData)
rm(XtestData)
rm(features)
rm(FeaturesWeWant)

##  Step 3:  Read in the subect data for train and test and join together
##           These files have one column which indicates subject (1-30)
##           There are 10299 records when combined which matches the joinX data
trainSubject <- read.table("./data/train/subject_train.txt",col.names="subject",
                           stringsAsFactors = FALSE)
testSubject <- read.table("./data/test/subject_test.txt",col.names="subject",
                          stringsAsFactors = FALSE)
joinSubject <- rbind(trainSubject, testSubject)
## Clean up files we are done with
rm(trainSubject)
rm(testSubject)

##  Step 4:  Read in the Y data for train and test and join together
##           These files have one column which indicates activity # (1-6)
##           There are 10299 records when combined which matches the joinX and
##           joinSubject data
YtrainData <- read.table("./data/train/y_train.txt",col.names="key",
                         stringsAsFactors = FALSE)
YtestData <- read.table("./data/test/y_test.txt",col.names="key",
                        stringsAsFactors = FALSE) 
joinY <- rbind(YtrainData, YtestData)
## Clean up files we are done with
rm(YtrainData)
rm(YtestData)

##   Step 5:  Join the columns from joinX, joinY and joinSubject
##            There is an underlying assumption that when joined train+test as
##            Done for each of these above, that the ordering is appropriate
##            and a simple cbind is sufficient to pull them together.  There
##            are no key fields by which to merge
alldata <-cbind(joinSubject,joinY,joinX)

##   Step 6:  Merge in the descriptive activity names to alldata by
##            reading in activity_labels.txt which contains a key (to match the key
##            from joinY) and the activity name
##            Do a minor amount of clean up on the names themselves - convert
##            underscores to spaces and use proper case
activitynames <- read.table("./data/activity_labels.txt",
                            col.names = c("key","activityname"),
                             stringsAsFactors = FALSE)

activitynames$activityname <- gsub("_", " ",activitynames$activityname)
activitynames$activityname <- topropper(activitynames$activityname)
## activitynames$activityname

##   Step 7:  Merge in the activitynames with alldata so the descriptive names
##            are in alldata
alldata <-arrange(alldata,key)
activitynames <-arrange(activitynames,key)
alldata <- merge(alldata,activitynames,all=TRUE)

##  Step 8:  Make a tidy dataset.  We will use summarise_each to get the 
##           Mean values grouped by subject, key and activityname.
##           Then we can drop key. We don't really need it
alldata <-arrange(alldata,subject,key,activityname)
tidydata <- alldata %>%  group_by(subject,key,activityname) %>% summarise_each(funs(mean))
tidydata$key <-NULL

##  Step 9:  Use write.table to make a final txt file of the tidydata
write.table(tidydata,"final_tidydata.txt",row.names = FALSE)
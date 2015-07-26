run_analysis.R
=================================

This codebook describes the data used for the program run_anlaysis.R.

This program was written to fulfill the peer project requirement for the coursera.org course "Getting and Cleaning Data".

The project description, as provided in coursera.org is as follows:

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected. 

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

 You should create one R script called run_analysis.R that does the following. 

  Merges the training and the test sets to create one data set.
  Extracts only the measurements on the mean and standard deviation for each measurement. 
  Uses descriptive activity names to name the activities in the data set
  Appropriately labels the data set with descriptive variable names. 
  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.



## Brief description of the data
The experiment from which this data was derived included 30 subjects ages 19-48. Each subject performed 6 activities wearing a Samsung Galaxy S II smartphone.  Measurements from the smartphone's embedded accelerometer and gyroscope were taken.  There are 561 measurements included in this experiment, for each of 30 subjects and 6 activities.  There are multiple observations per subject/activity in the raw dataset. 

This program, run_analysis.R, takes the data files from this project as provided in the zip file https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip and creates a tidy dataset, ready for further analysis.


### Input data files and structure

After the WD (working directory) is set by the program, the following data structure is assumed

  ./data
    contains the files "features.txt" and "activity_labels.txt"

  as well as "features_info.txt " which contains more information about the features but is not a dataset and "readme.txt" which contains additional details about the experiment but is also not a dataset.
    
    
  ./data/train
    contains the files 
      *"subject_train.txt"* file which contians the coded subject identy for each collection point or data element,
      *"X_train.txt"* which contain the values of the features, and
      *"y_train.txt"* which contains the values of the activity that was being preformed for each collection point.

  ./data/test

    *"subject_test.txt"* file which contians the coded subject identy for each collection point or data element,
    *"X_test.txt"* which contain the values of the features, and
    *"y_test.txt"* which contains the values of the activity that was being preformed for each collection point

In the ZIP file, both the train and the test sub-directories contian an additional sub-directory call"Inertial Signals" which contains raw signal data.  These data are not used for this project.

## Dataset descriptions

### features.txt
    This file contacts descriptive labels for each of the 561 variables included in the files x_train.txt and x_test.txt as well as an index or counter variable.  This file can be read in with read.table.  To make useful column names, some clean up of the values is necessary.  Specifically, values of "(" or ")" in the names should be removed and values of "," or '-' should be converted to "." (which is considered good programming practice in R for column names they require separators).  Additionally, the values should be set to lower case.  
    
Thus, this value...

  tBodyAcc-mean()-X 
  
will be changed to  

  tbodyacc.mean.x
    
for use as a column name.

  Additionally, only certain column names will be required for the final dataset.  Only those that are "mean" or "std" will be required.  Values that are "meanfreq"  or "gravitymean" are not considered part of the required list.
  

### x_train.txt and x_test.txt

  These two files each contain 561 variables which match to the names provided in features.txt (described above).  Each record pertains to a subject and activity. Actual subject and activity information must be pulled in from other files (descrbed next).  Together there are 10299 observations, 7352 in y_train.txt and 2947 in x_test.txt.  
 
### subject_train.txt and subject_test.txt

  These two files each contain one variable which indicates the subject number of the record from the corresponding x dataset.  Together there are 10299 observations, 7352 in subject_train.txt and 2947 in subject_test.txt.
  
### y_train.txt and y_test.txt

  These two files each contain one variable which indicates the activity number of the record from the corresponding x dataset.  Together there are 10299 observations, 7352 in y_train.txt and 2947 in x_test.txt.

### activity_names.txt

  This file contains two columns, an index/key field that matches to the activity number in the y_train.txt/y_test.txt file and an activity description.  There are 6 observations in this file.
  
  The actual values in this file will become a column of activity descriptions in the final dataset.  The values were "cleaned" up by changing the underscores to blanks and changing the values to proper case.  Thus the following values will be used
  1  Walking
  2  Walking Upstairs
  3  Walking Downstairs
  4  Sitting
  5  Standing
  6  Laying
  

## Creating a combined dataset.

To create a combined dataset, the following must be done...

1 Read in features.txt and clean up the fields as described above to create a dataset with 561 records and 2 variables.  Only the second variable will be used.

Subset the features to find the 66 that are measurements of mean or std.  Only keep these features in joinX.

2 Read in x_train.txt and x_test.txt and rbind them together to form a single dataset joinX with 10299 records and 561 variables.  The variable names are applied from the features.txt dataset

3 Read in subject_train.txt and subject_test.txt and rbind them together to form a single dataset joinSubject with 10299 records and 1 variable.  The variable will be named subject.

4 Read in y_train.txt and y_test.txt and rbind them together to form a single dataset joinY with 10299 records 1 variable.  The variable will be named key.

5  cbind the x, y and subject data to obtain a dataset with 10299 observations and 68 variables

6  Read in activity_names.txt and clean up the names as described above, to result in a dataset with 6 observations and 2 variables.

7  Merge in the activity names with the combined dataset.

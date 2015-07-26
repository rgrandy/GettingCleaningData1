---
title: "run_analysis"
author: "R Grandy"
date: "July 26, 2015"
output: html_document
---

This document describes in detail the program run_analysis.R.  A detailed description of the data are provided in CodeBook.md


In this version of the program, the working directory is set to 
  setwd("C:\\users\\Rose\\Documents\\Coursera\\CleanData2")

The dplyr package is also required.  The program assumes this has already been installed.  If not, install this package before running this code.

A simple function to convert character data to proper case has also been used.  This code was found after a google search and was deeemed to be a simple way to convert values to proper case (this is not an available option in any of the other loaded packages that were used)
 
 
           ```{r}
          topropper <- function(x) {
            sapply(x, function(strn)
            { s <- strsplit(strn, "\\s")[[1]]
            paste0(toupper(substring(s, 1,1)), 
                   tolower(substring(s, 2)),
                   collapse=" ")}, USE.NAMES=FALSE)
          }
          ```

The programming can be conceptualized in the following major steps

## Step 0 

  set the WD
  load the dplyr package
  initialize the toproper function
  
## Step 1
  Read in features.txt and clean up the fields to create a dataset with 561     records and 2 variables.  Only the second variable will be used.
  
  
  ```{r}
  features <-read.table("./data/features.txt",stringsAsFactors = FALSE)
  ```
  
  features.txt contains 561 observations that correspond to the variable names in the the x data that will be loaded next.  However, before these values can be used for field names they must be cleaned up. 
  
  ```{r}
  features$V2 <- gsub("\\(", "",features$V2) 
  features$V2 <- gsub("\\)", "",features$V2) 
  features$V2 <- gsub("\\,", ".",features$V2) 
  features$V2 <- gsub("\\-", ".",features$V2) 
  features$V2 <-tolower(features$V2)
  ```
  
  additionally, only select of the features are required for the final tidy dataset, that is, those that are for the mean or std of any given measurement.  To identify these, start with the original features data read in and create an index of the features we want
  
  ```{r}
  FeaturesWeWant <- grep("mean\\(\\)|std\\(\\)", features[, 2])
  ```
  
  it turns out there are 66 of these
  

## Step 2
Read in x_train.txt and x_test.txt and rbind them together to form a single dataset joinX with 10299 records and 561 variables.  The variable names are applied from the features.txt dataset and then a subset of these variables are kept based on the index in FeaturesWeWant created above

    ```{r}
    XtrainData <- read.table("./data/train/X_train.txt",col.names=features[,2],
                            stringsAsFactors = FALSE)
    XtestData <- read.table("./data/test/X_test.txt",col.names=features[,2],
                           stringsAsFactors = FALSE)
    joinX <- rbind(XtrainData, XtestData)
    joinX <-joinX[,FeaturesWeWant]
    ```

## Step 3
Read in subject_train.txt and subject_test.txt and rbind them together to form a single dataset joinSubject with 10299 records and 1 variable.  The variable will be named subject.

      ```{r}
    trainSubject <- read.table("./data/train/subject_train.txt",
                              col.names="subject",
                               stringsAsFactors = FALSE)
    testSubject <- read.table("./data/test/subject_test.txt",
                              col.names="subject",
                              stringsAsFactors = FALSE)
    joinSubject <- rbind(trainSubject, testSubject)   
      ```

## Step 4 
Read in y_train.txt and y_test.txt and rbind them together to form a single dataset joinY with 10299 records 1 variable.  The variable will be named key.

  ```{r}
  YtrainData <- read.table("./data/train/y_train.txt",col.names="key",
                           stringsAsFactors = FALSE)
  YtestData <- read.table("./data/test/y_test.txt",col.names="key",
                          stringsAsFactors = FALSE) 
  joinY <- rbind(YtrainData, YtestData)
  ```

## Step 5
cbind the x, y and subject data to obtain a dataset with 10299 observations and 68 variables

  ```{r}
  alldata <-cbind(joinSubject,joinY,joinX)
  ```
  
## Step 6
Read in activity_names.txt and clean up the names, to result in a dataset with 6 observations and 2 variables.

  ```{r}
  activitynames <- read.table("./data/activity_labels.txt",
                              col.names = c("key","activityname"),
                               stringsAsFactors = FALSE)
  
  activitynames$activityname <- gsub("_", " ",activitynames$activityname)
  activitynames$activityname <- topropper(activitynames$activityname)
  ```
  
## Step 7
Merge in the activity names with the combined dataset.
  
    ```{r}
    alldata <-arrange(alldata,key)
    activitynames <-arrange(activitynames,key)
    alldata <- merge(alldata,activitynames,all=TRUE)
    ```
  
## Step 8
Create the tidy dataset by getting the mean value for each combination of subject and activityname (also use the key value for nice sorting although it is not necessary and we will drop it before outputting the data)

    ```{r}
    alldata <-arrange(alldata,subject,key,activityname)
    tidydata <- alldata %>%  group_by(subject,key,activityname) %>%   summarise_each(funs(mean))
    tidydata$key <-NULL
    ```
    
## Step 9
Output the tidydata using write.table with row.names=FALSE


    ```{r}
    write.table(tidydata,"final_tidydata.txt",row.names = FALSE)
    ```
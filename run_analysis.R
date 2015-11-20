#' ---
#' title: "run_analysis.R"
#' author: "Betty Kreakie"
#' date: "November 20, 2015"
#' --


##Required libraries
library(dplyr)

##Read in all necessary data sets and set column names

activityLabels<-read.table(file="UCI HAR Dataset/activity_labels.txt",header=FALSE)
featuresLabels<-read.table(file="UCI HAR Dataset/features.txt",header=FALSE)



subjectTrain<-read.table(file="UCI HAR Dataset/train/subject_train.txt",header=FALSE)
featuresTrain<-read.table(file="UCI HAR Dataset/train/x_train.txt",header=FALSE)
activitiesTrain<-read.table(file="UCI HAR Dataset/train/y_train.txt",header=FALSE)

names(featuresTrain)<-featuresLabels[,2]

subjectTest<-read.table(file="UCI HAR Dataset/test/subject_test.txt",header=FALSE)
featuresTest<-read.table(file="UCI HAR Dataset/test/x_test.txt",header=FALSE)
activitiesTest<-read.table(file="UCI HAR Dataset/test/y_test.txt",header=FALSE)

names(featuresTest)<-featuresLabels[,2]


##Merging test and training data set into one dataset
trainingData<-cbind(subjectTrain,activitiesTrain,featuresTrain)
testData<-cbind(subjectTest,activitiesTest,featuresTest)

fullData<-rbind(trainingData,testData)

names(fullData)[1:2]<-c("Subject","Activities")


##Extracting only columns with mean or STD calculated 
whichColumns <- grep("mean\\(\\)|std\\(\\)",featuresLabels$V2,value=TRUE)

extractedColumns<-c("Subject","Activities",whichColumns)


extractedData<-subset(fullData,select=extractedColumns)


##Converting numerically coded activites to actual descriptive titles
x<-t(activityLabels)
colnames(x)<-activityLabels$V2
x<-x[-2,]
codedNames <- names(x)[match(extractedData$Activities, as.numeric(x))]
extractedData$Activities<-codedNames


##Renaming column names to be more interpretable
names(extractedData)<-gsub("^t","Time",names(extractedData))
names(extractedData)<-gsub("^f","Frequency",names(extractedData))
names(extractedData)<-gsub("Acc","Accelerometer",names(extractedData))
names(extractedData)<-gsub("Gyro","Gyroscope",names(extractedData))
names(extractedData)<-gsub("std","StandardDeviation",names(extractedData))
names(extractedData)<-gsub("Mag","Magnitude",names(extractedData))
names(extractedData)<-gsub("BodyBody","Body",names(extractedData))

##Creating tridy set of mean feature values by subject and activity

tidyData<- (extractedData %>% group_by(Subject,Activities) %>% summarise_each(funs(mean)))

write.table(tidyData,file="tidyData")

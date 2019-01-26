rm(list = ls())

library(dplyr)

setwd("C:/One-Drive/OneDrive - Tredence/MOOCs/01. Data Science Specialization/03. Getting and Cleaning Data/Peer Review Assignment")

filename = "UCI HAR Dataset.zip"

if (!file.exists(filename)) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",filename)
}

if (!dir.exists("UCI HAR Dataset")) {
  unzip(filename)
}

labels = read.table("./UCI HAR Dataset/activity_labels.txt",header = F,stringsAsFactors = F)
names(labels) = c("ActivityID","ActivityName")
features = read.table("./UCI HAR Dataset/features.txt", header = F, stringsAsFactors = F)

features = as.vector(features[,2])
required.feature.index = grep("mean|std", features)
required.features = features[required.feature.index]

test_label = read.table("./UCI HAR Dataset/test/y_test.txt",header = F)
names(test_label) = "ActivityID"
test_subject = read.table("./UCI HAR Dataset/test/subject_test.txt",header = F)
names(test_subject) = "Subject"
test_features = read.table("./UCI HAR Dataset/test/x_test.txt",header = F)
test_features = test_features[,required.feature.index]
names(test_features) = required.features
test = cbind(test_subject,test_label, test_features)

train_label = read.table("./UCI HAR Dataset/train/y_train.txt",header = F)
names(train_label) = "ActivityID"
train_subject = read.table("./UCI HAR Dataset/train/subject_train.txt", header = F)
names(train_subject) = "Subject"
train_features = read.table("./UCI HAR Dataset/train/x_train.txt",header = F)
train_features = train_features[,required.feature.index]
names(train_features) = required.features
train = cbind(train_subject, train_label, train_features)

master.dataset = rbind(train, test)
names(master.dataset)[2] = "ActivityID"
master.dataset = inner_join(labels, master.dataset, by = "ActivityID") %>% select(Subject, ActivityName, 4:81)

namescol = names(master.dataset)
namescol = gsub("mean","Mean",namescol, fixed = TRUE)
namescol = gsub("std","Std",namescol, fixed = TRUE)
namescol = gsub("-","",namescol, fixed = TRUE)
namescol = gsub("\\(\\)","",namescol)

names(master.dataset) = namescol

avg.master.dataset = master.dataset %>% group_by(Subject, ActivityName) %>% summarise_all(mean)
avgnamescol = paste0("Avg_",namescol)
names(avg.master.dataset) = avgnamescol

write.table(master.dataset,"FinalADS.txt",row.names = F)
write.table(avg.master.dataset,"AvgSummarised.txt",row.names = F)
#Script for taking a CSV of Tweets, as might be exported from Sifter or GNIP, and adding in the precise location
library(stringr)

#use this to only take a random sample from the data
takeSampleOfTweets = FALSE

someTweets = lookup_statuses(c("420344176967180288","420344178942705664","420344429913051136"))


## Read CSV
tweets <- read.csv("R_scripts/sifter_data/export_from_sifter.csv",header=T)

tweetIdsCol = as.character(tweets$X.M..id..)
splitRec = str_split_fixed(tweetIdsCol, ",2005:", 2)
tweetIdsCol = splitRec[,2]


if (takeSampleOfTweets == TRUE) {
  set.seed(42); 
  perCentSample = 0.01
  k = floor(perCentSample*length(tweetIdsCol))
  aSampleInd = sort(sample(1:length(tweetIdsCol),k))
  tweetSelection = tweetIdsCol[aSampleInd]
  
} else {
  tweetSelection = tweetIdsCol
}


iterSize = 1
statResp = lookup_statuses(tweetSelection[1:(1+iterSize)])
df <- do.call("rbind", lapply(statResp, as.data.frame))

apiQueryInterval = 12 #6 seconds

windowSize = 30
tweetsToGet = tweetSelection[which(!(tweetSelection%in%df$id))]
indexStart = 1
i=1
numIters = (length(tweetsToGet)+windowSize) %/% windowSize
for(i in 287:numIters-1){  
  print(i)
  windowStartIndex = indexStart
  windowEndIndex = windowStartIndex + windowSize-1
  if (windowEndIndex > length(tweetsToGet)) windowEndIndex = length(tweetsToGet)
    
  print(paste("window ", windowStartIndex, " to ", windowEndIndex))  
  windowIds = tweetsToGet[windowStartIndex:windowEndIndex]  
  indexStart = windowEndIndex+1

  
  
  
   sample = lookup_statuses(windowIds)
   newRecs <- do.call("rbind", lapply(sample, as.data.frame))

   df = rbind(df,newRecs)     
   if (length(newRecs) == 0) {
     print(paste("Tweets not found ",tweetsToGet[i]))
   } else {
     print(newRecs[,1])
   }    
   print(paste("iter: " ,i))
   Sys.sleep(apiQueryInterval)
  
  
  
  
#   if (tweetsToGet[i] %in% df$id == TRUE) {
#     theMatch = df[match(tweetsToGet[i],df$id),]
#     print(paste("already got tweet: ",tweetsToGet[i], " matched with ", theMatch$id))           
#   } else {    
#     sample = lookup_statuses(tweetsToGet[i])
#     newRecs <- do.call("rbind", lapply(sample, as.data.frame))
# 
#     df = rbind(df,newRecs)     
#     if (length(newRecs) == 0) {
#       print(paste("Tweet not found ",tweetsToGet[i]))
#     } else {
#       print(df[nrow(df),1]) # print last row
#     }    
#     print(i)
#     Sys.sleep(apiQueryInterval)
#   }
}



write.csv(file="dfOfTweetsNew_8474.csv", x=df)




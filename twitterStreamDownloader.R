install.packages("streamR")
install.packages("ROAuth")
library(ROAuth)
library(streamR)
library(devtools)
library(httr)

#lots of Twitter lib guff
install.packages("twitteR")
install_github("geoffjentry/twitteR")
library(twitteR)
library(base64enc)
devtools::install_github("jrowen/twitteR", ref = "oauth_httr_1_0")


#authentication process guff
credential <- OAuthFactory$new(consumerKey='api key',
                               consumerSecret='secret',
                               requestURL='https://api.twitter.com/oauth/request_token',
                               accessURL='https://api.twitter.com/oauth/access_token',
                               authURL='https://api.twitter.com/oauth/authorize')

options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
twitCred$handshake()
registerTwitterOAuth(twitCred)


options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")
credential$handshake(cainfo="cacert.pem")
save(credential, file = "my_oauth.Rdata")



#load the creds, if not done already
load("my_oauth.Rdata")



#Set up query params
locVec = c( -3.875800, 53.984656, -1.175812, 55.840553) #cumbria
keyword = "flood"
jsonfile = "tweets.json"


#start caching the stream
filterStream( file.name=jsonfile,track=keyword, locations=locVec, tweets=1000000, oauth=credential, timeout=360000, lang='en' )

# time passes...


#load and parse streamed tweets
tweets.df <- parseTweets(jsonfile, simplify = TRUE)



library(jsonlite)
library(parallel)
library(plyr)
library(reshape2)

# Used to extract some columns of the Tweet's data
transformTweets <- function(input, output) {
    lines <- readLines(input) # read lines of tweet file
    print("readLines")
    jsonData <- mclapply(lines, fromJSON, mc.cores=4) # transform each line to a json object (list)
    print("fromJSON")

    rm(lines)

    lang <- sapply(jsonData, function(x) x$user$lang)
    jsonPt <- jsonData[lang == "pt"]

    rm(jsonData)
    print("lang pt")

    tweets <- mclapply(jsonPt, extract, mc.cores=4)
    rm(jsonPt)
    print("extract")

    tweets.df <- do.call(rbind.data.frame, tweets)
    print("rbind.data.frame")

    tweets.df$text <- as.character(tweets.df$text)
    tweets.df$user_description <- as.character(tweets.df$user_description)

    save(tweets.df, file=output)
    cat(input, "saved to", output, "\n")
}

extract <- function(x) {
    created_at <- x$created_at 
    if (is.null(created_at)) created_at <- " " 
    created_at <- formatTwDate(created_at)

    text <- x$text
    if (is.null(text)) text <- " "

    retweeted <- x$retweeted
    if (is.null(retweeted)) retweeted <- FALSE

    retweet_count <- x$retweet_count
    if (is.null(retweet_count)) retweet_count <- 0

    source <- x$source
    if (is.null(source)) source <- " "

    user_location <- x$user$location
    if (is.null(user_location)) user_location <- " "

    user_description <- x$user$description
    if (is.null(user_description)) user_description <- " "

    user_name <- x$user$name
    if (is.null(user_name)) user_name <- " "

    user_screen_name <- x$user$screen_name
    if (is.null(user_screen_name)) user_screen_name <- " "

    user_time_zone <- x$user$time_zone
    if (is.null(user_time_zone)) user_time_zone <- " "

    df <- data.frame(created_at, text, retweeted, retweet_count, source, user_location, user_description, user_name, user_screen_name, user_time_zone)
}

#e <- lapply(jsonPt, extract)

formatTwDate <- function(datestring, format="datetime"){
    if (format=="datetime"){
        date <- as.POSIXct(datestring, format="%a %b %d %H:%M:%S %z %Y")
    }
    if (format=="date"){
        date <- as.Date(datestring, format="%a %b %d %H:%M:%S %z %Y")
    }   
    return(date)
}

# join tweets
setwd("processed/")

filenames <- list.files()

rest_idx <- grep("rest", filenames)

rest_count <- 0
streaming_count <- 0

rest_count <- sum(sapply(filenames[rest_idx], function(x) {
    load(x)
    nrow(tweets.df)
    })) 


streaming_count <- sum(sapply(filenames[-rest_idx], function(x) {
    load(x)
    nrow(tweets.df)
    })) 

load(filenames[1])
x <- tweets.df
for(i in 2:length(filenames)) {
    #length(filenames)) {
    load(filenames[i])
    ls()
    x <- rbind.data.frame(x, tweets.df)
}

rmTags <- function(htmlString) {
      return(gsub("<.*?>", "", htmlString))
}

# remove html tags
data$source <- rmTags(data$source)

# create the column for device
data$device <- "unknown"

data$device[grep("android", tolower(data$source))] <- "android"
data$device[grep("windows phone", tolower(data$source))] <- "windows"
data$device[grep("ios|iphone|ipad", tolower(data$source))] <- "ios"


# identify the state of twitter
city <- read.csv("cidade_estado.csv")
location <- data$user_location

state <- c()
ufs <- unique(city$uf)
for(uf in ufs) {
    cidades <- city$cidade[city$uf == uf]
    temp <- grepl(uf, location)
    for(cidade in cidades)
        temp <- temp | grepl(cidade, location)

    state[which(temp)] <- uf
    print(uf)
}

data$aecio <- FALSE
data$aecio[grepl("aécio", data$text) | grepl("aecio", data$text) | grepl("#aecio", data$text) | grepl("#aécio", data$text)] <- TRUE

data$psdb <- FALSE
data$psdb[grepl("psdb", data$text) | grepl("#psdb", data$text)] <- TRUE

data$dilma <- FALSE
data$dilma[grepl("dilma", data$text) | grepl("#dilma", data$text) | grepl("rousseff", data$text)] <- TRUE

data$pt <- FALSE
data$pt[grepl("pt", data$text) | grepl("#pt", data$text)] <- TRUE

data$category <- "unknown"
data$category[grepl("aécio", data$text) | grepl("aecio", data$text) | grepl("#aecio", data$text) | grepl("#aécio", data$text) | grepl("psdb", data$text) | grepl("#psdb", data$text)] <- "aecio"

data$category[grepl("dilma", data$text) | grepl("#dilma", data$text) | grepl("rousseff", data$text) | grepl("pt", data$text) | grepl("#pt", data$text)] <- "dilma"

library(tm)
library(SnowballC)

# separate the tweet text into these four elements
#0 - stemmed terms of the text
#1 - hashtags
#2 - user mentions
#3 - links
text <- data$text[1]

stemmed <- c()
hashtags <- c()
user_mentions <- c()
links <- c()

text <- unlist(strsplit(text, " "))
for(token in text) {
    if(grepl("^#", token))
        hashtags <- c(hashtags, token)
    else if(grepl("^@", token))
        user_mentions <- c(user_mentions, token)
    else if(grepl("^http:", token))
        links <- c(links, token)
    else {
        token <- gsub("[[:punct:]]", "", token) # remove punctuation
        token <- wordStem(token, language = "portuguese")
        stemmed <- c(stemmed, token)
    }
}



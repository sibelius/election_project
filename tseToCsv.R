setwd("tse")

brasil <- read.csv("brasil.csv", sep=";", fileEncoding="latin1")
brasil <- brasil[,c("Nr","Candidato","Partido","Votação")]
brasil <- brasil[complete.cases(brasil),]
brasil$Votação <- as.numeric(gsub("[.]","",as.character(brasil$Votação)))


parseResultsState <- function(filename) {
    data <- read.csv(filename, sep=";", fileEncoding="latin1")
    data <- data[,c("UF", "Nr", "Candidato", "Partido", "Votação")]
    data <- data[complete.cases(data),]
    data$UF[seq(2,nrow(data),2)] <- data$UF[seq(1,nrow(data),2)] # complete uf data
    data$Votação <- as.numeric(gsub("[.]","",as.character(data$Votação)))
    data$regiao <- gsub(".csv","", filename)
    return(data)
}

filenames <- list.files()
states <- lapply(filenames[-1], parseResultsState)

elections <- do.call(rbind.data.frame, states)

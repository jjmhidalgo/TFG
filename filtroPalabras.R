library(stringr)
library(plyr)
library(dplyr)
library(magrittr)
library(tm)
library(proxy)
library(ggplot2)
library(RColorBrewer)
library(wordcloud)
library(extracat)
source("histFreqs.R")

#Leer ficheros de datos y crear un corpus:
twCor <-VCorpus(DirSource("txt", encoding="UTF-8"), readerControl = list(language="es"))

#Quitar acentos:
twCor <- tm_map(twCor, tolower)

#Quitar puntuación
twCor <- tm_map(twCor, removePunctuation)

#Quitar números
twCor <- tm_map(twCor, removeNumbers)

# remove stopwords
myStopwords <- c(stopwords("spanish"))
twCor <- tm_map(twCor, removeWords, myStopwords)



#Para crear la matriz
twCor <-tm_map(twCor, PlainTextDocument)
matrizTweets <- TermDocumentMatrix(twCor, control = list(minWordLength = 1))
matrizTweets <- removeSparseTerms(matrizTweets, 0.99) #Este valor va de 0 a 1, siendo 0,99 las más frecuentes


#Función para partir matrices (por defecto divide entre uno)
muestreaTweets <- function(matriz, fraccion=1) {
  muestra <- sample(1:ncol(matriz), ncol(matriz)/fraccion)
  matriz[, muestra]
}

# Reduce la matriz a la mitad de tweets, aleatoriamente pero de forma reproducible
set.seed(1463068473)
matrizTweets <- muestreaTweets(matrizTweets, 2) #Este número marca el número por el que dividimos la matriz


#Para construir las matrices para el clustering:
m <- as.matrix(matrizTweets)
matrizTweets_dist <- dist(m, method = 'cosine')

#Con esto creamos el cluster dendrogram por el metodo de la distancia del coseno de Ward
clust_h <- hclust(d = matrizTweets_dist, method = 'ward.D2')
plot(clust_h, main = 'Cluster Dendrogram: Ward Cosine Distance', xlab = '', ylab = '', sub = '')

#Para crear un heatmap
#heatmap(m[cutree(clust_h, 6)==1,])
#heatmap(m[cutree(clust_h, 6)==2,])
#heatmap(m[cutree(clust_h, 6)==3,])
#heatmap(m[cutree(clust_h, 6)==4,])
#heatmap(m[cutree(clust_h, 6)==5,])
#heatmap(m[cutree(clust_h, 6)==6,])


#Para el wordcloud
v <- sort(rowSums(m), decreasing=TRUE)
myNames <- names(v)
k <- which(names(v)=="miners")
myNames[k] <- "mining"
d <- data.frame(word=myNames, freq=v)
wordcloud(d$word, d$freq, min.freq=5000, max.words = 50)

histFreqs(m)
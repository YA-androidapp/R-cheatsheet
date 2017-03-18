# MeCabによる類似度分析

---

```r
# テキストファイルの読み込み
data  <- scan("data.txt", what=character(), sep="\n", blank.lines.skip=F)
data1 <- data[1]
data2 <- data[2]
data3 <- data[3]

library(RMeCab)
library(Matrix)
pos <- c("名詞", "動詞", "形容詞", "形容動詞")
texts <- c(data1, data2,data3)
# TF値による単語文書行列
D1 <- docMatrixDF(texts, pos=pos, weight="tf")
# 疎行列へ変換
DD1 <- as(D1, "CsparseMatrix")
# 2-gramによる行列
D2 <- t(docNgramDF(texts, type=1, pos=pos, N=2))
DD2 <- as(D1, "CsparseMatrix")
```

## 2値文書分類

```r
install.packages("maxent")
library(maxent)
data <- read.csv(system.file("data/NYTimes.csv.gz", package="maxent"))
data2 <- subset(data, Topic.Code %in% c(16L, 20L))
head(data)
head(data2)

# ラベル
topic <- factor(data2$Topic.Code)
library(tm)
corpus <- Corpus(VectorSource(data2$Title))
# 単語文書行列
D <- TermDocumentMatrix(corpus)
rownames(D)[which(rownames(D)=="...")] <- "X..."
set.seed(0)
# ホールドアウト法
trIndex <- sample.int(ncol(D), ncol(D)/2)
trData <- t(D[, trIndex])
teData <- t(D[, -trIndex])
trTopic <- topic[trIndex]
teTopic <- topic[-trIndex]

# MEモデル
me.train <- maxent(trData, trTopic)
me.predict <- predict(me.train, teData)[, "labels"]
( me.tbl <- table(me.predict, truth=teTopic))
sum(diag(me.tbl))/sum(me.tbl)

# SVMで分類
library(caret)
fitControl <- trainControl(
  method="LGOCV",
  number=30,
  p=0.75
)

# trDataを、疎行列から通常の行列に戻す必要がある
# svm.train <- train(as.matrix(trData), trTopic, trControl=fitControl)
svm.train <- train(as.matrix(trData), trTopic)
svm.sigma <- unlist(svm.train["bestTune"])["bestTune.sigma"]
svm.c <- unlist(svm.train["bestTune"])["bestTune.C"]
# 2回目の探索範囲を、1回目に得られた最適値の周囲のみに限定
grid <- expand.grid(
  sigma = c(
    3*svm.sigma/4,
    svm.sigma,
    5*svm.sigma/4
    ),
  C = c(0.8*svm.c, 0.9*svm.c, svm.c, 1.1*svm.c, 1.2*svm.c)
)
# より詳細に探索
svm.tune <- train(
  as.matrix(trData),
  trTopic,
  method="svmRadial",
  preProc=c("center","scale"),
  trControl=fitControl,
  tuneGrid=grid
  )
svm.sigma <- unlist(svm.train["bestTune"])["bestTune.sigma"]
svm.c <- unlist(svm.train["bestTune"])["bestTune.C"]
svm.predict <- predict(svm.train, as.matrix(teData))
( svm.tbl <- table(svm.predict, truth=teTopic))
sum(diag(svm.tbl))/sum(svm.tbl)
```

---

Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.
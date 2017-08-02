# R cheatsheet (教師あり学習編)

## 目次

1. e1071パッケージ
2. caretパッケージ
3. randomForestパッケージ
4. 不均衡データに対する学習

---

## 1.e1071パッケージ

### 1.1.データの準備

```r
# データを読込み
data(iris)
data <- iris

# データを散布図行列に表示して確認
plot(data, col=1+as.integer(data$Species), pch=as.character(data$Species))
# Sepal.Length列とSepal.Width列のみ抽出し、散布図行列に表示して確認
plot(data$Sepal.Length, data$Sepal.Width, col=1+as.integer(data$Species), pch=as.character(data$Species), xlab="Sepal.Length", ylab="Sepal.Width")

# ランダムにテストデータとトレーニングデータとに分割する
sample <- sample(nrow(data),(nrow(data)/2))
test <- data[sample, ]
train  <- data[-sample, ]
head(test)
```

|     | Sepal.Length | Sepal.Width | Petal.Length | Petal.Width | Species |
| --- | ------------ | ----------- | ------------ | ----------- | ------- |
|   3 | 4.7 | 3.2 | 1.3 | 0.2 | setosa
|  42 | 4.5 | 2.3 | 1.3 | 0.3 | setosa
|  69 | 6.2 | 2.2 | 4.5 | 1.5 | versicolor
|  45 | 5.1 | 3.8 | 1.9 | 0.4 | setosa
| 116 | 6.4 | 3.2 | 5.3 | 2.3 | virginica
|   6 | 5.4 | 3.9 | 1.7 | 0.4 | setosa

```r
head(train)
```

|     | Sepal.Length | Sepal.Width | Petal.Length | Petal.Width | Species |
| --- | ------------ | ----------- | ------------ | ----------- | ------- |
|   5 | 5.0 | 3.6 | 1.4 | 0.2 | setosa
|  11 | 5.4 | 3.7 | 1.5 | 0.2 | setosa
|  14 | 4.3 | 3.0 | 1.1 | 0.1 | setosa
|  15 | 5.8 | 4.0 | 1.2 | 0.2 | setosa
|  19 | 5.7 | 3.8 | 1.7 | 0.3 | setosa
|  20 | 5.1 | 3.8 | 1.5 | 0.3 | setosa

```r
# t検定でデータ分割の妥当性を確認
#  帰無仮説：「二群の母平均は等しい」
#  p-valueが0.05よりも小さければ、2つのデータセットは有意に異なる
( data.ttest <- t.test(test[,1:4],train[,1:4],var.equal=T) )
```

>	Two Sample t-test
>
>
>
>data:  test[, 1:4] and train[, 1:4]
>
>t = 0.2416, df = 598, p-value = 0.8092
>
>alternative hypothesis: true difference in means is not equal to 0
>
>95 percent confidence interval:
>
> -0.2780289  0.3560289
>
>sample estimates:
>
>mean of x mean of y
>
>    3.484     3.445

```r
# names(data.ttest)
# data.ttest["p.value"]
if(data.ttest["p.value"]<0.05) {
  print("テストデータとトレーニングデータの傾向には差が見られます。")
} else {
  print("テストデータとトレーニングデータの傾向はほぼ同じといえます。")
}
```

```r
# テストデータから正解値となる列を除去する
test.ansr <- test[, "Species"]
test.test <- test[, setdiff(colnames(test), "Species")]
```

### 1.2.SVM(デフォルトのパラメーター)

```r
# パッケージの読み込み
# install.packages("e1071")
library(e1071)

# デフォルトのパラメーターでSpeciesの判別
#  トレーニングデータからモデルを作成
model <- svm(Species ~ ., data = train)

#  作成したモデルでテストデータのSpeciesの判別
predict <- predict(model, test.test)

#  答え合わせ
table(predict, test.ansr)
```

| predict      | setosa | versicolor | virginica |
| ------------ | ------ | ---------- | --------- |
|   setosa     |     23 |          0 |         0 |
|   versicolor |      0 |         26 |         0 |
|   virginica  |      0 |          0 |        26 |

### 1.3.SVM(グリッドサーチで最適なパラメーター値を探索)

```r
# まずはおおまかに探索
gammaRange = 10^(-5:5)
costRange = 10^(-2:2)
t <- tune.svm(Species ~ ., data=train, gamma=gammaRange, cost=costRange, tunecontrol=tune.control(sampling="cross", cross=8))
plot(t, transform.x=log10, transform.y=log10)

# 2回目の探索範囲を、1回目に得られた最適値の周囲のみに限定
gamma <- t$best.parameters$gamma
cost  <- t$best.parameters$cost
gammaRange <- 10^seq(log10(gamma)-1,log10(gamma)+1,length=11)[2:10]
costRange  <- 10^seq(log10(cost)-1 ,log10(cost)+1 ,length=11)[2:10]
# より詳細に探索
t <- tune.svm(Species ~ ., data = train, gamma=gammaRange, cost=costRange, tunecontrol = tune.control(sampling="cross", cross=8))
plot(t, transform.x=log10, transform.y=log10, zlim=c(0,0.1))

# 探索して得られたパラメーターをもとにテストデータに対して判別を行う
model <- svm(Species ~ ., data = train, gamma=t$best.parameters$gamma, cost=t$best.parameters$cost)
predict <- predict(model, train.train)

#  答え合わせ
table(predict, train.ansr)
```

| predict      | setosa | versicolor | virginica |
| ------------ | ------ | ---------- | --------- |
|   setosa     |     27 |          0 |         0 |
|   versicolor |      0 |         23 |         1 |
|   virginica  |      0 |          1 |        23 |

## 2.caretパッケージ

### 2.1.データの準備

```r
# データを読込み
data(iris)
data <- iris

# データを散布図行列に表示して確認
plot(data, col=1+as.integer(data$Species), pch=as.character(data$Species))
# Sepal.Length列とSepal.Width列のみ抽出し、散布図行列に表示して確認
plot(data$Sepal.Length, data$Sepal.Width, col=1+as.integer(data$Species), pch=as.character(data$Species), xlab="Sepal.Length", ylab="Sepal.Width")
```

### 2.2.変数選択とデータ分割

```r
# パッケージの読み込み
# install.packages("caret")
library(caret)

# 数値型のみ処理対象
data.numeric <- head(data[sapply(data,is.numeric)])
data.filtered <- data

# 分散が0に近い特徴量を除去
data.n <- nearZeroVar(data.numeric)
if((!is.null(data.n)) && (is.numeric(data.n)) && (length(data.n) > 0)) {
  data.filtered <- data.filtered[,-data.n]
}
# head(data.filtered)

# 相関が強い特徴量を削除
data.c <- cor(data.filtered[sapply(data.filtered,is.numeric)])
data.highcor <- findCorrelation(data.c,cutoff=0.75)
if((!is.null(data.highcor)) && (is.numeric(data.highcor)) && (length(data.highcor) > 0)) {
  data.filtered <- data.filtered[,-data.highcor]
}
# head(data.filtered)
colnames(data.filtered)

# 変数選択結果を反映
# data <- data[, colnames(data.filtered)]
```

```r
# ランダムにテストデータとトレーニングデータとに分割する
sample <- sample(nrow(data),(nrow(data)/2))
test <- data[sample, ]
train  <- data[-sample, ]
head(test)

# テストデータから正解値となる列を除去する
test.ansr <- test[, "Sepal.Length"]
test.test <- test[, setdiff(colnames(test), "Sepal.Length")]
```

### 2.3.SVM(グリッドサーチで最適なパラメーター値を探索)

```r
fitControl <- trainControl(
  method="LGOCV",
  number=30,
  p=0.75
)

# まずはおおまかに探索
svm.train <- train(Sepal.Length~.,data=train,method="svmRadial",preProc = c("center","scale"),trControl=fitControl)
svm.sigma <- unlist(svm.train["bestTune"])["bestTune.sigma"]
svm.c <- unlist(svm.train["bestTune"])["bestTune.C"]
# 2回目の探索範囲を、1回目に得られた最適値の周囲のみに限定
grid <- expand.grid(sigma = c(3*svm.sigma/4, svm.sigma, 5*svm.sigma/4),
  C = c(0.8*svm.c, 0.9*svm.c, svm.c, 1.1*svm.c, 1.2*svm.c)
)
# より詳細に探索
svm.tune <- train(Sepal.Length~.,data=train,method="svmRadial",preProc = c("center","scale"),trControl=fitControl,tuneGrid = grid)
svm.sigma <- unlist(svm.train["bestTune"])["bestTune.sigma"]
svm.c <- unlist(svm.train["bestTune"])["bestTune.C"]

# 探索して得られたパラメーターをもとにテストデータに対して判別を行う
svm.predict <- predict(svm.train, test)

# 評価
predict <- svm.predict
n <- length(predict)
er <- predict - test$Sepal.Length
rss <- sum(er*er) / n
rms <- sqrt(rss)

mean(test$Sepal.Length)
sd(test$Sepal.Length)
```

# 2.4.RandomForest

```r
rf.train <- train(Sepal.Length~.,data=train,method="rf",trControl=fitControl)
unlist(rf.train["bestTune"])["bestTune.mtry"]
```

# 2.5.NeuralNetwork


```r
nn.train <- train(Sepal.Length~.,data=train,method="nnet",trControl=fitControl)
unlist(nn.train["bestTune"])["bestTune.size"]
unlist(nn.train["bestTune"])["bestTune.decay"]
```

## 3.randomForestパッケージ

### 3.1.データの準備

```r
# データを読込み
data(iris)
data <- iris

# ランダムにテストデータとトレーニングデータとに分割する
sample <- sample(nrow(data),(nrow(data)/2))
test <- data[sample, ]
train  <- data[-sample, ]

# テストデータから正解値となる列を除去する
test.ansr <- test[, "Species"]
test.test <- test[, setdiff(colnames(test), "Species")]
```

### 3.2.SVM(デフォルトのパラメーター)

```r
# パッケージの読み込み
# install.packages("randomForest")
library(randomForest)

# デフォルトのパラメーターでSpeciesの判別
#  トレーニングデータからモデルを作成
model <- randomForest(Species ~ ., data = train, ntree=2000)

#  作成したモデルでテストデータのSpeciesの判別
predict <- predict(model, test.test)

#  答え合わせ
table(predict, test.ansr)
```

| predict      | setosa | versicolor | virginica |
| ------------ | ------ | ---------- | --------- |
|   setosa     |     26 |          0 |         0 |
|   versicolor |      0 |         22 |         4 |
|   virginica  |      0 |          1 |        22 |

### 1.3.SVM(グリッドサーチで最適なパラメーター値を探索)

```r
# 探索
t <- tuneRF(train.train,train.ansr,doBest=T, ntreeTry=2000)

model <- randomForest(Species ~ ., data = train, mtry=t$mtry, ntree=2000)
plot(model)
importance(model)
```

|              | MeanDecreaseGini |
| ------------ | ---------------- |
| Sepal.Length | 10.718649 |
| Sepal.Width | 4.829245 |
| Petal.Length | 15.845210 |
| Petal.Width | 17.535487 |

```r
# 探索して得られたパラメーターをもとにテストデータに対して判別を行う
predict <- predict(model, test.test)

#  答え合わせ
table(predict, test.ansr)
```

| predict      | setosa | versicolor | virginica |
| ------------ | ------ | ---------- | --------- |
|   setosa     |     26 |          0 |         0 |
|   versicolor |      0 |         22 |         4 |
|   virginica  |      0 |          1 |        22 |

# 4.不均衡データに対する学習

## 4.1.線形判別分析

### 4.1.1.必要なライブラリ等の読み込み
```r
# install.packages("MASS")
# install.packages("DMwR")
# install.packages("dplyr")
# install.packages("e1071")

library(caret)
library(DMwR) # SMOTE
library(dplyr)
library(e1071)
library(kernlab) # spamデータセット
library(MASS) # 線形判別分析

data(iris)
data(spam)
```

### 4.1.2.不均衡データの準備

```r
# iris
data.iris <- rbind(iris[1:50,], iris[51:100,], iris[106:111,])

# spam
data.spam <- rbind(head(spam, 500), tail(spam, 2500))
table(data.spam[, 58]) # 標本数を確認
# nonspam    spam
#    2500     500
```

### 4.1.3.不均衡データのまま線形判別分析

```r
#iris
data.iris.lda <- lda(Species ~ ., data = data.iris, CV = TRUE)
( tab.iris <- table(data.iris[, 5], data.iris.lda$class) )
#              setosa versicolor virginica
#   setosa         50          0         0
#   versicolor      0         50         0
#   virginica       0          1         5

# spam
data.spam.lda <- lda(type ~ ., data = data.spam, CV = TRUE)
( tab.spam <- table(data.spam[, 58], data.spam.lda$class) )
#           nonspam spam
# nonspam    2440   60
# spam        220  280
```

### 4.1.4.SMOTEによるオーバーサンプリング

```r
# iris
data.iris.smote <- SMOTE(Species ~ ., data = data.iris, perc.over = 500, k = 5, perc.under = 100)
table(data.iris.smote[, 5])

# spam
data.spam.smote <- SMOTE(type ~ ., data = data.spam, perc.over = 500, k = 5, perc.under = 100)
table(data.spam.smote[, 58])
```

### 4.1.5.オーバーサンプリングしたデータに対する線形判別分析

```r
# iris
data.iris.lda <- lda(Species ~ ., data = data.iris.smote, CV = TRUE)
( tab.iris.smote <- table(data.iris.smote[, 5], data.iris.lda$class) )
#              setosa versicolor virginica
# setosa         19          0         0
# versicolor      0         11         0
# virginica       0          0        36

# 分類精度の確認
sum(diag(tab.iris)) / sum(tab.iris)
# [1] 0.990566
sum(diag(tab.iris.smote)) / sum(tab.iris.smote)
# [1] 1

# spam
data.spam.smote.lda <- lda(type ~ ., data = data.spam.smote, CV = TRUE)
( tab.spam.smote <- table(data.spam.smote[, 58], data.spam.smote.lda$class) )
#         nonspam spam
# nonspam    2348  152
# spam        192 2808

# 分類精度の確認
sum(diag(tab.spam)) / sum(tab.spam)
# [1] 0.9066667
sum(diag(tab.spam.smote)) / sum(tab.spam.smote)
# [1] 0.9374545
```

## 4.2.SVM・ランダムフォレスト

### 4.2.1.データセットの準備・可視化

```r
data <- iris %>%
  filter(Species %in% c("versicolor", "virginica")) %>%
  select(Sepal.Length, Petal.Width, Species) %>%
  mutate(Species=as.factor(as.character(Species)))
head(data, 3)
#   Sepal.Length Petal.Width    Species
# 1          7.0         1.4 versicolor
# 2          6.4         1.5 versicolor
# 3          6.9         1.5 versicolor

train_index <- createDataPartition(data$Species, p=0.7, list=FALSE)
train_data <- data[train_index,] # 訓練データ
test_data <- data[-train_index,] # 評価データ

myplot <- function(data) {
  plot(Sepal.Length ~ Petal.Width, data=data, col=Species, pch=19,
       xlim=c(1, 2.5), ylim=c(4.5, 8))
}
myplot(train_data)
```

### 4.2.2.分類用関数の準備

```r
# SVM
computeSVM <- function(data) {
  cpsvm.train<-svm(Species~.,data)
  cpsvm.predict<-predict(cpsvm.train,newdata=test_data[,-3])
  table(test_data$Species,cpsvm.predict)
}

computeRF <- function(data) {
  model <- train(data %>% select(-Species), data$Species,
                 method="rf", preProcess=c("center", "scale"),
                 trControl=trainControl(method="oob"), ntree=2000)
  all_pred <- extractPrediction(list(model),
                                testX=test_data %>% select(-Species),
                                testY=test_data$Species)
  pred <- all_pred %>% filter(dataType == "Test")
  cm <- confusionMatrix(pred$pred, pred$obs)
  cm$table
}
```

### 4.2.3.不均衡データとする前のデータに対する分類の実施

```r
computeSVM(train_data)
#           cpsvm.predict
#            versicolor virginica
# versicolor         15         0
# virginica           2        13

# Random Forest
computeRF(train_data)
#           Reference
#            Prediction   versicolor virginica
# versicolor         15         3
# virginica           0        12
```

### 4.2.4.不均衡データの準備

```r
# 不均衡データとする
data_imbalanced <- train_data %>%
  slice(c(1:35, sample(36:70, size = 6, replace = FALSE)))

myplot(data_imbalanced)
```

### 4.2.5.不均衡データに対する分類の実施

```r
computeSVM(data_imbalanced)
#           cpsvm.predict
#            versicolor virginica
# versicolor         15         0
# virginica           6         9
computeRF(data_imbalanced)
#           Reference
#            Prediction   versicolor virginica
# versicolor         15         7
# virginica           0         8
```

### 4.2.5.不均衡データへのオーバーサンプリングの実施と再判別

```r
# オーバーサンプリング
data_smote <- SMOTE(Species ~ ., data = data_imbalanced)
myplot(data_smote)
computeRF(data_smote)
#           Reference
#            Prediction   versicolor virginica
# versicolor         15         7
# virginica           0         8
data_imbalanced %>% count(Species)
# # A tibble: 2 × 2
#      Species     n
#       <fctr> <int>
# 1 versicolor    35
# 2  virginica     6
data_smote %>% count(Species)
# # A tibble: 2 × 2
#      Species     n
#       <fctr> <int>
# 1 versicolor    24
# 2  virginica    18
```

### 4.2.5.クラスの重みづけ調整と精度評価

```r
computeSVM2 <- function(data) {
  wts<-100/table(data$Species)
  cpsvm.train<-svm(Species~., data, class.weights=wts)
  cpsvm.predict<-predict(cpsvm.train,newdata=test_data[,-3])
  table(test_data$Species,cpsvm.predict)
}
computeSVM2(train_data)
#           cpsvm.predict
#            versicolor virginica
# versicolor         15         0
# virginica           3        12
```

---

Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.

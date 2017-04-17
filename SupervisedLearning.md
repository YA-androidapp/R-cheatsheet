# R cheatsheet (教師あり学習編)

## 目次

1. e1071パッケージ
2. caretパッケージ
3. randomForestパッケージ

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

---

Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.

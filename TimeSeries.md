﻿# R cheatsheet (時系列分析編)

## 目次

1. 時系列分析と確率過程
2. CO2データセットに対する予測

---

## 1.線形回帰分析

### 1.1.データの準備

```r
# install.packages('forecast')
library(forecast)

#パラメータの設定
d <- 1 #階差
no <- 200 #標本数
sd <- 1.0 #ホワイトノイズの標準偏差
phi <- c(0.1,0.1) #ARモデルの係数
theta <- c(0.1,0.1) #MAモデルの係数

#arima.sim()による標本の作成
generateARIMASample <- function(phi, d, theta){
  p <- length(phi)
  q <- length(theta)
  mdl <- list(order=c(p,d,q),ar=phi,ma=theta)
  y <- arima.sim(n=no,model=mdl,sd=sd)
  plotARIMASample(p, d, q, y)
  return( y )
}

# 生成した標本をプロット
plotARIMASample <- function(p, d, q, y){
  title1 <- paste("ARIMA Model(",p,",",d,",",q,")", sep="")
  title2 <- "ar ="
  for(j in 1:p) {title2 <- paste(title2,phi[j]," ")}
  title3 <- "ma ="
  for(j in 1:q) {title3 <- paste(title3,theta[j]," ")}
  title2 <- paste(title2,title3)
  title <- c(title1,title2)
  plot(y,type="l",main=title)
}


generateARIMASample(phi, d, theta)

# 3つのパラメータを変化させながらプロットし、並べて表示
par(mfrow=c(4,3))
generatedSamples.101 <- (generateARIMASample(c(0.1),      0, c(0.1)))
generatedSamples.201 <- (generateARIMASample(c(0.1, 0.1), 0, c(0.1)))
generatedSamples.102 <- (generateARIMASample(c(0.1),      0, c(0.1, 0.1)))
generatedSamples.202 <- (generateARIMASample(c(0.1, 0.1), 0, c(0.1, 0.1)))
generatedSamples.111 <- (generateARIMASample(c(0.1),      1, c(0.1)))
generatedSamples.211 <- (generateARIMASample(c(0.1, 0.1), 1, c(0.1)))
generatedSamples.112 <- (generateARIMASample(c(0.1),      1, c(0.1, 0.1)))
generatedSamples.212 <- (generateARIMASample(c(0.1, 0.1), 1, c(0.1, 0.1)))
generatedSamples.121 <- (generateARIMASample(c(0.1),      2, c(0.1)))
generatedSamples.221 <- (generateARIMASample(c(0.1, 0.1), 2, c(0.1)))
generatedSamples.122 <- (generateARIMASample(c(0.1),      2, c(0.1, 0.1)))
generatedSamples.222 <- (generateARIMASample(c(0.1, 0.1), 2, c(0.1, 0.1)))
par(mfrow=c(1,1))
```

### 1.2.原系列および基本統計量をプロット

```r
#  ACF: 標本自己相関関数
#  PACF:標本偏自己相関関数
tsdisplay(generatedSamples.101)
acf(generatedSamples.111)
pacf(generatedSamples.111)
# pdf("plot.pdf"); tsdisplay(tsdata.train); dev.off()
```

### 1.3.単位根検定

```r
PP.test(generatedSamples.111)$p.value
PP.test(generatedSamples.211)$p.value
PP.test(generatedSamples.112)$p.value
PP.test(generatedSamples.212)$p.value
PP.test(generatedSamples.121)$p.value
PP.test(generatedSamples.221)$p.value
PP.test(generatedSamples.122)$p.value
PP.test(generatedSamples.222)$p.value
PP.test(generatedSamples.131)$p.value

tryCatch({
  PP.test(generatedSamples.111)
},
error = function(e) {    # e にはエラーメッセージが保存されている
  PP.test(na.remove(generatedSamples.111))
},
warning = function(e) {  # e には警告文が保存されている
  PP.test(na.remove(generatedSamples.111))
},
silent = TRUE
)
#
# Phillips-Perron Unit Root Test
#
# Dickey-Fuller = -2.1067, Truncation lag parameter = 4, p-value = 0.5314
```

p値が0.53なので帰無仮説「単位根が存在する」は棄却されない
→単位根過程

|確率過程|   |   |
|:---|:---|:---|
| 定常過程 | | 平均回帰的・自己相関は減衰・トレンドを持たない |
| 非定常過程 | | 対数系列が線形トレンドを持つ |
| | 単位根過程 | 原系列は非定常過程、階差系列は定常過程 |

### 1.4.forecastパッケージのARIMAモデルで分析

```r
result.arima.111 <- auto.arima(
  generatedSamples.111, # 対象データ
  ic="aic", # 情報量基準としてaic(または aicc, bic を使用)
  trace=T, # 処理の経過を出力させる
  stepwise=F, # 計算を簡略化する
  approximation=F,
  start.p=0,
  start.q=0,
  start.P=0,
  start.Q=0,
  seasonal=F # 季節調整済みARIMAモデル
)

# auto.arima関数で計算されなかった情報量基準を追加計算
result.arima.111.111 <- arima(
  generatedSamples.111,
  order=c(1,1,1),
  include.mean=F
)

# ARIMAモデルの評価
summary(result.arima.111)
summary(result.arima.111.111)

# 7期(=7日)先まで推定
# 50%信頼区間, 95%信頼区間
forecast.arima.111 <- forecast(result.arima.111,range=c(50,95),h=7)
forecast.arima.111.111 <- forecast(result.arima.111.111,range=c(50,95),h=7)

# 推定結果をプロット
plot(forecast.arima.111)
plot(forecast.arima.111.111)

forecast.arima.111$fitted
```

# 2.CO2データセットに対する予測

## 2.1.データの準備

```r
data(co2)
# CSVファイルを読み込む(ローカルでの作業用)
# co2 <- read.csv("co2.csv", header = TRUE, stringsAsFactors = FALSE, row.names="year")

# 評価用データ以外を抽出してtsクラスのオブジェクトとして格納
tsdata.train <- ts(co2, end=c(1989, 12), frequency=12) # frequency:1年分のデータの要素数
# tsクラスのオブジェクトか判定
is.ts(co2)
# [1] TRUE
class(co2)
# [1] "ts"
attr(co2,"tsp")
# [1] 1959.000 1997.917   12.000 # 開始年月, 終了年月, 1年のうちのデータ頻度
# データセットco2はもともとtsクラスのオブジェクトとして保存されているため、window関数で直接抽出することも可能

# 全体
tsdata <- co2
```

## 2.2.部分時系列の切り出し・学習データ作成

```r
# 学習用
tsdata.train <- window(tsdata, end=c(1989, 12), frequency=12)
tail(tsdata.train)

# 評価用
tsdata.ans <- window(tsdata, start=c(1990, 1), frequency=12)
head(tsdata.ans)



# 部分時系列をwindows関数で抽出
tsdata.1970 <- window(co2, start=c(1970, 1), end=c(1985, 12)) # 1970年～
tsdata.1980 <- window(co2, start=c(1980, 1), end=c(1995, 12)) # 1980年～
tsdata.union <- ts.union(tsdata.1970, tsdata.1980)      # 合併
tsdata.inter <- ts.intersect(tsdata.1970, tsdata.1980)  # 共通範囲

# 時系列データを長期変動・季節変動・不規則変動に分解
tsdata.decomposed <- decompose(tsdata)
plot(tsdata.decomposed$x)
plot(tsdata.decomposed$trend)     # 長期変動
plot(tsdata.decomposed$seasonal)  # 季節変動
plot(tsdata.decomposed$random)    # 不規則変動
#  または
tsdata.stl<-stl(tsdata,s.window="periodic")
plot(tsdata.stl)
```

## 2.3.原系列のプロット・単位根検定

```r
# モデル化(情報量基準が最小のときのパラメーターを使用)
install.packages("quadprog")
install.packages("forecast", dependencies=T)

# forecastパッケージ(デフォルトでインストール済)の読み込み
library(forecast)

# 原系列および基本統計量をプロット
#  ACF: 標本自己相関関数
#  PACF:標本偏自己相関関数
tsdisplay(tsdata.train)
# pdf("plot.pdf")
# tsdisplay(tsdata.train)
# dev.off()
```

```r
# 単位根検定
tryCatch({
  PP.test(tsdata.train)
},
error = function(e) {    # e にはエラーメッセージが保存されている
  PP.test(na.remove(tsdata.train))
},
warning = function(e) {  # e には警告文が保存されている
  PP.test(na.remove(tsdata.train))
},
silent = TRUE
)
#
# Phillips-Perron Unit Root Test
#
# data:  na.remove(tsdata.train)
# Dickey-Fuller = -6.3046, Truncation lag parameter = 5, p-value = 0.01
# 帰無仮説「単位根が存在する」は棄却
# →単位根過程でない
# 定常過程：　平均回帰的・自己相関は減衰・トレンドを持たない
# 非定常過程：対数系列が線形トレンドを持つ
# 　単位根過程：原系列は非定常過程、階差系列は定常過程
```

### 2.4.forecastパッケージのARIMAモデルで分析

```r
# forecastパッケージ(デフォルトでインストール済)の
# ARIMAモデルで分析
result.arima <- auto.arima(
  tsdata.train, # 対象データ
  ic="aic", # 情報量基準としてaic(または aicc, bic を使用)
  trace=T, # 処理の経過を出力させる
  stepwise=F, # 計算を簡略化する
  approximation=F,
  start.p=0,
  start.q=0,
  start.P=0,
  start.Q=0,
  seasonal=F # 季節調整済みARIMAモデル
)

# auto.arima関数で計算されなかった情報量基準を追加計算
# ARIMA(2,1,3)                    : Inf
arima(
  tsdata.train,
  order=c(2,1,3),
  include.mean=F
)
#
# Call:
#   arima(x = tsdata.train, order = c(2, 1, 3), include.mean = F)
#
# Coefficients:
#   ar1      ar2      ma1     ma2     ma3
# 1.7162  -0.9834  -1.3819  0.1814  0.4089
# s.e.  0.0086   0.0085   0.0424  0.0750  0.0413
#
# sigma^2 estimated as 0.3093:  log likelihood = -312.08,  aic = 636.16
# 別のデータセットの例を示すが、以下の場合はパラメータを追加する必要がある
# ARIMA(0,0,1) with zero mean     : Inf
# ARIMA(0,0,1) with non-zero mean : 950.2516
# > arima(
# +   tsdata.train,
# +   order=c(0,0,1)
# + )
#
# Call:
#   arima(x = tsdata.train, order = c(0, 0, 1))
#
# Coefficients:
#   ma1  intercept
# 0.6027  1705.1063
# s.e.  0.1349    53.6708
#
# sigma^2 estimated as 76264:  log likelihood = -472.13,  aic = 950.25
# > arima(
#   +   tsdata.train,
#   +   order=c(0,0,1),
#   +   include.mean = T
#   + )
#
# Call:
#   arima(x = tsdata.train, order = c(0, 0, 1), include.mean = T)
#
# Coefficients:
#   ma1  intercept
# 0.6027  1705.1063
# s.e.  0.1349    53.6708
#
# sigma^2 estimated as 76264:  log likelihood = -472.13,  aic = 950.25
# > arima(
#   +   tsdata.train,
#   +   order=c(0,0,1),
#   +   include.mean =F
#   + )
#
# Call:
#   arima(x = tsdata.train, order = c(0, 0, 1), include.mean = F)
#
# Coefficients:
#   ma1
# 1.0000
# s.e.  0.0962
#
# sigma^2 estimated as 827424:  log likelihood = -555.01,  aic = 1114.03
```

### 2.5.ARIMAモデルの評価

```r
summary(result.arima)
# Series: tsdata.train
# ARIMA(0,1,3)(0,1,1)[12]
#
# Coefficients:
#           ma1      ma2      ma3     sma1
#       -0.3504  -0.0161  -0.0967  -0.8597
# s.e.   0.0533   0.0559   0.0519   0.0325
#
# sigma^2 estimated as 0.08407:  log likelihood=-63.16
# AIC=136.32   AICc=136.49   BIC=155.74
#
# Training set error measures:
#                      ME      RMSE       MAE         MPE       MAPE      MASE       ACF1
# Training set 0.02431332 0.2832465 0.2244853 0.00711694 0.06781885 0.1817613 0.008491678

# 残差分析
#  (上)残差のプロット
#  (中)残差の自己相関のプロット
#  (下)引数gof.lagに対応するLjung-Box検定のp値のプロット
tsdiag(result.arima)

# # tsdiag関数で Error in plot.new() : figure margins too large
# # というエラーが出る場合、画面サイズを変更する(RStudio)かpdfファイルに出力するとよい
# pdf("plot.pdf")
# tsdiag(result.arima)
# dev.off()
```

### 2.6.予測結果の評価

```r
# 96期(=8年)先まで推定
# 50%信頼区間, 95%信頼区間
forecast.arima <- forecast(result.arima,range=c(50,95),h=96)

# 推定結果をプロット
plot(forecast.arima)

# 実データと比較するためのプロット
lim.x <- c(
  min( c( start(tsdata.train)[1], start(tsdata.ans)[1] ), na.rm=TRUE )-10,
  max( c( end(tsdata.train)[1], end(tsdata.ans)[1] ), na.rm=TRUE )+10
)
lim.y <- c(
  min( c( tsdata.train, tsdata.ans, forecast.ar$mean ), na.rm=TRUE )-10,
  max( c( tsdata.train, tsdata.ans, forecast.ar$mean ), na.rm=TRUE )+10
)
plot(forecast.arima, xlim=lim.x, ylim=lim.y, ann=F, col="blue")
par(new=T)
plot(tsdata.ans, xlim=lim.x, ylim=lim.y, col="plum1")
# plot(tsdata.train, xlim=lim.x, ylim=lim.y, ann=F, col="red")
# par(new=T)
# plot(tsdata.ans, xlim=lim.x, ylim=lim.y, ann=F, col="plum1")
# par(new=T)
# plot(forecast.arima$mean, xlim=lim.x, ylim=lim.y, col="blue")

transform.arima <- transform(as.data.frame(forecast.arima), y=paste(1990:1997,"/",1:12), ans=tsdata.ans)
head(transform.arima)
```

---

Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.

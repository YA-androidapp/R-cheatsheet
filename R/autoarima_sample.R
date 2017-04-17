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

# 生成した標本をプロットする
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

# 原系列および基本統計量をプロット
#  ACF: 標本自己相関関数
#  PACF:標本偏自己相関関数
tsdisplay(generatedSamples.101)
acf(generatedSamples.111)
pacf(generatedSamples.111)
# pdf("plot.pdf"); tsdisplay(tsdata.train); dev.off()

# 単位根検定
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
# p値が0.53なので帰無仮説「単位根が存在する」は棄却されない
# →単位根過程
# 定常過程：　平均回帰的・自己相関は減衰・トレンドを持たない
# 非定常過程：対数系列が線形トレンドを持つ
# 　単位根過程：原系列は非定常過程、階差系列は定常過程

# forecastパッケージ(デフォルトでインストール済)の
# ARIMAモデルで分析
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

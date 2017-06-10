# R cheatsheet (教師なし学習編)

## 目次

1. クラスタリング

---

## 1.クラスタリング

### 1.1.評価用関数の用意

```r
# エントロピーを算出
calcEntropy <- function(
  ct # クロス集計表
  ){
  -sum( (apply(ct,1,sum)/sum(ct)) * apply(ct,1,calcEntropy0))/log(ncol(ct))
}
calcEntropy0<-function(pv){
  p1<-pv/sum(pv)
  p2<-p1[p1 !=0]
  sum(p2*log(p2))
}

# 純度を算出
calcPurity <-function(
  ct # クロス集計表
  ){
  sum(apply(ct,1,max))/sum(ct)
}

calckmeans <- function(
  x,              # データセット
  clsnum,         # クラスタ数
  meth="Hartigan-Wong" # メソッド
  ){
  return(
    kmeans(
      x, # データ
      clsnum,
      iter.max=10, # 繰り返し最大数
      nstart=1, # 初期中心
      algorithm = meth
    )
  )
}

# 評価指標の算出
evalclust <- function(result, answer){
  ct <- table(answer, result) #クロス表の作成
  cat("Entropy: ", calcEntropy(ct), "\n") #エントロピー
  cat("Purity : ", calcPurity(ct), "\n")  #純度
}
```

### 1.2.データの読み込み

```r
x <- iris[,1:4]
```

### 1.3.クラスタリングとプロット

```r
# 最適なkの値を算出
library(cluster)
result.gap <- clusGap(x, kmeans, K.max = clsnum * 2, B = 100, verbose = interactive())
plot(result.gap)
clsnum <- with(result.gap,maxSE(Tab[,"gap"],Tab[,"SE.sim"]))

 # gap.range <- range(result.gap$Tab[,"gap"])
 # lines(rep(which.max(result.gap$Tab[,"gap"]),2),gap.range, col="blue", lty=2)

# クラスタリング用関数の用意
km.hw<-kmeans(x, clsnum, algorithm = "Hartigan-Wong")
km.ll<-kmeans(x, clsnum, algorithm = "Lloyd")
km.fo<-kmeans(x, clsnum, algorithm = "Forgy")
km.mq<-kmeans(x, clsnum, algorithm = "MacQueen")



# ここから分類結果の確認
ctitems <- as.list(NULL)
for(i in 1:nrow(km$centers)){
    item <- subset(x, cluster == i, 'LABEL')
    ctitems[[i]] <- item[order(-item[, 'LABEL']), ]
}
 # ここまで分類結果の確認
```

```r
# プロット

# 解析データの特徴量が2列以上の時
x <- x[,c("Sepal.Length", "Sepal.Width")]
plot(x, col = km.hw$cluster)
points(km.hw$centers, col = 1:(length(km.hw$centers)), pch = 8)

# 解析データの特徴量が3列以上で、複数の特徴量同士の図を出力させる時
#  クラスタの重心をプロットできない
plot(x, col = km.hw$cluster)

# 解析データの特徴量が3列以上で、特徴量を2つだけ抽出して図を出力させる時
plot(x[,c("Sepal.Length", "Sepal.Width")], col = km.hw$cluster)
points(km.hw$centers[,c("Sepal.Length", "Sepal.Width")], col = 1:(length(km.hw$centers)), pch = 8)



op <- par(mfrow=c(2,2), pin = c(1,1)) # 2行2列
plot(km.hw$cluster, main="Hartigan-Wong法")

# Error in plot.new() : figure margins too large
# http://stackoverflow.com/questions/12766166/error-in-plot-new-figure-margins-too-large-in-r
par(mar = rep(2, 4))

plot(km.ll$cluster, main="Lloyd法")
plot(km.fo$cluster, main="Forgy法")
plot(km.mq$cluster, main="MacQueen法")
par(op)
```

```r
# 各手法でのクラスタリング
km.hw<-calckmeans(x, 3, meth = "Hartigan-Wong")
km.ll<-calckmeans(x, 3, meth = "Lloyd")
km.fo<-calckmeans(x, 3, meth = "Forgy")
km.mq<-calckmeans(x, 3, meth = "MacQueen")
```

```r
# 評価
ans <- iris[,5]
evalclust(km.hw$cluster,ans)
# Entropy:  0.2790808
# Purity :  0.86
evalclust(km.ll$cluster,ans)
# Entropy:  0.2308662
# Purity :  0.8933333
evalclust(km.fo$cluster,ans)
# Entropy:  0.2308662
# Purity :  0.8933333
evalclust(km.mq$cluster,ans)
# Entropy:  0.2308662
# Purity :  0.8933333
```

## 2.階層的クラスター分析

```r
calchclust <- function(
  x, # データセット
  clsnum, # クラスタ数
  meth="complete" # メソッド
  ){
  d2 <- dist(x)^2 # ユークリッド平方距離
  switch(meth,    # 初期距離行列の設定
         "ward"		  = d <- d2,  # ウォード法の場合：  ユークリッド平方距離
         "centroid"   = d <- d2,  # 重心の場合：        ユークリッド平方距離
         "median"	  = d <- d2,  # メディアン法の場合：ユークリッド平方距離
         d <- dist(x)             # その他の場合：      ユークリッド距離
  )
  hc <- hclust(d, method = meth) # meth手法でのクラスタリング
  ct  <- cutree(hc,k=clsnum) # clsnum個のクラスタに分割

 # ここから分類結果の確認
 x[, 'cluster'] <- ct

 ctitems <- as.list(NULL)
 for(i in 1:clsnum){
  item <- subset(x, cluster == i, 'LABEL') # 第三引数(LABEL)には元データでIDを示すような列名を入れる
  ctitems[[i]] <- item[order(-item), ]
 }
 plot(hc, labels=as.character(x[, 1]))
 rect.hclust(hc, k=clsnum)
 # ここまで分類結果の確認

  return(ct) # クラスタ群を返す
}

x <- iris[,1:4] # 解析データ：iris 1-4列のデータ
# 階層的クラスタリングではデータ同士／クラスタ同士の距離をもとに分割するため
# 始めに距離行列を求めておく必要がある
d <- dist(x)    # 距離行列の作成
d2 <- dist(x)^2 # ユークリッド平方距離
hc.aver <- hclust(d,"average")   # 群平均法
hc.sngl <- hclust(d,"single")    # 単連結法
hc.comp <- hclust(d, "complete") # 完全連結法
hc.ward <- hclust(d2,"ward.D")   # ウォード法
hc.cntr <- hclust(d2,"centroid") # 重心法
hc.medi <- hclust(d2,"median")   # メディアン法

op <- par(mfrow=c(2,3)) # Graphic parameter設定：2行3列

# Error in plot.new() : figure margins too large
# http://stackoverflow.com/questions/12766166/error-in-plot-new-figure-margins-too-large-in-r
par(mar = rep(2, 4))

plot(hc.aver, main="群平均法")
plot(hc.sngl, main="単連結法")
plot(hc.comp, main="完全連結法")
plot(hc.ward, main="ウォード法")
plot(hc.cntr, main="重心法")
plot(hc.medi, main="メディアン法")
par(op) # 作業前のGraphic Parameterに戻す

# 各手法でのクラスタリング
hcc.aver <- calchclust(x,clsnum=3,meth="average")  # 群平均法
hcc.sngl <- calchclust(x,clsnum=3,meth="single")   # 単連結法
hcc.comp <- calchclust(x,clsnum=3)                 # 完全連結法
hcc.ward <- calchclust(x,clsnum=3,meth="ward.D")   # ウォード法
hcc.cntr <- calchclust(x,clsnum=3,meth="centroid") # 重心法
hcc.medi <- calchclust(x,clsnum=3,meth="median")   # メディアン法

# 評価
ans <- iris[,5] #
evalclust(hcc.aver,ans) # 群平均法
# Entropy:  0.1799098
# Purity :  0.9066667
evalclust(hcc.sngl,ans) # 単連結法
# Entropy:  0.05095645
# Purity :  0.9866667
evalclust(hcc.comp,ans) # 完全連結法
# Entropy:  0.2390843
# Purity :  0.84
evalclust(hcc.ward,ans) # ウォード法
# Entropy:  0.1799098
# Purity :  0.9066667
evalclust(hcc.cntr,ans) # 重心法
# Entropy:  0.1799098
# Purity :  0.9066667
evalclust(hcc.medi,ans) # メディアン法
# Entropy:  0.173873
# Purity :  0.9133333
```

---

Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.

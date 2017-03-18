# R cheatsheet (回帰分析編)

## 目次

1. 線形回帰分析

---

## 1.線形回帰分析

### 1.1.データの準備

```r
# データを読込み
data(iris)
data <- iris[iris$Species=="versicolor", ]

# ソートする
sortlist <- order(data$Sepal.Length)
data <- data[sortlist,]

# 行番号を修正する
rownames(data) <- c(1:nrow(data))
```

### 1.2.データの確認

```r
# データ構造を確認
str(data)
```

> 'data.frame':	50 obs. of  5 variables:
>
> $ Sepal.Length: num  7 6.4 6.9 5.5 6.5 5.7 6.3 4.9 6.6 5.2 ...
>
> $ Sepal.Width : num  3.2 3.2 3.1 2.3 2.8 2.8 3.3 2.4 2.9 2.7 ...
>
> $ Petal.Length: num  4.7 4.5 4.9 4 4.6 4.5 4.7 3.3 4.6 3.9 ...
>
> $ Petal.Width : num  1.4 1.5 1.5 1.3 1.5 1.3 1.6 1 1.3 1.4 ...
>
> $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 2 2 2 2 2 2 2 2 2 2 ...

```r
# 基礎統計量を確認
by(data$Sepal.Width, data$Sepal.Length, summary)
```

>
> data$Sepal.Length: 4.9
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>     2.4     2.4     2.4     2.4     2.4     2.4
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 5
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>   2.000   2.075   2.150   2.150   2.225   2.300
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 5.1
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>     2.5     2.5     2.5     2.5     2.5     2.5
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 5.2
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>     2.7     2.7     2.7     2.7     2.7     2.7
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 5.4
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>       3       3       3       3       3       3
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 5.5
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>    2.30    2.40    2.40    2.44    2.50    2.60
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 5.6
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>    2.50    2.70    2.90    2.82    3.00    3.00
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 5.7
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>    2.60    2.80    2.80    2.82    2.90    3.00
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 5.8
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>   2.600   2.650   2.700   2.667   2.700   2.700
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 5.9
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>    3.00    3.05    3.10    3.10    3.15    3.20
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 6
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>   2.200   2.575   2.800   2.800   3.025   3.400
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 6.1
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>   2.800   2.800   2.850   2.875   2.925   3.000
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 6.2
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>   2.200   2.375   2.550   2.550   2.725   2.900
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 6.3
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>     2.3     2.4     2.5     2.7     2.9     3.3
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 6.4
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>   2.900   2.975   3.050   3.050   3.125   3.200
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 6.5
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>     2.8     2.8     2.8     2.8     2.8     2.8
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 6.6
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>   2.900   2.925   2.950   2.950   2.975   3.000
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 6.7
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>   3.000   3.050   3.100   3.067   3.100   3.100
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 6.8
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>     2.8     2.8     2.8     2.8     2.8     2.8
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 6.9
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>     3.1     3.1     3.1     3.1     3.1     3.1
>
> ---------------------------------------------------------------------------
>
> data$Sepal.Length: 7
>
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>     3.2     3.2     3.2     3.2     3.2     3.2

```r
# データの相関係数表を確認
cor.test(data$Sepal.Width, data$Sepal.Length)
```

>
>
>
>         Pearson's product-moment correlation
>
>
>
> data:  data$Sepal.Width and data$Sepal.Length
>
> t = 4.2839, df = 48, p-value = 8.772e-05
>
> alternative hypothesis: true correlation is not equal to 0
>
> 95 percent confidence interval:
>
>  0.2900175 0.7015599
>
> sample estimates:
>
>       cor
>
> 0.5259107

### 1.3.回帰分析を実行

```r
data.lm <- lm(Sepal.Length ~ Sepal.Width, data=data)

# 結果を確認
summary(data.lm)
```

>
>
> Call:
>
> lm(formula = Sepal.Length ~ Sepal.Width, data = data)
>
>
>
> Residuals:
>
>      Min       1Q   Median       3Q      Max
>
> -0.73497 -0.28556 -0.07544  0.43666  0.83805
>
>
>
> Coefficients:
>
>               Estimate Std. Error t value Pr(>|t|)
>
> (Intercept)     3.5397     0.5629   6.289 9.07e-08 ***
>
>   Sepal.Width   0.8651     0.2019   4.284 8.77e-05 ***
>
>   ---
>
>   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
>
>
>
> Residual standard error: 0.4436 on 48 degrees of freedom
>
> Multiple R-squared:  0.2766,	Adjusted R-squared:  0.2615
>
> F-statistic: 18.35 on 1 and 48 DF,  p-value: 8.772e-05

回帰式は、Coefficients(係数)から求める。Interceptは定数項

>   Sepal.Length = 0.8651 * Sepal.Width + 3.5397
>
>  決定係数R2            1に近いほど回帰の当てはまりがよい
>
>  t値：t value          絶対値が大きいほど説明力がある
>
>  p値：Pr(>|t|)         値が小さいほど説明力がある。「*」の数が多いほどよい

#### データの散布図を出力

```r
plot ( data$Sepal.Width, data$Sepal.Length, cex=0.4, main="Sepal.Length ~ Sepal.Width", xlim=c(0,6), ylim=c(0,8) )

# 回帰直線を出力
abline( data.lm, col = "red", lwd=1 )
```

#### 残差の分布図を出力

```r
plot ( data$Sepal.Width, residuals( data.lm ), cex=0.4, main="Sepal.Width, Residual", xlim=c(0,6), ylim=c(-3,3), yaxp=c(0, 6, 12), yaxp=c(-3, 3, 12))
```

#### 回帰診断図を出力

```r
par(mfrow=c(2,2))
plot(data.lm)
#  左上：残差の偏りをチェック
#  右上：データの正規性をチェック
#  左下：残差の変動をチェック
#  左下：モデルの当てはまりへの影響力をチェック
```

#### 箱ひげ図を表示

```r
boxplot(
  data$Sepal.Length ~ data$Sepal.Width,# データ
  #names    = c("", "", ""),           # 項目名
  border   = "orange",                 # ボックス枠線の色
  col      = "lightyellow",            # ボックス内部の塗り色
  varwidth = TRUE                      # データの個数をボックス幅で表現
)
```

#### 平均値±標準偏差

```r
library(gplots)
gplots::plotmeans(data$Sepal.Length ~ data$Sepal.Width, error.bars="se")
```

#### 予測を実行

```r
data.predict <- predict(data.lm)
```

#### 予測値を出力

```r
plot(
  data,
  xlim=c(min(data$Sepal.Width)-1, max(data$Sepal.Width)+1),
  ylim=c(min(data$Sepal.Length)-1, max(data$Sepal.Length)+1)
)
```

#### 信頼区間を出力

```r
data.conf <- as.data.frame(predict(data.lm, interval="confidence", level=0.95))
```

#### 予測区間を出力

```r
data.preint <- as.data.frame(predict(
  data.lm,
  newdata=data.frame(Sepal.Width=data$Sepal.Width), # data自体に含まれている列名を指定する必要がある
  interval="prediction",
  level=0.95
))

clearPlots()
plot(
  data$Sepal.Width,
  data$Sepal.Length,
  xlim=c(min(data$Sepal.Width)-1, max(data$Sepal.Width)+1),
  ylim=c(min(data$Sepal.Length)-1, max(data$Sepal.Length)+1),
  axes=T, xlab="Sepal.Width", ylab="Sepal.Length"
)
```

#### 出力対象のグラフ

```r
graphs <- cbind(
  data.conf$fit,   # 回帰直線
  data.conf$upr,   # 信頼区間の上側
  data.conf$lwr,   # 信頼区間の下側
  data.preint$upr, # 予測区間の上側
  data.preint$lwr  # 予測区間の下側
)
lcolors <- c(2, 4, 4, 5, 5)
xx <- seq(0, 5, length=100)
for (g in 1:length(graphs[1,])) {
  sp <- smooth.spline(data$Sepal.Width,graphs[,g])
  pred <- predict(sp, xx)
  lines(pred, col=lcolors[g])
}

data.frame(data$Sepal.Width,data.conf$fit)
```

---

Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.

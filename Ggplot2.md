---
title: "ggplot2"
author: "(c) 2017 YA <ya.androidapp@gmail.com>"
output: html_notebook
---


# ggplot2パッケージの読込み

[ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html)パッケージを読込む

```{r}
library(ggplot2)
```

# quickplot

## 散布図

```{r}
library(ggplot2)
data(diamonds)
names(diamonds)

# 基本
qplot(diamonds$carat, diamonds$price)

# データフレームの各列を抽出する場合はdataパラメータを使用すると
# 凡例や軸ラベルにデータフレーム名を表示しなくなる
qplot(carat, price, data = diamonds)

# 対数グラフ
qplot(log(carat), log(price), data = diamonds)

# 色分け
qplot(carat, price, data = diamonds,
      alpha = I(1/10),  # 透明度
      colour = clarity, # プロットの色分け
      shape = cut       # プロットの形
      )

# 条件付き散布図
qplot(carat, price, data = diamonds, facets = ~ cut)

# 近似曲線を追加する
qplot(carat, price, data = diamonds, facets = ~ cut,
      geom = c("point", "smooth")
      )
```

### グラフを画像ファイルとして保存する

```{r}
result <- qplot(carat, price, data = diamonds)

# 画面上とファイルの双方に出力する
print(result) # 画面出力
ggsave(file = "result.png", plot = result) # ファイル出力

# 出力解像度・サイズの変更
ggsave(file = "result.png", plot = result, dpi = 300, width = 5, height = 5)
```

| filetype |
| -------- |
| bmp |
| eps/ps |
| jpeg |
| pdf |
| png |
| svg |
| tex |
| tiff |
| wmf |

## 折れ線グラフ

```{r}

library(ggplot2)
data(diamonds)
names(diamonds)

dia.x <- 1:100
dia.y <- diamonds$y[1:100]

# 基本
qplot(dia.x, dia.y, geom = "line")

# デザインを変更して描画する
windowsFonts("MR"=windowsFont("Meiryo")) #
g <- g + theme_bw(
  base_size = 24,    # フォントサイズを指定する
  base_family = "MR" # フォントを指定する
  )
plot(g)
```

## 棒グラフ

```{r}
library(ggplot2)
data(diamonds)
names(diamonds)

dia.c <- diamonds$cut

# 基本
qplot(dia.c, geom = "bar", stat = "identity")
```

## ヒストグラム

```{r}
library(ggplot2)
data(diamonds)
names(diamonds)

dia.c <- diamonds$carat

# ヒストグラム
qplot(dia.c, geom = "histogram",
      binwidth = 0.1 # 階級幅の調節
      )

# 密度プロット
qplot(dia.c, geom = "density")
```

## 箱ひげ図

```{r}
library(ggplot2)
data(diamonds)
names(diamonds)

# 基本
qplot(cut, price, data = diamonds, geom = "boxplot")
```

# ggplot

## ggplotを用いた作図の手順

1. ```ggplot()```関数で新たなレイヤーを確保する
2. 描画するグラフの種類を指定する
3.

## 散布図

```{r}
# ggplot2パッケージの読込み
library(ggplot2)

# womenデータセットを読込む
data(women)

# 作図したいデータセットを読込み、グラフエリアを用意する
g <- ggplot(
  women, # 描画対象のデータフレームを指定する
  aes(
    x = height, # x軸にheight列を使用する
    y = weight  # y軸にweight列を使用する
  )
)

# プロットの設定を行い、重ねて描画する
g <- g + geom_point(
  na.rm = TRUE, # NAを無視する
  shape = 20,   # プロットの形を指定する
  size = 0.8,   # プロットのサイズを指定する

  # 全てのプロットに対してではなく、軸ごとに設定を行いたい場合にはaes()を使用する
  aes(
    # プロットの色を指定
    color = height           # 連続量に対しグラデーションを指定する
    # color = factor(height) # 連続量に対し離散的な色分けを指定する
  )
)

# 回帰直線を描画する
g <- g + geom_smooth(
  method = "lm" # 線形回帰で求める
)

# タイトルを追加する
g <- g + xlab("身長")      # x軸
g <- g + ylab("体重")      # y軸
g <- g + ggtitle("散布図") # グラフ

plot(g)

# デザインを変更して描画する
windowsFonts("MR"=windowsFont("Meiryo")) #
g <- g + theme_bw(
  base_size = 24,    # フォントサイズを指定する
  base_family = "MR" # フォントを指定する
  )
plot(g)
```

## 折れ線グラフ

```{r}
# ggplot2パッケージの読込み
library(ggplot2)

# co2データセットを読込む
data(co2)
df <- data.frame(x = 1:length(co2), y = as.matrix(co2))

# 作図したいデータセットを読込み、グラフエリアを用意する
g <- ggplot(
  df, # 描画対象のデータフレームを指定する
  aes(
    x = x, # x軸にx列を使用する
    y = y  # y軸にy列を使用する
  )
)

# 折れ線グラフの設定を行い、重ねて描画する
g <- g + geom_line(
  linetype = 1,   # 線の形を指定する
  size = 0.8,     # 線の太さを指定する
  color = "blue" # 線の色を指定
)

# 回帰直線を描画する
g <- g + geom_smooth(
  method = "lm",    # 線形回帰で求める
  color = "orange" # 線の色を指定
)

# タイトルを追加する
g <- g + xlab("No.")       # x軸
g <- g + ylab("ppm")       # y軸
g <- g + ggtitle("折れ線") # グラフ

plot(g)
```

## 棒グラフ

### 度数で集計

```{r}
# ggplot2パッケージの読込み
library(ggplot2)
data(diamonds)
dia.c <- diamonds$cut

# 作図したいデータセットを読込み、グラフエリアを用意する
g <- ggplot(
  diamonds, # 描画対象のデータフレームを指定する
  aes(cut) # 度数を数え上げる対象とする列を指定する
)

# 棒グラフを描画する
g <- g + geom_bar()

# タイトルを追加する
g <- g + xlab("Cut")       # x軸
g <- g + ylab("Count")       # y軸
g <- g + ggtitle("棒") # グラフ

plot(g)
```

### データを要約して集計

```{r}
# ggplot2パッケージの読込み
library(ggplot2)
data(diamonds)
dia.c <- diamonds$cut

# 作図したいデータセットを読込み、グラフエリアを用意する
g <- ggplot(
  diamonds, # 描画対象のデータフレームを指定する
  aes( # データを集計する際に要約する列を指定する
    y = price, #
    x = cut    # cutの種類ごとに、priceの統計量を求める
  )
)

# 棒グラフを描画する
g <- g + stat_summary(fun.y=mean,geom="bar") # 求める統計量はmean(平均値)

# タイトルを追加する
g <- g + xlab("Cut")       # x軸
g <- g + ylab("Count")       # y軸
g <- g + ggtitle("棒") # グラフ

plot(g)
```

## ヒストグラム

```{r}
# ggplot2パッケージの読込み
library(ggplot2)

# randuデータセットを読込む
data(randu)

# データフレームの形を変換する
library(reshape2)
mdf <- melt(randu)
# melt()を通すことで、variable列とvalue列が生成される

# 作図したいデータセットを読込み、グラフエリアを用意する
g <- ggplot(
  mdf, # 描画対象のデータフレームを指定する
  aes(
    fill = variable, # fillで領域内の塗りつぶし色を指定する
    x = value # x軸にvalue列を使用する
  )
)

# ヒストグラムの設定を行い、重ねて描画する
# g <- g + geom_histogram()

# 列ごとに描画する場合は代わりに以下の通りとする
g <- g + geom_histogram(
  alpha = 0.5,          # 透明度を指定する
  # binwidth = 10,        # 階級幅を指定する
  position = "identity" # 列ごとに描画する
)

# 密度曲線を描画する
g <- g + geom_density(alpha = 0)

plot(g)
```

## 箱ひげ図(ボックスプロット)

```{r}
# ggplot2パッケージの読込み
library(ggplot2)

# irisデータセットを読込む
data(iris)

# データフレームの形を変換する
library(reshape2)
mdf <- melt(iris)
# melt()を通すことで、variable列とvalue列が生成される

# 作図したいデータセットを読込み、グラフエリアを用意する
g <- ggplot(
  mdf, # 描画対象のデータを指定する
  aes(
    x = Species, # x軸にSpecies列を使用する
    y = value    # y軸にvalue列を使用する
  )
)

g <- g + facet_wrap( # 特徴量ごとに異なる、複数グラフを描画
  ~variable, # variable列の値ごとに分割
  ncol = 2,  # グラフ領域の列数
  scales = "free" ## 各々のグラフごとに最適な軸を設定する
  )

## グラフの軸に任意のスケールを設定する
## g <- g + facet_wrap (~variable) + coord_cartesian(xlim = c(0, 1), ylim = c(250,1000))

# 箱ひげ図の設定を行い、描画する
g <- g + geom_boxplot()

# 個別のデータも重ねて描画する
g <- g + geom_jitter()

# タイトルを追加する
g <- g + xlab("Species")     # x軸
g <- g + ylab("value")       # y軸
g <- g + ggtitle("箱ひげ図") # グラフ

plot(g)
```






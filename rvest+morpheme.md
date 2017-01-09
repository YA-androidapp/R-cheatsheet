# Webページの簡易形態素解析

---

# 読み込み対象のWebページを指定

```r
curl <- "http://www.nikkei.com/"
```

# rvestを使わずにHTMLをダウンロード

```r
cdestfile <- "news.txt"
download.file(curl,cdestfile)
data <- read.table(
  cdestfile,
  encoding= "UTF-8",
  header=T,
  row.names=NULL,
  sep="\n"
  )
```

# rvestによるスクレイピング

```r
# install.packages("rvest")
library(rvest)
data <- read_html(curl)
# html_attr
# html_attrs
# html_children
# html_name
# html_text
```

## 全てのpタグの中身を得る

```r
src <- data %>%
  html_nodes(xpath = "//p") %>%
  # .[1:10] %>%
  html_text()
```

## (参考)先頭から10個のpタグの子要素を得る

```r
data %>%
  html_nodes(xpath = "//p") %>%
  .[1:10] %>%
  html_children()
```

## (参考)全てのimgタグのsrc属性を得る

```r
data %>%
  html_nodes(xpath = "//img") %>%
  html_attr("src")
```

## (参考)idで指定

```r
data %>%
  html_nodes("#CONTENTS") %>%
  html_text()
```

## (参考)classで指定

```r
data %>%
  html_nodes(".l-localNav_item") %>%
  html_text()
```

```r
src <- src[3]

print(src)
```

## 簡易形態素解析

```r
require(stringr)

# https://gist.github.com/mgng/6128903 を参考にさせていただきました
patterns <- c(
  '[\\x{2E80}-\\x{2FDF}\\x{3005}\\x{3007}\\x{3021}-\\x{3029}\\x{3038}-\\x{303B}\\x{3400}-\\x{4DBF}\\x{4E00}-\\x{9FFF}\\x{F900}-\\x{FAFF}\\x{20000}-\\x{2FFFF}]+',
  '[\\x{3041}-\\x{309F}\\x{31F0}-\\x{31FF}\\x{1B000}\\x{1B001}]+',
  '[\\x{30A0}-\\x{30FF}\\x{FF65}-\\x{FF9F}]+',
  '[\\x{FF10}-\\x{FF19}\\x{FF21}-\\x{FF3A}\\x{FF41}-\\x{FF5A}]+',
  '[\\x{0020}-\\x{007D}\\x{203E}\\s\\r\\n\\t]+',
  '[^\\x{0020}-\\x{007D}\\x{203E}\\s\\r\\n\\t\\x{FF10}-\\x{FF19}\\x{FF21}-\\x{FF3A}\\x{FF41}-\\x{FF5A}\\x{30A0}-\\x{30FF}\\x{FF65}-\\x{FF9F}\\x{3041}-\\x{309F}\\x{31F0}-\\x{31FF}\\x{1B000}\\x{1B001}\\x{2E80}-\\x{2FDF}\\x{3005}\\x{3007}\\x{3021}-\\x{3029}\\x{3038}-\\x{303B}\\x{3400}-\\x{4DBF}\\x{4E00}-\\x{9FFF}\\x{F900}-\\x{FAFF}\\x{20000}-\\x{2FFFF}]+'
)
locates <- stringr::str_locate_all(src, paste(patterns,sep="|"))

# 位置の一覧を取得する
locateMatrix <- matrix(0, nrow = 0, ncol = 2) # colnames<-c("start","end")
for (i in 1:(length(locates))) { # ORで区切られたパターンの部分の数
  if((length(locates[[i]])/2)>0){
    for (j in 1:(length(locates[[i]])/2)) { # それぞれのパターンについてマッチした数
      locateMatrix <- rbind(locateMatrix, locates[[i]][j,])
    }
  }
}
# 出現順にソート
locateMatrix <- locateMatrix[order(locateMatrix[,1]),]

# 一覧を出力
morphemeArray <- character()
for (i in 1:(nrow(locateMatrix))) {
  sstr <- substr(src, locateMatrix[i,1], locateMatrix[i,2])
  morphemeArray <- append(morphemeArray, sstr)
  print(sstr)
}

DF <- data.frame(morphemeArray)
```

---

Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.
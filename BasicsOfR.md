# R cheatsheet (基礎編)

## 目次

1. Web上の資料
1. 事前設定
1. ユーティリティ関数
1. 出力
1. データ型
1. 文法
1. 関数の定義
1. 数値計算
1. 文字列
1. ファイル操作

---

## 1.Web上の資料

* [R: The R Project for Statistical Computing](https://www.r-project.org/)

* [R-Tips](http://cse.naro.affrc.go.jp/takezawa/r-tips/r.html)
* [R による統計処理](http://aoki2.si.gunma-u.ac.jp/R/)
* [Rの初歩](https://oku.edu.mie-u.ac.jp/~okumura/stat/first.html)
* [R、R言語、R環境・・・・・・](http://mjin.doshisha.ac.jp/R/)

* [RPubs](https://rpubs.com/)

* [RjpWiki](http://www.okadajp.org/RWiki/)
* [朱鷺の杜Wiki](http://ibisforest.org/index.php?FrontPage)
* [Rに関する新着投稿 - Qiita](http://qiita.com/tags/R/items)

* [biostatistics](http://stat.biopapyrus.net/)

---

## 2.事前設定

### カレントディレクトリの設定

```r
setwd(paste(gsub("\\\\","/",Sys.getenv("USERPROFILE")),"/Documents/R",sep=""))
```

## 3.ユーティリティ関数

### 開発環境の諸々のクリア

```r
clearConsole = clc = function(){
    cat( "\014" )
}
clearObjects = function () {
    rm(list = ls(all.names = TRUE))
}
clearPlots = function () {
    if( dev.cur() > 1 ) dev.off()
}
clearWorkspace = function () {
    rm( list = ls( envir = globalenv() ), envir = globalenv() )
}
clearAll = function(){
    # コンソール
    clearConsole()
    # グラフ(プロット)
    clearPlots()
    # ワークスペース
    clearWorkspace()
    # オブジェクト
    clearObjects()
}
```

### ブロックコメント

```r
foo <- function(x, debug=0) { # 既定ではデバッグ用コードを実行しない(debug=0)
  ;
  if(debug==1) {
    ;
    #デバッグ用コード
  }
  ;
}

foo(x)    # 通常の関数呼び出し

foo(x, 1) # 第二引数に1を指定してデバッグ
```

## 4.出力

```r
x <- "ABCabc"
print( x )
```

> [1] "ABCabc"

```r
x <- as.Date("2016/01/01")
print( x )
print( x , quote=F )
```

> [1] "2016-01-01"
>
> [1] 2016-01-01

```r
x <- "1\\2\t3\n4\f5"
cat(x)
```

> 1\2 3
>
> 4
>
> (改ページ)
>
> 5

```r
page( VariableName )   # 別の枠に表示する
page( "VariableName" )
```

> 5

> 5

### 整形された文字列を得る

```r
sprintf("%d", 123)
sprintf("%05d", 123)
sprintf("%d", as.integer(123.4567))
```

> [1] "123"
>
> [1] "00123"
>
> [1] "123"

```r
sprintf("%a", 123.4567)
sprintf("%e", 123.4567)
sprintf("%f", 123.4567)
sprintf("%.3f", 123.4567)
sprintf("%5.1f", 123.4567)
sprintf("%g", 123.4567)
sprintf("%s", "123.4567")
```

> [1] "0x1.edd3a92a30553p+6"
>
> [1] "1.234567e+02"
>
> [1] "123.456700"
>
> [1] "123.457"
>
> [1] "123.5"
>
> [1] "123.457"
>
> [1] "123.4567"

### オブジェクトの情報を確認する

```r
str( x )
```

>  Date[1:1], format: "2016-01-01"

### データの統計量を確認する

```r
summary( x )
```

>         Min.      1st Qu.       Median         Mean      3rd Qu.         Max.
>
> "2016-01-01" "2016-01-01" "2016-01-01" "2016-01-01" "2016-01-01" "2016-01-01"

### オブジェクトにメモをつける

```r
x <- as.Date("2016/01/01")
comment(x) <- "BirthDay"
x
comment(x)
```

> [1] "2016-01-01"
>
> [1] "BirthDay"

## 5.データ型

### 変数

#### 代入と参照

```r
a <- 1
A <- 2 # 大文字と小文字は区別される
3 -> b
c = 4
assign("VariableName", 5)
```

```r
( a <- 6 ) # 代入と表示
```

> [1] 6

```r
objects() # 定義済オブジェクト一覧の取得
```

> [1] "a"            "A"            "b"            "c"            "VariableName"

```r
# オブジェクトの削除
rm(c)

# 全オブジェクトの削除
rm(list=ls(all=TRUE))
```

#### 型の検査

```r
checkv <- function(x){
  if(is.null(x)){
    print("NULL(無効値)か?:TRUE")
  } else {
    print(
      paste(
        x, " ||| ",
        "NA(欠損値)か?:",is.na(x)," | ",
        "NaN(非数)か?:",is.nan(x)," | ",
        "無限か?:",is.infinite(x)," | ",
        "有限値か?:",is.finite(x)," | ",
        "欠損がないか?:",complete.cases(x),
        sep=""
      )
    )
  }
}

# NULL
x <- c()
checkv(x)

x <- NA
checkv(x)

# NAを一部の要素に含むベクトル
x <- c(NA, 1, 2, 3)
is.na(x)

# NaN
x <- 0 / 0
checkv(x)

# Inf
x <- 1 / 0
checkv(x)

# 複素数
x <- 1 + 1i
checkv(x)
```

> [1] "NULL(無効値)か?:TRUE"
>
> [1] "NA ||| NA(欠損値)か?:TRUE | NaN(非数)か?:FALSE | 無限か?:FALSE | 有限値か?:FALSE | 欠損がないか?:FALSE"
>
> [1]  TRUE FALSE FALSE FALSE
>
> [1] "NaN ||| NA(欠損値)か?:TRUE | NaN(非数)か?:TRUE | 無限か?:FALSE | 有限値か?:FALSE | 欠損がないか?:FALSE"
>
> [1] "Inf ||| NA(欠損値)か?:FALSE | NaN(非数)か?:FALSE | 無限か?:TRUE | 有限値か?:FALSE | 欠損がないか?:TRUE"
>
> [1] "1+1i ||| NA(欠損値)か?:FALSE | NaN(非数)か?:FALSE | 無限か?:FALSE | 有限値か?:TRUE | 欠損がないか?:TRUE"

#### 文字列

```r
( x <- "a'\'b\"c" )
( x <- 'ab"\"c' )
( x <- "\\" )
( x <- '\\' )
```

> [1] "a''b\"c"
>
> [1] "ab\"\"c"
>
> [1] "\\"
>
> [1] "\\"

#### 論理値

```r
( x <- T )
( x <- TRUE )
( x <- FALSE )
```

> [1] TRUE
>
> [1] TRUE
>
> [1] FALSE

#### 日付と時刻

##### 本日の日付

```r
(today <- Sys.Date())
format(today, "%Y %m %d")
format(today, "%y %m %d")
format(today, "%d %b %Y")
format(today, "%b %d(%a)")
```

> [1] "2016-12-01"
>
> [1] "2016 12 01"
>
> [1] "16 12 01"
>
> [1] "01 12 2016"
>
> [1] "12 01(木)"

##### 書式指定文字列

| Conversion | Description         | Example |
| ---------- | ------------------- | ------- |
| %a         | Abbreviated weekday | Sun, Thu
| %A         | Full weekday        | Sunday, Thursday
| %b , %h    | Abbreviated month   | May, Jul
| %B         | Full month          | May, July
| %d         | Day of the month
| %j         | Day of the year
| %m         | Month               | 05, 07
| %U         | Week (01-53) # with Sunday as first day of the week | 22, 27
| %w         | Weekday (Sunday is 0)
| %W         | Week (00-53) # with Monday as first day of the week | 21, 27
| %x         | Date, locale-specific
| %y         | Year without century (00-99)
| %Y         | Year with century 00 to 68 prefixed by 20, 69 to 99 prefixed by 19
| %C         | Century             | 19, 20
| %D         | %m/%d/%y            | 05/27/84
| %u         | Weekday (Monday is 1)
| %n         | Newline on output or Arbitrary whitespace on input
| %t         | Tab on output or Arbitrary whitespace on input

##### Windows Excelのシリアル値

```r
dates <- c(1, 42736)
as.Date(dates, origin = "1899-12-30")
```

##### Mac Excelのシリアル値

```r
dates <- c(1, 41274)
as.Date(dates, origin = "1904-01-01")
```

##### 閏年の判定

```r
year <- 1996
if(length(seq(as.Date(paste(as.character(year), "-01-01", sep=""), format="%Y-%m-%d"), as.Date(paste(as.character(year), "-12-31", sep=""), format="%Y-%m-%d"), by="days"))==366){
  print('閏年です')
}
```

##### 文字列へ、文字列からのキャスト

```r
( d1 <- as.Date("2016/01/01") )
( d1 <- as.Date("2016/01/01 00:00:00", format="%Y/%m/%d %H:%M:%S") )
( d1 <- as.Date("01/01/16", format="%m/%d/%y") )
( d2 <- as.Date("32", format="%j") ) # 1/1からの日数
Sys.setlocale("LC_TIME","C") # 日本語環境では、日本語の文字列が含まれないよう事前設定が必要
( d1 <- as.Date("2016/Jan/01", format="%Y/%b/%d") )
( d3 <- as.Date("01Jan14", "%d%b%y") )
( d3 <- strptime("01Jan14", "%d%b%y") )
dates <- c("02/27/92", "02/27/92", "01/14/92")
times <- c("23:03:20", "22:29:56", "01:03:30")
strptime(paste(dates, times, sep=" "), "%m/%d/%y %H:%M:%S")
```

"2016/01/01"は文字列だが、as.Dateの戻り値は日付型であって、文字列ではない

> [1] "2016-01-01"
>
> [1] "2016-01-01"
>
> [1] "2016-01-01"
>
> [1] "2016-02-01"
>
> [1] "C"
>
> [1] "2016-01-01"
>
> [1] "2014-01-01"
>
> [1] "2014-01-01 JST"
>
> [1] "1992-02-27 23:03:20 JST" "1992-02-27 22:29:56 JST"
[3] "1992-01-14 01:03:30 JST"

```r
format(Sys.time(), "%y/%m/%d %H:%M:%S")
as.character(Sys.time(), "%y/%m/%d %H:%M:%S")
strftime(Sys.time(), "%y/%m/%d %H:%M:%S")
```

> [1] "2016-11-11 11:11:11"
>
> [1] "2016-11-11 11:11:11"
>
> [1] "2016-11-11 11:11:11"

##### 年齢を求める

```r
length(seq(d3, d1, "year"))-1 # seq(過去, 未来, "year")という並びでないとエラーとなる
```

##### 日数の差を求める

```r
d1 - d3
d3 - d1
ISOdate(2016, 1, 1) - ISOdate(2014, 1, 1)
ISOdatetime(2016, 1, 1, 0, 0, 0) - ISOdatetime(2014, 1, 1, 0, 0, 0)
```

> Time difference of 730 days
>
> Time difference of -730 days
>
> 日数の差を求める
>
> Time difference of 730 days
>
> Time difference of 730 days

##### 週／日／時／分／秒数の差を求める

```r
difftime(d1, d3, tz="", units="secs")
difftime(d1, d3, tz="", units="mins")
difftime(d1, d3, tz="", units="hours")
difftime(d1, d3, tz="", units="days")
difftime(d1, d3, tz="", units="weeks")
```

> Time difference of 63072000 secs
>
> Time difference of 1051200 mins
>
> Time difference of 17520 hours
>
> Time difference of 730 days
>
> Time difference of 104.2857 weeks

##### POSIXtクラス

日時を表すPOSIXtクラスには

* POSIXct
* POSIXlt

が含まれる

```r
( t1 <- Sys.time() ) # 日時
str(t1)
```

> [1] "2016-11-11 11:11:11 JST"
>
> POSIXct[1:1], format: "2016-11-11 11:11:11"

```r
( t2 <- as.POSIXlt(Sys.time(), "GMT") ) # 現在のロケール(JST)からGMTでの日時へ変換
( t3 <- t1 - 24 * 60 * 60 )
print(.leap.seconds) # 過去の閏秒一覧
```

> [1] "2016-11-11 02:11:11 GMT"
>
> [1] "2016-11-10 11:11:11 JST"

> [1] "1972-07-01 09:00:00 JST" "1973-01-01 09:00:00 JST"
>
> [3] "1974-01-01 09:00:00 JST" "1975-01-01 09:00:00 JST"
>
> [5] "1976-01-01 09:00:00 JST" "1977-01-01 09:00:00 JST"
>
> [7] "1978-01-01 09:00:00 JST" "1979-01-01 09:00:00 JST"
>
> [9] "1980-01-01 09:00:00 JST" "1981-07-01 09:00:00 JST"
>
> [11] "1982-07-01 09:00:00 JST" "1983-07-01 09:00:00 JST"
>
> [13] "1985-07-01 09:00:00 JST" "1988-01-01 09:00:00 JST"
>
> [15] "1990-01-01 09:00:00 JST" "1991-01-01 09:00:00 JST"
>
> [17] "1992-07-01 09:00:00 JST" "1993-07-01 09:00:00 JST"
>
> [19] "1994-07-01 09:00:00 JST" "1996-01-01 09:00:00 JST"
>
> [21] "1997-07-01 09:00:00 JST" "1999-01-01 09:00:00 JST"
>
> [23] "2006-01-01 09:00:00 JST" "2009-01-01 09:00:00 JST"
>
> [25] "2012-07-01 09:00:00 JST" "2015-07-01 09:00:00 JST"

```r
difftime(t1, t3, tz="", units="secs")
difftime(t1, t3, tz="", units="mins")
difftime(t1, t3, tz="", units="hours")
```

> Time difference of 86400 secs
>
> Time difference of 1440 mins
>
> Time difference of 24 hours

as.difftime()を用いて時間差を表す文字列をdifftime()の戻り値と同様のdifftimeオブジェクトに変換

```r
( df1 <- as.difftime("1:23:45", units="secs") )
( df2 <- as.numeric(df, units="mins") )
```

> Time difference of 5025 secs
>
> [1] 83.75

### ベクトル

#### 数値型ベクトル

```r
( x <- c() )
```

> NULL

```r
( x1 <- c(1, 2, 3, 4, 5) )
( x2 <- c(1.0, 2.0, 3.0, 4.0, 5.0) )
( x3 <- 1:5 )
( x4 <- 5:1 )
( x5 <- 1:length(c(2,8,5)) )
( x6 <- seq(along=c(2,8,5)) )
```

> [1] 1 2 3 4 5
>
> [1] 1 2 3 4 5
>
> [1] 1 2 3 4 5
>
> [1] 5 4 3 2 1
>
> [1] 1 2 3
>
> [1] 1 2 3

```r
( y1 <- rep(0:1, length=8) )
( y2 <- rep(0:1, times=8) )
( y3 <- rep(0:1, times=c(3,5)) )
( y4 <- seq(1, 30, by=6) )
( y5 <- seq(1, 5, length=6) )
( y6 <- seq_len(10) )
( y7 <- seq.int(10) )
( y8 <- sequence(1:10) )
( y9 <- sequence(c(5,2)) )
( y10 <- sequence(c(1,3,5)) )
( y11 <- sequence(c("1","3","5")) )
```

> [1] 0 1 0 1 0 1 0 1
>
> [1] 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
>
> [1] 0 0 0 1 1 1 1 1
>
> [1]  1  7 13 19 25
>
> [1] 1.0 1.8 2.6 3.4 4.2 5.0
>
> [1]  1  2  3  4  5  6  7  8  9 10
>
> [1]  1  2  3  4  5  6  7  8  9 10
>
>  [1]  1  1  2  1  2  3  1  2  3  4  1  2  3  4  5  1  2  3  4  5  6  1  2  3  4  5  6  7  1  2  3  4
>
> [33]  5  6  7  8  1  2  3  4  5  6  7  8  9  1  2  3  4  5  6  7  8  9 10
>
> [1] 1 2 3 4 5 1 2
>
> [1] 1 1 2 3 1 2 3 4 5
>
> [1] 1 1 2 3 1 2 3 4 5

```r
( z1 <- numeric(6) )
( z2 <- rep(1,6) )
( z3 <- unique(y8) )
```

> [1] 0 0 0 0 0 0
>
> [1] 1 1 1 1 1 1
>
> [1]  1  2  3  4  5  6  7  8  9 10

#### 文字型ベクトル

```r
( s <- c("AAA", "BBB", "CCC") )
```

> [1] "AAA" "BBB" "CCC"

#### 因子ベクトル

##### 順序無し因子→名義尺度

```r
( s <- rep(c("S", "M", "L"), 3) ) # もとになる文字型ベクトルを生成

( fcn1 <- factor(s) )

( fcn2 <- factor(s, levels=c("S", "M", "L")) ) # 明示的に順序を指定
```

> [1] "S" "M" "L" "S" "M" "L" "S" "M" "L"

> [1] S M L S M L S M L
>
> Levels: L M S

> [1] S M L S M L S M L
>
> Levels: S M L

##### 順序付き因子→順序尺度

```r
( fco1 <- ordered(s) )

( fco2 <- factor(s, ordered=T) )
```

> [1] S M L S M L S M L
>
> Levels: L < M < S

> [1] S M L S M L S M L
>
> Levels: L < M < S

##### 列挙型(Enum)のように扱う

値に別名をつける

```r
answers <- c(0,0,0,1,1,1,0,1,0,1,0,1)
( f1 <- factor(answers, labels = c("No","Yes")) )

( f2 <- factor(c(10, 10, 20, 30, 30), levels=c(30, 20, 10), labels=c("l1", "l2", "l3")) )

levels(f2)

labels(f2)

as.integer(f2)
```

>  [1] No  No  No  Yes Yes Yes No  Yes No  Yes No  Yes
>
> Levels: No Yes

> [1] l3 l3 l2 l1 l1
>
> Levels: l1 l2 l3

> [1] "l1" "l2" "l3"

> [1] "1" "2" "3" "4" "5"

> [1] 3 3 2 1 1

変換先がnumeric型の場合、単にas.numericとしただけでは意図した動作をしない

逆にnumeric型からfactor型へキャストする場合はfactor関数を使う

```r
( f3 <- factor(c(1.2, 1.2, 3.4, 5.6, 5.6, 5.6, 7.8, 9.0)) )

as.numeric(f3) # Levelが返る

as.character(f3) # Labelが返る

as.numeric(levels(f3)[f3]) | as.numeric(as.character(f3))
```

> [1] 1.2 1.2 3.4 5.6 5.6 5.6 7.8 9
>
> Levels: 1.2 3.4 5.6 7.8 9

> [1] 1 1 2 3 3 3 4 5

> [1] "1.2" "1.2" "3.4" "5.6" "5.6" "5.6" "7.8" "9"

numeric型の要素が格納されたベクトルが返る

> [1] 1.2 1.2 3.4 5.6 5.6 5.6 7.8 9.0

##### 水準・複製回数・ラベルを指定して因子ベクトルを生成

```r
( fcn3 <- gl(3, 5, length=15, ordered=F) )

( fcn4 <- gl(3, 5, labels=c("S", "M", "L"), ordered=F) )

( fco3 <- gl(3, 5, length=15, ordered=T) )

( fco4 <- gl(3, 5, labels=c("S", "M", "L"), ordered=T) )
```

>  [1] 1 1 1 1 1 2 2 2 2 2 3 3 3 3 3
>
> Levels: 1 2 3

>  [1] S S S S S M M M M M L L L L L
>
> Levels: S M L

>  [1] 1 1 1 1 1 2 2 2 2 2 3 3 3 3 3
>
> Levels: 1 < 2 < 3

>  [1] S S S S S M M M M M L L L L L
>
> Levels: S < M < L

##### 型の変換・検査

同じベクトルの中に異なる型のデータがあるときには、
優先順位(character>complex>numeric>logical>NULL)の高いものに変換される

```r
checkType <- function(x){
  print(
    paste(
      x, " ||| ",
      "mode:",mode(x)," | ",
      "実数か?:",is.numeric(x)," | ",
      "整数か?:",is.integer(x)," | ",
      "複素数か?:",is.complex(x)," | ",
      "文字列か?:",is.character(x)," | ",
      "論理値か?:",is.logical(x),
      sep=""
    )
  )
}
( x1 <- c(0,1,"2","3.0",4.0,"5") )
( x2 <- c(0,1,"2","a",4.0,"b") )
storage.mode(x1)
storage.mode(x2)
as.numeric(x1)
as.integer(x1)
as.complex(x1)
as.character(x1)
as.character(x2)
as.logical(x1)
as.logical(x2)
```

> [1] "0"   "1"   "2"   "3.0" "4"   "5" # 文字型ベクトルになっている
>
> [1] "0" "1" "2" "a" "4" "b"           # 文字型ベクトルになっている
>
> [1] "character"
>
> [1] "character"
>
> [1] 0 1 2 3 4 5
>
> [1] 0 1 2 3 4 5
>
> [1] 0+0i 1+0i 2+0i 3+0i 4+0i 5+0i
>
> [1] "0"   "1"   "2"   "3.0" "4"   "5"
>
> [1] "0" "1" "2" "a" "4" "b"
>
> [1] NA NA NA NA NA NA
>
> [1] NA NA NA NA NA NA

##### データ構造の検査

```r
checkType <- function(x){
  print(
    paste(
      x, " ||| ",
      "ベクトルか?:",is.vector(x)," | ",
      "行列か?:",is.matrix(x)," | ",
      "配列か?:",is.array(x)," | ",
      "リストか?:",is.list(x)," | ",
      "データフレームか?:",is.data.frame(x)," | ",
      "順序なし因子か?:",is.factor(x),
      "順序つき因子か?:",is.ordered(x),
      sep=""
    )
  )
}
```

##### 型変換

###### 暗黙的な型変換

```r
TRUE + 0 # 論理型→数値型
FALSE - 0
```

> [1] 1
>
> [1] 0

```r
ifelse(2, "T", "F") # 数値型→論理型
ifelse(1, "T", "F")
ifelse(0, "T", "F") # 0はFALSEへ、0でない数はTRUEへ変換
ifelse(-1, "T", "F")
```

> [1] "T"
>
> [1] "T"
>
> [1] "F"
>
> [1] "T"

###### 明示的な型変換

```r
( x <- c(0,1,"2","3.0",4.0,"5") )
```

> [1] "0"   "1"   "2"   "3.0" "4"   "5"

```r
as.vector(x) # ベクトル→ベクトル
```

> [1] "0"   "1"   "2"   "3.0" "4"   "5"

```r
as.matrix(x) # ベクトル→行列
```

>      [,1]
>
> [1,] "0"
>
> [2,] "1"
>
> [3,] "2"
>
> [4,] "3.0"
>
> [5,] "4"
>
> [6,] "5"

```r
attributes(x) # mode と length 以外の全属性を調べる
attr(x, "dim") <- c(2,3)
x
```

>      [,1] [,2]  [,3]>
> [1,] "0"  "2"   "4"
>
> [2,] "1"  "3.0" "5"

```r
x <- c(0,1,"2","3.0",4.0,"5")
```

```r
as.array(x) # ベクトル→配列
```

> [1] "0"   "1"   "2"   "3.0" "4"   "5"

```r
as.list(x) # ベクトル→リスト
```

> [[1]]
>
> [1] "0"
>
>
>
> [[2]]
>
> [1] "1"
>
>
>
> [[3]]
>
> [1] "2"
>
>
>
> [[4]]
>
> [1] "3.0"
>
>
>
> [[5]]
>
> [1] "4"
>
>
>
> [[6]]
>
> [1] "5"

```r
as.data.frame(x) # ベクトル→データフレーム
```

>     x
>
> 1   0
>
> 2   1
>
> 3   2
>
> 4 3.0
>
> 5   4
>
> 6   5

```r
as.factor(x) # ベクトル→順序無し因子ベクトル
```

>
> [1] 0   1   2   3.0 4   5
>
> Levels: 0 1 2 3.0 4 5

```r
as.ordered(x) # ベクトル→順序つき因子ベクトル
```

> [1] 0   1   2   3.0 4   5
>
> Levels: 0 < 1 < 2 < 3.0 < 4 < 5
```

##### ベクトルの要素

```r
( x <- 5:1 )

x[2]

( x[2] <- 44 )
```

> [1] 5 4 3 2 1

> [1] 4

> [1] 44

```r
( x <- replace( x, c(2,4), c(444,222) ) )

( x <- replace( x, which(x == 3), 33 ) )

( x <- replace(x, which(is.na(x)), 0) )
```

> [1]   5 444   3 222   1
>
> [1]   5 444  33 222   1
>
> [1]   5 444  33 222   1

##### ベクトルの結合

```r
( x <- c( x , c( -1, -2, -3, -4, -5 ) ) )
( x <- append( x, c( -11, -22, -33, -44, -55 ) ) )
( x <- append( x, c( -111, -222 ), after=10 ) )
```

>  [1]   5 444  33 222   1  -1  -2  -3  -4  -5
>
>  [1]   5 444  33 222   1  -1  -2  -3  -4  -5 -11 -22 -33 -44 -55
>
>  [1]    5  444   33  222    1   -1   -2   -3   -4   -5 -111 -222  -11  -22  -33  -44  -55

```r
x[c(1,3)] # 1,3番目の要素
```

> [1] 5 33

```r
x[1:3] # 1～3番目の要素
```

> [1]   5 444   33

```r
x[-1:-3] # 1～3番目以外の要素
```

> [1]  222    1   -1   -2   -3   -4   -5 -111 -222  -11  -22  -33  -44  -55

```r
x[5 < x] # 要素の値が5よりも大きい
```

> [1] 444  33 222

```r
x[3 < x & x < 10] # 要素の値が3よりも大きく10よりも小さい
```

> [1] 5

```r
(1:length(x))[3 < x & x < 10] # 条件に該当する要素のインデックス
```

> [1] 1

```r
x[ which( abs(x-2.8) == min(abs(x-2.8)) ) ] # 要素の値が2.8に最も近いもの
```

> [1] 3

##### ベクトルの演算

###### 要素数の取得

```r
length( x1 )
```

> [1] 5

###### 要素同士の比較

```r
( x1 == x2 )
```

> [1] TRUE TRUE TRUE TRUE TRUE

```r
( x1 > x2 )
```

> [1] FALSE FALSE FALSE FALSE FALSE

###### 要素同士の加算

```r
( x1 + x2 )
```

> [1]  2  4  6  8 10

```r
( x1 + y6 )
```

ベクトルの要素数が異なる場合、短いほうのベクトルの要素が循環して使用される

> [1]  2  4  6  8 10  7  9 11 13 15

```r
( x1 + x5 )
```

ベクトルの要素数が整数倍でない場合、結果は出力されるが警告メッセージも表示される

> [1] 2 4 6 5 7
>
> Warning message:
>
>   In x1 + x5 :
>
>   longer object length is not a multiple of shorter object length

ベクトルとスカラーの場合、スカラーが繰り返し使用される

```r
( x1 + 1 )
```

> [1] 2 3 4 5 6

###### ベクトル同士の演算を行う関数

| method   | 内容
| -------- | ---
| sum()    | 総和
| mean()   | 平均
| var()    | 不偏分散
| median() | 中央値
| cor()    | 相関係数
| max()    | 最大値
| min()    | 最小値
| prod()   | 総積
| cumsum() | 累積和
| sd()     | 標準偏差
| sort()   | 整列
| rev()    | 要素を逆順
| pmax()   | 並列最大値
| pmin()   | 並列最小値
| range()  | 範囲
| match()  | マッチング
| diff()   | 前進差分
| rank()   | 整列した各要素の順位
| order()  | 整列した各要素の移動元

```r
s <- c(6, 9, 12, 7, 10)

sort(s)
order(s)
rank(s)
```

> [1]  6  7  9 10 12
>
> [1] 1 4 2 5 3
>
> [1] 1 3 5 2 4

###### 集合演算

```r
union(x1, y6)      # 和集合
intersect(x1, y6)  # 積集合
setdiff(x1, y6)    # 差集合
setdiff(y6, x1)
setequal(x1, y6)   # 集合として等しいか否か
setequal(y6, x1)
is.element(x1, y6) # xの各要素yに含まれるか
is.element(y6, x1)
x1 %in% y6
y6 %in% x1
```

>  [1]  1  2  3  4  5  6  7  8  9 10
>
> [1] 1 2 3 4 5
>
> numeric(0)
>
> [1]  6  7  8  9 10
>
> [1] FALSE
>
> [1] FALSE
>
> [1] TRUE TRUE TRUE TRUE TRUE
>
>  [1]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE
>
> [1] TRUE TRUE TRUE TRUE TRUE
>
>  [1]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE

###### 論理型ベクトルの演算

```r
( c(T, T, F, F) & c(T, F, T, F) )
( c(T, T, F, F) | c(T, F, T, F) )
( ! c(T, T, F, F) )
( xor( c(T, T, F, F) , c(T, F, T, F) ) )
( any( c(T, F, F, F) ) )
( any( c(F, F, F, F) ) )
( any(seq(0, 1, 0.2) > 0.8) )
( all( c(T, T, T, F) ) )
( all( c(T, T, T, T) ) )
( all(seq(0, 1, 0.2) < 0.8) )
```

> [1]  TRUE FALSE FALSE FALSE
>
> [1]  TRUE  TRUE  TRUE FALSE
>
> [1] FALSE FALSE  TRUE  TRUE
>
> [1] FALSE  TRUE  TRUE FALSE
>
> [1] TRUE
>
> [1] FALSE
>
> [1] TRUE
>
> [1] FALSE
>
> [1] TRUE
>
> [1] FALSE

###### 文字型ベクトルの演算

```r
"AAA" > "BBB"
```

> [1] FALSE

###### 因子ベクトルの演算

```r
s <- rep(c("S", "M", "L"), 3)
fcn1 <- factor(s)
fco1 <- ordered(s)
summary(fcn1)
```

> L M S
>
> 3 3 3

```r
mode(fcn1)
```

> [1] "numeric"

```r
attributes(fcn1)

attributes(fco1)
```

> $levels
>
> [1] "L" "M" "S"
>
>
>
> $class
>
> [1] "factor"

> $levels
>
> [1] "L" "M" "S"
>
>
>
> $class
>
> [1] "ordered" "factor"

```r
unclass(fcn1)
```

> [1] 3 2 1 3 2 1 3 2 1
>
> attr(,"levels")
>
> [1] "L" "M" "S"

```r
fco1counts <- c(10, 30, 20, 10, 30, 20, 10, 30, 20)

# fco1counts全要素の平均値
mean(fco1counts)

# 水準ごとの平均値
tapply(fco1counts, fcn1, mean)
```

> [1] 20

>  L  M  S
>
> 20 30 10

### 行列

#### 行列の生成

```r
# 零行列
( m0 <- matrix(0, nrow=2, ncol=2) )

# 単位行列
( m0 <- diag(2) )
```

>      [,1] [,2]
>
> [1,]    0    0
>
> [2,]    0    0

>      [,1] [,2]
>
> [1,]    1    0
>
> [2,]    0    1

```r
# 列を埋めてから次の行へ進む
( m1 <- matrix(1:12, nrow=4, ncol=3) )
```

>      [,1] [,2] [,3]
>
> [1,]    1    5    9
>
> [2,]    2    6   10
>
> [3,]    3    7   11
>
> [4,]    4    8   12

```r
# "byrow=T"と指定すると行を埋めてから次の列へ進む
( m2 <- matrix(1:12, nrow=4, ncol=3, byrow=T) )
```

>      [,1] [,2] [,3]
>
> [1,]    1    2    3
>
> [2,]    4    5    6
>
> [3,]    7    8    9
>
> [4,]   10   11   12

#### 行列の結合

```r
# 空のベクトルに行ベクトルを結合して生成(forループ内など)
( m3 <- rbind(c(), c(1,2,3)) )

# 行ベクトルを結合して生成
( m4 <- rbind(c(1,2,3), c(4,5,6)) )
( m5 <- rbind(c(1,2,3), c(4,5,6), c(7,8,9)) )

# 列ベクトルを結合して生成
( m6 <- cbind(c(1,2,3,4), c(5,6,7,8)) )
( m7 <- cbind(c(1,2,3,4), c(5,6,7,8), c(9,10,11,12)) )
```

#### 次元属性の確認

```r
dim(m1)
```

> [1] 4 3

```r
# 行列の次元属性を除去(NULLで上書き)するとベクトルになる
dim(m1) <- NULL

dim(m1)
m1
```

> NULL
>
>  [1]  1  4  7 10  2  5  8 11  3  6  9 12

```r
# ベクトルを行列に戻す
dim(m1) <- c(4,3)
dim(m1)
```

> [1] 4 3

#### 行列要素の参照

##### 列

```r
# 列数
ncol(m1)

m1[,3]
```

> [1] 3

> [1]  3  6  9 12

```r
# 戻り値のベクトル化を防ぐ
m1[,3, drop=F]
```

>      [,1]
>
> [1,]    3
>
> [2,]    6
>
> [3,]    9
>
> [4,]   12

```r
# 複数列の取得
m1[,c(1, 2)]

# T(True)の列のみ
m1[,c(T,F,T)]
```

>      [,1] [,2]
>
> [1,]    1    2
>
> [2,]    4    5
>
> [3,]    7    8
>
> [4,]   10   11

>      [,1] [,2]
>
> [1,]    1    3
>
> [2,]    4    6
>
> [3,]    7    9
>
> [4,]   10   12

##### 行

```r
# 行数
nrow(m1)

m1[3,]
```

> [1] 4

> [1] 7 8 9

```r
# 戻り値のベクトル化を防ぐ
m1[3,, drop=F]
```

>      [,1] [,2] [,3]
>
> [1,]    7    8    9

```r
# 複数行の取得
# T(True)の列のみ
m1[c(T,F,T,F),]
```

>      [,1] [,2] [,3]
>
> [1,]    1    2    3
>
> [2,]    7    8    9

```r
# 条件を満たす要素のみ
( wh1 <- which(m1%%2==0, arr.ind=TRUE) )

m1[wh1]
```

> [1]  2  4  5  7 10 12
>
> [1]  4 10  2  8  6 12

##### 行と列を共に指定

```r
m1[3, 2]

m1[[3, 2]]

# 戻り値のベクトル化を防ぐ
m1[3, 2, drop=F]
```

> [1] 8

> [1] 8

>      [,1]
>
> [1,]    8

#### 行列の演算

```r
rowSums(m1)  # 行の総和
colSums(m1)  # 列の総和
rowMeans(m1) # 行の平均
colMeans(m1) # 列の平均
apply(m1, 1, mean)
 # 第2引数
 #  1:      行に対して関数を適用
 #  2:      列に対して関数を適用
 #  c(1,2): 各要素に対して関数を適用
```

> [1] 15 18 21 24
>
> [1] 10 26 42
>
> [1] 5 6 7 8
>
> [1]  2.5  6.5 10.5
>
> [1] 5 6 7 8

```r
( M1 <- matrix(1:4, 2, 2) )
( M2 <- matrix(0:3, 2, 2) )

M1 + M2
M1 - M2

M1 %*% M2

# 要素ごとの積
M1 * M2

# 外積
a %o% b

# クロネッカー積
a %x% b
```

>      [,1] [,2]
>
> [1,]    1    3
>
> [2,]    2    4

>      [,1] [,2]
>
> [1,]    0    2
>
> [2,]    1    3

>      [,1] [,2]
>
> [1,]    1    5
>
> [2,]    3    7

>      [,1] [,2]
>
> [1,]    1    1
>
> [2,]    1    1

>      [,1] [,2]
>
> [1,]    3   11
>
> [2,]    4   16
>
>      [,1] [,2]
>
> [1,]    0    6
>
> [2,]    2   12

> , , 1, 1
>
>      [,1] [,2]
>
> [1,]    0    0
>
> [2,]    0    0
>
>
>
> , , 2, 1
>
>
>
>      [,1] [,2]
>
> [1,]    1    3
>
> [2,]    2    4
>
>
>
> , , 1, 2
>
>
>
>      [,1] [,2]
>
> [1,]    2    6
>
> [2,]    4    8
>
>
>
> , , 2, 2
>
>
>
>      [,1] [,2]
>
> [1,]    3    9
>
> [2,]    6   12

>      [,1] [,2] [,3] [,4]
>
> [1,]    0    2    0    6
>
> [2,]    1    3    3    9
>
> [3,]    0    4    0    8
>
> [4,]    2    6    4   12

##### 転置行列

```r
t( M1 )
```

>      [,1] [,2]
>
> [1,]    1    2
>
> [2,]    3    4

```r
( M3 <- matrix(1:25, 5, 5) )
```

>      [,1] [,2] [,3] [,4] [,5]
>
> [1,]    1    6   11   16   21
>
> [2,]    2    7   12   17   22
>
> [3,]    3    8   13   18   23
>
> [4,]    4    9   14   19   24
>
> [5,]    5   10   15   20   25

##### 上三角成分を0にする

```r
( M3[upper.tri(M3)] <- 0 )
```

>      [,1] [,2] [,3] [,4] [,5]
>
> [1,]    1    0    0    0    0
>
> [2,]    2    7    0    0    0
>
> [3,]    3    8   13    0    0
>
> [4,]    4    9   14   19    0
>
> [5,]    5   10   15   20   25

##### 対角成分も含めて、上三角成分を0にする

```r
( M3[upper.tri(M3,diag=TRUE)] <- 0 )
```

>      [,1] [,2] [,3] [,4] [,5]
>
> [1,]    0    0    0    0    0
>
> [2,]    2    0    0    0    0
>
> [3,]    3    8    0    0    0
>
> [4,]    4    9   14    0    0
>
> [5,]    5   10   15   20    0

##### 下三角成分を0にする

```r
# 下三角成分を0にする
M3[lower.tri(M3)] <- 0

# 対角成分も含めて、下三角成分を0にする
M3[lower.tri(M3,diag=TRUE)] <- 0

M3
```

>      [,1] [,2] [,3] [,4] [,5]
>
> [1,]    0    0    0    0    0
>
> [2,]    0    0    0    0    0
>
> [3,]    0    0    0    0    0
>
> [4,]    0    0    0    0    0
>
> [5,]    0    0    0    0    0

##### 行列成分をそれぞれ二乗したものの和

```r
sum(M1^2) | sum( diag( t(M1) %*% M1 ) )
```

> [1] 30

##### 逆行列を求める

```r
solve(M1)
```

>      [,1] [,2]
>
> [1,]   -2  1.5
>
> [2,]    1 -0.5

##### 逆行列を使用して連立方程式を解く

```r
#  Ax=b
A <- matrix(c(1,2,3,4,5,6,7,8,10), 3, 3)
b <- matrix(1:3, 3, 1)
solve(A,b)
```

>      [,1]
>
> [1,]    1
>
> [2,]    0
>
> [3,]    0

##### 固有値・固有ベクトルを求める

```r
A <- matrix(c(1,2,3,4,5,6,7,8,10), 3, 3)
( eigenvalues <- eigen(A)$values )
( eigenvectors <- eigen(A)$vectors )
```

> [1] 16.7074933 -0.9057402  0.1982469

>            [,1]       [,2]       [,3]
>
> [1,] -0.4524587 -0.9369032  0.1832951
>
> [2,] -0.5545326 -0.1249770 -0.8624301
>
> [3,] -0.6984087  0.3264860  0.4718233

固有値eigenvalues[1]に対応する固有ベクトルはeigenvectors[,1]

#### 行列をグラフにプロットする

```r
x <- matrix(1:100, 10, 10)
cols = colorRamp(c("#0080ff","white","#ff8000"))
image(x, col=rgb(cols(0:99/99)/255))
```

#### 行列の行や列に名前を付ける

```r
( m1 <- matrix(1:12, nrow=4, ncol=3) )
```

>      [,1] [,2] [,3]
>
> [1,]    1    5    9
>
> [2,]    2    6   10
>
> [3,]    3    7   11
>
> [4,]    4    8   12

```r
# 行の名前
rownames(m1) <- c("r1", "r2", "r3", "r4")

# 列の名前
colnames(m1) <- c("c1", "c2", "c3")

m1

m1["r1","c1"]

# 変数で指定しても参照できる
name <- "r1"
m1[name,"c2"]
```

>    c1 c2 c3
>
> r1  1  5  9
>
> r2  2  6 10
>
> r3  3  7 11
>
> r4  4  8 12

> [1] 1

> [1] 5

```r
# 行に付けられた名前を全削除
rownames(m1) <- NULL

# 列に付けられた名前を全削除
colnames(m1) <- NULL

m1
```

>      [,1] [,2] [,3]
>
> [1,]    1    5    9
>
> [2,]    2    6   10
>
> [3,]    3    7   11
>
> [4,]    4    8   12

```r
# 行の名前
rownames(m1) <- c("r1", "r2", "r3", "r4")

# 列の名前
colnames(m1) <- c("c1", "c2", "c3")
```
>    c1 c2 c3
>
> r1  1  5  9
>
> r2  2  6 10
>
> r3  3  7 11
>
> r4  4  8 12

```r
# 行・列に付けられた名前を全削除
m1 <- unname(m1)
m1
```

>      [,1] [,2] [,3]
>
> [1,]    1    5    9
>
> [2,]    2    6   10
>
> [3,]    3    7   11
>
> [4,]    4    8   12

```r
# 行の名前
rownames(m1) <- c("r1", "r2", "r3", "r4")

# 列の名前
colnames(m1) <- c("c1", "c2", "c3")
```

>    c1 c2 c3
>
> r1  1  5  9
>
> r2  2  6 10
>
> r3  3  7 11
>
> r4  4  8 12

```r
# 行・列に付けられた名前を全削除
dimnames(m1) <- NULL
m1
```

>      [,1] [,2] [,3]
>
> [1,]    1    5    9
>
> [2,]    2    6   10
>
> [3,]    3    7   11
>
> [4,]    4    8   12

### 配列

#### 配列の生成と参照

```r
( a1 <- array(1:24, dim=c(2, 3, 4)) )
```

> , , 1
>
>
>
>      [,1] [,2] [,3]
>
> [1,]    1    3    5
>
> [2,]    2    4    6
>
>
>
> , , 2
>
>
>
>      [,1] [,2] [,3]
>
> [1,]    7    9   11
>
> [2,]    8   10   12
>
>
>
> , , 3
>
>
>
>      [,1] [,2] [,3]
>
> [1,]   13   15   17
>
> [2,]   14   16   18
>
>
>
> , , 4
>
>
>
>      [,1] [,2] [,3]
>
> [1,]   19   21   23
>
> [2,]   20   22   24

```r
a1[2, , ]
a1[2, 3, ]
a1[2, 3, 4]
```

>      [,1] [,2] [,3] [,4]
>
> [1,]    2    8   14   20
>
> [2,]    4   10   16   22
>
> [3,]    6   12   18   24

> [1]  6 12 18 24

> [1] 24

#### 配列の演算

```r
apply(a1, 1, mean)
apply(a1, c(1,2), mean)
```

> [1] 12 13

>      [,1] [,2] [,3]
>
> [1,]   10   12   14
>
> [2,]   11   13   15

#### (多次元)配列の転置

```r
perm=c(2,1,3)
```

* もとの配列の2番目の添字を新しい配列の1番目の添字にする
* もとの配列の1番目の添字を新しい配列の2番目の添字にする
* もとの配列の3番目の添字を新しい配列の3番目の添字にする

```r
( at1 <- aperm(a1, perm=c(2,1,3)) )
```

### リスト

#### リストの生成

```r
( l0 <- as.list(NULL) ) # 初期化
```

> list()

```r
( l1 <- list(1:5) )
```

> [[1]]
>
> [1] 1 2 3 4 5

```r
( l2 <- list(1:5,6:10) )
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1]  6  7  8  9 10

```r
( l3 <- list(1:5,"6") )
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1] "6"

```r
( l3 <- list(1:5,str="6") )
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> $str
>
> [1] "6"

```r
( l3 <- list(1:5,"str"="6") )
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> $str
>
> [1] "6"

```r
( l4 <- list(1:5,"6","7") )
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1] "6"
>
>
>
> [[3]]
>
> [1] "7"

```r
( l5 <- list(1:5,c("6","7")) )
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1] "6" "7"

```r
( l6 <- list(1:5,c("6","7"),c(TRUE,FALSE)) )
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1] "6" "7"
>
>
>
> [[3]]
>
> [1]  TRUE FALSE

#### リスト要素の参照

```r
# 戻り値はリスト
l6[1]
```

> [[1]]
>
> [1] 1 2 3 4 5

```r
# 戻り値はベクトル
l6[[1]]
```

> [1] 1 2 3 4 5
>
> “If list x is a train carrying objects, then x5 is the object in car 5; x[4:6] is a train of cars 4-6.”

```r
# 第1,2成分のリスト
l6[1:2]
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1] "6" "7"

```r
# 第1成分のリストの第2成分
l6[[1:2]]
l6[[1]][[2]]
```

> [1] 2
>
> [1] 2

```r
# 第1成分以外のリスト
l6[-1]
```

> [[1]]
>
> [1] "6" "7"
>
>
>
> [[2]]
>
> [1]  TRUE FALSE

```r
# 第1,3成分のリスト
l6[c(T,F,T)]
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1]  TRUE FALSE

```r
l6 <- list(1:5,c("6","7"),c(TRUE,FALSE))

# リストの第2成分に代入
l6[2] <- 10 | l6[[2]] <- 10

l6
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1] 10
>
>
>
> [[3]]
>
> [1]  TRUE FALSE

```r
l6 <- list(1:5,c("6","7"),c(TRUE,FALSE))
l6[2] <- list(NULL) # 第2成分にNULLを代入
l6
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> NULL
>
>
>
> [[3]]
>
> [1]  TRUE FALSE

```r
l6 <- list(1:5,c("6","7"),c(TRUE,FALSE))
l6[2] <- NULL       # 成分を除去
l6
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1]  TRUE FALSE

#### リストに対する演算

```r
length(l6) # 長さ
```

> [1] 3

#### リストの連結

```r
( l7 <- c(list(1:5),list(6:10)) ) | ( l7 <- append(list(1:5),list(6:10)) )
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1]  6  7  8  9 10

```r
( l8 <- c(list(),list(1:5)) ) | ( l8 <- append(list(),list(1:5)) )
```

> [[1]]
>
> [1] 1 2 3 4 5

```r
( l9 <- rep(list(1:3, 4:6), 2) )
```

> [[1]]
>
> [1] 1 2 3
>
>
>
> [[2]]
>
> [1] 4 5 6
>
>
>
> [[3]]
>
> [1] 1 2 3
>
>
>
> [[4]]
>
> [1] 4 5 6

#### ベクトルの要素を、因子別にリストの要素に変換

```r
( l11 <- split(1:10, rep(c("odd", "even"), 5)) )

l11$even
```

> $even
>
> [1]  2  4  6  8 10
>
>
>
> $odd
>
> [1] 1 3 5 7 9

> [1]  2  4  6  8 10

#### リストの要素をベクトルにする

```r
unlist(l11)
```

> even1 even2 even3 even4 even5  odd1  odd2  odd3  odd4  odd5
>
>     2     4     6     8    10     1     3     5     7     9

#### 一括処理

##### apply：ベクトル・行列・配列

```r
( apl <- matrix(1:12, nrow=3, ncol=4) )

# 各行ごとに処理
( m1 <- apply(apl, 1, mean) )

# 各列ごとに処理
( m2 <- apply(apl, 2, mean) )

# 各要素ごとに処理
apply(apl, c(1,2), sum)

# 各要素ごとに処理
apply(apl, c(1,2), sqrt)
```

>      [,1] [,2] [,3] [,4]
>
> [1,]    1    4    7   10
>
> [2,]    2    5    8   11
>
> [3,]    3    6    9   12

> [1] 5.5 6.5 7.5

> [1]  2  5  8 11

>      [,1] [,2] [,3] [,4]
>
> [1,]    1    4    7   10
>
> [2,]    2    5    8   11
>
> [3,]    3    6    9   12

>          [,1]     [,2]     [,3]     [,4]
>
> [1,] 1.000000 2.000000 2.645751 3.162278
>
> [2,] 1.414214 2.236068 2.828427 3.316625
>
> [3,] 1.732051 2.449490 3.000000 3.464102

```r
sweep(apl, 1, m1) # 各行ごとに処理
sweep(apl, 2, m2) # 各列ごとに処理
```

>      [,1] [,2] [,3] [,4]
>
> [1,] -4.5 -1.5  1.5  4.5
>
> [2,] -4.5 -1.5  1.5  4.5
>
> [3,] -4.5 -1.5  1.5  4.5

>      [,1] [,2] [,3] [,4]
>
> [1,]   -1   -1   -1   -1
>
> [2,]    0    0    0    0
>
> [3,]    1    1    1    1

##### lapply：リスト

* lapply：結果をリストで返す
* sapply：結果をベクトルで返す

```r
( li <- list(1:5,6:9,c(T,T,F,T),"10") )

lapply(li, mean)

sapply(li, mean)
```

> [[1]]
>
> [1] 1 2 3 4 5
>
>
>
> [[2]]
>
> [1] 6 7 8 9
>
>
>
> [[3]]
>
> [1]  TRUE  TRUE FALSE  TRUE
>
>
>
> [[4]]
>
> [1] "10"

> [[1]]
>
> [1] 3 # 第1成分の平均値
>
>
>
> [[2]]
>
> [1] 7.5 # 第2成分の平均値
>
>
>
> [[3]]
>
> [1] 0.75 # 第3成分の平均値
>
>
>
> [[4]]
>
> [1] NA # 第4成分の平均値
>        # 論理型はT:1;F:0へとキャストされるが、文字型はNAになってしまう

> [1] 3.00 7.50 0.75   NA # 論理型はT:1;F:0へとキャストされるが、文字型はNAになってしまう

##### tapply：カテゴリカルデータ

```r
num <- 1:10
type <- rep(c("odd","even"), 5)
( df <- data.frame(num, type) )

tapply(df$num, df$type, mean)
```

>    num type
>
> 1    1  odd
>
> 2    2 even
>
> 3    3  odd
>
> 4    4 even
>
> 5    5  odd
>
> 6    6 even
>
> 7    7  odd
>
> 8    8 even
>
> 9    9  odd
>
> 10  10 even

> even  odd
>
>    6    5

##### mapply：sapply関数の多変量版

http://sudori.info/stat/stat_mapply_clusterMap.html

```r
trapezoid <- function(a, b, h) {
  return( (a+b)*h/2 )
}

trapezoid.modified <- function(a, b, h) {
  h <- ifelse(h > 0, h, 0)
  return((a+b)*h/2)
}

upper.length <- seq(1, 300, by=3)
lower.length <- seq(1, 200, by=2)

result1 <- mapply(FUN=trapezoid,
                  a=upper.length,
                  b=lower.length,
                  MoreArgs=list(h=30),
                  SIMPLIFY=TRUE,
                  USE.NAMES=TRUE )
summary(result1)

result2 <- trapezoid.modified(upper.length, lower.length, 30)
summary(result2)
```

>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
>
>      30    1886    3742    3742    5599    7455

#### リストの要素に名前を付ける

```r
( li <- list(1:5,6:9,c(T,T,F,T),"10") )
names(li) <- c("l1", "l2", "l3", "l4")
```

> li
>
> $l1
>
> [1] 1 2 3 4 5
>
>
>
> $l2
>
> [1] 6 7 8 9
>
>
>
> $l3
>
> [1]  TRUE  TRUE FALSE  TRUE
>
>
>
> $l4
>
> [1] "10"

```r
li$l3
```

> [1]  TRUE  TRUE FALSE  TRUE

```r
li$l1
```

> [1] 1 2 3 4 5

```r
name <- "l2"

# 変数で指定しても参照できる
li[name]
li[[name]]

# li$l2ではなくli$nameと認識されるため、NULLが返される
li$name
```

### データフレーム

#### データフレームの作成

##### 空のデータフレーム

```r
( df <- data.frame(matrix(NA,ncol=1,nrow=1))[-1,-1] )

( df <- data.frame(matrix(rep(NA,3),ncol=3,nrow=1))[-1,] )
```

> 0 列 0 行のデータフレーム

> [1] X1 X2 X3
>
>  <0 行> (または長さ 0 の row.names)

##### ベクトルから作成

```r
# data <- read.csv("example.csv", header = TRUE, stringsAsFactors = FALSE)

type <- c("A","A","B","B","A")
num <- 1:5
point <- c(12,34,56,78,90)
( df <- data.frame(TYPE=type, NUMBER=num, POINT=point) )

df$TYPE
```

>   TYPE NUMBER POINT
>
> 1    A      1    12
>
> 2    A      2    34
>
> 3    B      3    56
>
> 4    B      4    78
>
> 5    A      5    90

> [1] A A B B A
>
> Levels: A B

```r
mean(df$NUMBER)
mean(df$POINT)
summary(df)
by(df, df$TYPE, summary)
```

> [1] 3
>
> [1] 54

>  TYPE      NUMBER      POINT
>
> A:3   Min.   :1   Min.   :12
>
> B:2   1st Qu.:2   1st Qu.:34
>
> Median :3   Median :56
>
> Mean   :3   Mean   :54
>
> 3rd Qu.:4   3rd Qu.:78
>
> Max.   :5   Max.   :90

> df$TYPE: A
>
> TYPE      NUMBER          POINT
>
> A:3   Min.   :1.000   Min.   :12.00
>
> B:0   1st Qu.:1.500   1st Qu.:23.00
>
> Median :2.000   Median :34.00
>
> Mean   :2.667   Mean   :45.33
>
> 3rd Qu.:3.500   3rd Qu.:62.00
>
> Max.   :5.000   Max.   :90.00
>
> ------------------------------------------------------------------------------------------------------------------
>
>   df$TYPE: B
>
> TYPE      NUMBER         POINT
>
> A:0   Min.   :3.00   Min.   :56.0
>
> B:2   1st Qu.:3.25   1st Qu.:61.5
>
> Median :3.50   Median :67.0
>
> Mean   :3.50   Mean   :67.0
>
> 3rd Qu.:3.75   3rd Qu.:72.5
>
> Max.   :4.00   Max.   :78.0

#### 要素の参照

##### 列

```r
df$POINT | df[["POINT"]] | df[[3]]

df["POINT"] | df[3]

df[c(1, 2)] | df[,c(1, 2)]

# T(True)の列のみ
df[ ,c(T,F,T)]

# 一列おきに偶数列のみ
df[,seq(0, length(df[1,]), +2)]

# 一列おきに奇数列のみ
df[,seq(1, length(df[1,]), +2)]
```

> [1] 12 34 56 78 90

>   POINT
>
> 1    12
>
> 2    34
>
> 3    56
>
> 4    78
>
> 5    90

> TYPE NUMBER
>
> 1    A      1
>
> 2    A      2
>
> 3    B      3
>
> 4    B      4
>
> 5    A      5

> TYPE POINT
>
> 1    A    12
>
> 2    A    34
>
> 3    B    56
>
> 4    B    78

> [1] 1 2 3 4 5 # 次元が落ちた

>   TYPE POINT
>
> 1    A    12
>
> 2    A    34
>
> 3    B    56
>
> 4    B    78
>
> 5    A    90

##### 行

```r
df[3,]

df[c(1, 2),]

# T(True)の行のみ
df[c(T,F,T),]

# 一行おきに偶数行のみ
df[seq(0, length(df[1,]), +2),]

# 一行おきに奇数行のみ
df[seq(1, length(df[1,]), +2),]
```

>   TYPE NUMBER POINT
>
> 3    B      3    56

>   TYPE NUMBER POINT
>
> 1    A      1    12
>
> 2    A      2    34

>   TYPE NUMBER POINT
>
> 1    A      1    12
>
> 3    B      3    56
>
> 4    B      4    78

>   TYPE NUMBER POINT
>
> 2    A      2    34

>   TYPE NUMBER POINT
>
> 1    A      1    12
>
> 3    B      3    56

##### 行と列を共に指定

```r
df[3, 2]
df[[3, 2]]
df[3, "POINT"]
df[[3, "POINT"]]

head(df)

tail(df)
```

> [1] 3
>
> [1] 3
>
> [1] 56
>
> [1] 56

>   TYPE NUMBER POINT
>
> 1    A      2     1
>
> 2    B      8     4
>
> 3    A      9     5
>
> 4    B      5     3
>
> 5    A      3     5
>
> 6    B      7     1

>    TYPE NUMBER POINT
>
> 5     A      3     5
>
> 6     B      7     1
>
> 7     A      1     4
>
> 8     A      6     2
>
> 9     B      4     4
>
> 10    B     10     3

##### フィルタリング

```r
# TYPEがAの列のみ
df[df$TYPE=="A",]

# 複数条件(AND)
df[df$TYPE=="A" & df$NUMBER>2,]

# 複数条件(OR)
df[df$TYPE=="A" | df$NUMBER>3,]
```

>   TYPE NUMBER POINT
>
> 1    A      1    12
>
> 2    A      2    34
>
> 5    A      5    90

>   TYPE NUMBER POINT
>
> 5    A      5    90

>   TYPE NUMBER POINT
>
> 1    A      1    12
>
> 2    A      2    34
>
> 4    B      4    78
>
> 5    A      5    90

```r
subset(df, POINT>50)
subset(df, POINT>50, c(NUMBER,POINT))
```

>   TYPE NUMBER POINT
>
> 3    B      3    56
>
> 4    B      4    78
>
> 5    A      5    90

>   NUMBER POINT
>
> 3      3    56
>
> 4      4    78
>
> 5      5    90

```r
# データを展開
reshape(df, timevar="TYPE", idvar="NUMBER", direction="wide")
```

>   NUMBER POINT.A POINT.B
>
> 1      1      12      NA
>
> 2      2      34      NA
>
> 3      3      NA      56
>
> 4      4      NA      78
>
> 5      5      90      NA

```r
# 数値データが含まれる列のみ
df[sapply(df,is.numeric)]

# 単体で実行すると
sapply(df,is.numeric)
```

>   NUMBER POINT
>
> 1      1    12
>
> 2      2    34
>
> 3      3    56
>
> 4      4    78
>
> 5      5    90

is.numericのほかにもis.integer, is.complex, is.character, is.logicalがある

>   TYPE NUMBER  POINT
>
>  FALSE   TRUE   TRUE

```r
df2 <- df

# 1列目を削除
df2[1] <- NULL

df2
```

> TYPE POINT
>
> 1    A    12
>
> 2    A    34
>
> 3    B    56
>
> 4    B    78
>
> 5    A    90

```r
# 1列目を削除
df2 <- df[-1]
df2
```

> TYPE POINT
>
> 1    A    12
>
> 2    A    34
>
> 3    B    56
>
> 4    B    78
>
> 5    A    90

```r
# 1,2列目を削除
df2 <- df[c(-1,-2)]
df2
```

>   POINT
>
> 1    12
>
> 2    34
>
> 3    56
>
> 4    78
>
> 5    90

```r
# 1行目を削除
df2 <- df[-1,]
df2
```

>   TYPE NUMBER POINT
>
> 2    A      2    34
>
> 3    B      3    56
>
> 4    B      4    78
>
> 5    A      5    90

```r
# 1,2,4,5行目を削除
df2 <- df[c(-1,-2,-4,-5),]
df2
```

>   TYPE NUMBER POINT
>
> 3    B      3    56

```r
df2 <- df[, colnames(df) != "TYPE"] | df[, setdiff(colnames(df), "TYPE")] # TYPE列を削除
df2
```

>   NUMBER POINT
>
> 1      1    12
>
> 2      2    34
>
> 3      3    56
>
> 4      4    78
>
> 5      5    90

```r
df2 <- df[, -which (colnames(df) %in% c("TYPE", "NUMBER"))] | df[, !(colnames(df) %in% c("TYPE", "NUMBER"))] # TYPE列,NUMBER列を削除
df2
```

> [1] 12 34 56 78 90

```r
df2 <- df[!(rownames(df) %in% c("1", "2")), ] # 1,2行を削除
df2
```

> TYPE NUMBER POINT
>
> 3    B      3    56
>
> 4    B      4    78
>
> 5    A      5    90

```r
na.fail(df) # 欠損値を含むか検査する
na.omit(df) # 欠損値を含む行を削除
na.exclude(df) # 欠損値を含む行を削除
na.contiguous(df) # 欠損値でない値の最長部分を抽出
df[is.na(df)] <- 0 # 欠損値を0で置き換える

df[which(df == Inf, TRUE)] <- -1 # 無限大を-1で置き換える
```

```r
transform(df, add=1:10) # 新規列を追加する
```

>    TYPE NUMBER POINT add
>
> 1     A      2     1   1
>
> 2     B      8     4   2
>
> 3     A      9     5   3
>
> 4     B      5     3   4
>
> 5     A      3     5   5
>
> 6     B      7     1   6
>
> 7     A      1     4   7
>
> 8     A      6     2   8
>
> 9     B      4     4   9
>
> 10    B     10     3  10

#### データフレーム同士の結合

```r
type <- c("A","A","B","B","A")
num <- 1:5
point <- c(10,34,56,78,90)
dfA <- data.frame(TYPE=type, NUMBER=num, POINT=point)
dfA

prop <- c("AAA","AAA","BBB","BBB","AAA")
num <- 3:7
point2 <- c(90,76,54,32,10)
dfB <- data.frame(PROP=prop, NUMBER=num, POINT2=point2)
dfB
```

>   TYPE NUMBER POINT
>
> 1    A      1    10
>
> 2    A      2    34
>
> 3    B      3    56
>
> 4    B      4    78
>
> 5    A      5    90

>   PROP NUMBER POINT2
>
> 1  AAA      3     90
>
> 2  AAA      4     76
>
> 3  BBB      5     54
>
> 4  BBB      6     32
>
> 5  AAA      7     10

```r
# all=T指定ですべての行を残す。NUMBER列の値で紐づけ
merge(dfA,dfB,all=T,by="NUMBER")
```

>   NUMBER TYPE POINT PROP POINT2
>
> 1      1    A    10 <NA>     NA
>
> 2      2    A    34 <NA>     NA
>
> 3      3    B    56  AAA     90
>
> 4      4    B    78  AAA     76
>
> 5      5    A    90  BBB     54
>
> 6      6 <NA>    NA  BBB     32
>
> 7      7 <NA>    NA  AAA     10

```r
# all=T指定ですべての行を残す。POINT列の値とPOINT2列の値で紐づけ
merge(dfA,dfB,all=T,by.x="POINT",by.y="POINT2")
```

>   POINT TYPE NUMBER.x PROP NUMBER.y
>
> 1    10    A        1  AAA        7
>
> 2    32 <NA>       NA  BBB        6
>
> 3    34    A        2 <NA>       NA
>
> 4    54 <NA>       NA  BBB        5
>
> 5    56    B        3 <NA>       NA
>
> 6    76 <NA>       NA  AAA        4
>
> 7    78    B        4 <NA>       NA
>
> 8    90    A        5  AAA        3

```r
# NUMBER列が共通している行のみ
merge(dfA,dfB,all=F,by="NUMBER")
```

>   NUMBER TYPE POINT PROP POINT2
>
> 1      3    B    56  AAA     90
>
> 2      4    B    78  AAA     76
>
> 3      5    A    90  BBB     54

```r
# POINT列とPOINT2列に共通している値がある行のみ
merge(dfA,dfB,all=F,by.x="POINT",by.y="POINT2")
```

>   POINT TYPE NUMBER.x PROP NUMBER.y
>
> 1    10    A        1  AAA        7
>
> 2    90    A        5  AAA        3

```r
# NUMBER列が共通している行およびdfAのデータを残す
merge(dfA,dfB,all.x=T,by="NUMBER")
```

>   NUMBER TYPE POINT PROP POINT2
>
> 1      1    A    10 <NA>     NA
>
> 2      2    A    34 <NA>     NA
>
> 3      3    B    56  AAA     90
>
> 4      4    B    78  AAA     76
>
> 5      5    A    90  BBB     54

```r
# NUMBER列が共通している行およびdfBのデータを残す
merge(dfA,dfB,all.y=T,by="NUMBER")
```

>   NUMBER TYPE POINT PROP POINT2
>
> 1      3    B    56  AAA     90
>
> 2      4    B    78  AAA     76
>
> 3      5    A    90  BBB     54
>
> 4      6 <NA>    NA  BBB     32
>
> 5      7 <NA>    NA  AAA     10

#### ソート

```r
n <- 10
type <- sample(c("A","B"),n,replace=T)
num <- sample(1:n)
point <- sample(1:(n/2),n,replace=T)
df <- data.frame(TYPE=type, NUMBER=num, POINT=point)

sort <- order(df$POINT) # 昇順にソート
# sort <- order(df$POINT, decreasing=T) # 降順にソート

df2 <- df[sort,]
rownames(df2) <- c(1:nrow(df2)) # 行番号を振り直す

df2
```

>    TYPE NUMBER POINT
>
> 1     A      2     1
>
> 2     B      7     1
>
> 3     A      6     2
>
> 4     B      5     3
>
> 5     B     10     3
>
> 6     B      8     4
>
> 7     A      1     4
>
> 8     B      4     4
>
> 9     A      9     5
>
> 10    A      3     5

```r
sort <- order(df$POINT, pmax(df$POINT,df$NUMBER)) # 複数キー(1:POINT, 2:NUMBER)
df2 <- df[sort,]
rownames(df2) <- c(1:nrow(df2)) # 行番号を修正する
df2
```

>    TYPE NUMBER POINT
>
> 1     A      2     1
>
> 2     B      7     1
>
> 3     A      6     2
>
> 4     B      5     3
>
> 5     B     10     3
>
> 6     A      1     4
>
> 7     B      4     4
>
> 8     B      8     4
>
> 9     A      3     5
>
> 10    A      9     5

## 6.文法

### 演算子

#### 比較演算子

```r
1 == 1
2 >  1
2 >= 1
2 <= 1
2 <  1
```

> [1] TRUE
>
> [1] TRUE
>
> [1] TRUE
>
> [1] FALSE
>
> [1] FALSE

```r
c(1, 2, 3, 4, 5) > 1

# すべての要素が条件を満たすか
all( c(1, 2, 3, 4, 5) > 1 )

# いずれかの要素が条件を満たすか
any( c(1, 2, 3, 4, 5) > 1 )
```

> [1] FALSE  TRUE  TRUE  TRUE  TRUE
>
> [1] FALSE
>
> [1] TRUE

#### 論理演算子

```r
T && T          # AND
T || F          # OR
!T              # NOT
xor(T,F)        # XOR
c(T,T) & c(T,F) # ベクトルのAND
c(T,T) | c(T,F) # ベクトルのOR
```

> [1] TRUE
>
> [1] TRUE
>
> [1] FALSE
>
> [1] TRUE
>
> [1]  TRUE FALSE
>
> [1] TRUE TRUE

#### 文字列の比較

```r
"aa" > "ab"
"aa" > "ba"
"aa" > "aaa"
```

> [1] FALSE
>
> [1] FALSE
>
> [1] FALSE

#### 数値の比較

```r
# 数値誤差以内で等しいか
all.equal(1, 1.0)

# 実数, 実数 → FALSE
identical(1, 1.) | identical(all.equal(1, 1.0), TRUE)

# 実数, 整数 → FALSE
identical(1, as.integer(1))
identical(all.equal(1, as.integer(1)), TRUE)
```

> [1] TRUE

> [1] TRUE

> [1] FALSE
>
> [1] TRUE

#### 代入演算子

```r
# グローバル変数に代入(永続代入)
x <<- 1
assign(x[2], 2, env=.GlobalEnv)

# ローカル変数に代入(関数内)
x <-  1

x = 1
```

#### 算術演算子

```r
2^3
> [1] 8
-1
> [1] -1
1:10
> [1]  1  2  3  4  5  6  7  8  9 10
1*2
> [1] 2
1/2
> [1] 0.5
1+2
> [1] 3
1-2
> [1] -1
```

### 制御構文

#### if

```r
x <- 2
if (x > 0) {
  cat( x )
} else {
  cat( "" )
}
```

> 2

```r
x <- -3
if (x<-2) print(x) # 「x<-2」は「x < -2」ではなく「x <- 2」
```

> [1] 2

##### elseif

```r
if (a < 0) {
  print(0)
} else if (a < 1) {
  print(1)
} else {
  print(2)
}
```

##### 三項演算子

```r
ifelse(x >= 0, x, NA)
```

#### switch

```r
a <- 1 | a <- "1" | a <- T
switch(a,
  "1" = print("one"),
  "2" = print("two"),
  print("other")
)
```

> [1] "one"

```r
int <- 2
switch(int, # 整数の場合、条件値を省略できる
  print("one"), # 1
  print("two")  # 2
)
```
> [1] "two"

#### for

```r
sum <- 0
for (i in 1:5) {
  sum <- sum + i
}
sum
```

> [1] 15

```r
x <- 0
y <- matrix(1:10, 2, 5)
for (i in y) cat( i, " " )
```

> 1  2  3  4  5  6  7  8  9  10

#### while

```r
x <- 0
while (x <= 10) {
  x <- x + 1
  if (x == 3) next
  if (x == 7) break
  cat( x, " " )
}
```

> 1  2  4  5  6

#### repeat

```r
x <- 0
repeat {
  if (x <= 10) x <- x + 1
  else         break
  cat( x, " " )
}
```

> 1  2  3  4  5  6  7  8  9  10  11

```r
stop("Error")      # エラーを発生させる
warning("Warning") # 警告を発生させる
try(func(x), TRUE) # エラーが発生しても処理を継続する
```

#### 文字列の評価

```r
com <- "ls()"
eval(parse(text=com))

get("com")
eval(parse(text="com"))
```
> [1] "ls()"
>
> [1] "ls()"

#### コマンドラインでの入力

```r
( x <- readline("Enter the value: ") )
x
( v <- as.numeric(x) )
```

> Enter the value: 1
>
> [1] "1"

> [1] "1"

> [1] 1

##### コマンドラインでの入力(ベクトル)

```r
( x <- readline("Enter x: ") )
( v <- as.numeric(unlist(strsplit(x, ","))) )
```

> Enter x: 1,2,3,4,5
>
> [1] "1,2,3,4,5"

> [1] 1 2 3 4 5

## 7.関数の定義

### 関数定義の確認方法

* 関数名のみを入力し、Enterキーを押す

or

* methods(<関数名>)→getS3method(<メソッド名>,<クラス名>)

```r
FunctionName1 <- function(arg1) {
  return( arg1 )
}
FunctionName1(1)
```

> [1] 1

```r
FunctionName2 <- function(arg1, arg2) {
  return( list(arg1, arg2) )
  # return( list(input1=arg1, input2=arg2) )
}
FunctionName2(1, 2)
```

> [[1]]
>
> [1] 1
>
>
>
> [[2]]
>
> [1] 2

```r
FunctionName3 <- function(x) {
  return( function (y){ x*y } ) # returnで関数を返すこともできる
}
result <- FunctionName3(2)
result(3)
```

> [1] 6

```r
FunctionName4 <- function(arg1) {
  return( invisible( arg1 ) ) # invisibleを用いることで、呼び出しの際に戻り値が表示されなくなる
}
FunctionName4(1)
```

### 演算子の定義

```r
"%+=%" <- function(x, y) x <<- x + y
"%-=%" <- function(x, y) x <<- x - y
```

## 8.数値計算

### 実数の丸め

IEEE式：丸めた結果が偶数になるように丸めるため、四捨五入ではなく五捨もある

```r
# digits引数は小数点以下の桁数
round(0.5, digits = 0)
round(1.5, digits = 0)
round(2.5, digits = 0)
round(0.45, digits = 1)
```

> [1] 0
>
> [1] 2
>
> [1] 2
>
> [1] 0.4

```r
# 切り上げ
ceiling(1.4)

# 切り捨て
floor(1.5)

# 指定された有効数字で丸める
signif(1.4444444, digits = 6)
signif(1.5555555, digits = 6)

# 0へ向かって切り捨て
trunc(5.5)
trunc(-5.5)
```

> [1] 2
>
> [1] 1
>
> [1] 1.44444
>
> [1] 1.55556
>
> [1] 5
>
> [1] -5

### 数学関数

```r
sin(0)
asin(0)
cos(0)
acos(0)
tan(0)
atan(0)
atan2(y, x) # x 軸と、原点と座標 (x,y) を結ぶベクトルのなす角
            # x、y>0 なら atan2(y,x) = atan(y/x)
sinh(0)
asinh(0)
cosh(0)
acosh(0)
tanh(0)
atanh(0)
```

```r
( e <- exp(1) )
log(e)
log10(10)
log2(2)
```

> [1] 2.718282
>
> [1] 1
>
> [1] 1
>
> [1] 1

```r
dx <- 0.01

# dx≪1のときのlog(dx+1)
log1p(dx)

# dx≪1のときのexp(dx)-1
expm1(dx)
```

> [1] 0.009950331
>
> [1] 0.01005017

```r
sign(-2) # 符号を求める(結果はc(-1, 0, 1)で返却される)
abs(-2)  # 絶対値
sqrt(4) # 平方根
```

> [1] -1
>
> [1] 2
>
> [1] 2

```r
# nCk
choose(3, 2)

# nCkの自然対数
lchoose(3, 2)

# x!
factorial(3)

# x!の自然対数
lfactorial(3)
```

> [1] 3
>
> [1] 1.098612
>
> [1] 6
>
> [1] 1.791759

### 逐次処理

```r
c <- 1:10

# 累積和ベクトル
cumsum(c)

# 逐次積ベクトル
cumprod(c)

# 逐次最大値ベクトル
cummax(c)

# 逐次最小値ベクトル
cummin(c)
```

>  [1]  1  3  6 10 15 21 28 36 45 55
>
>  [1]       1       2       6      24     120     720    5040   40320  362880 3628800
>
>  [1]  1  2  3  4  5  6  7  8  9 10
>
>  [1] 1 1 1 1 1 1 1 1 1 1

### 数値計算

#### ニュートン法

```r
# 対象の関数を定義
f <- function (x) x^3 - 2 * sqrt(2)

# 範囲を指定
uniroot(f, c(0, 2))
```

> $root
>
> [1] 1.414196
>
>
>
> $f.root
>
> [1] -0.000107459
>
>
>
> $iter
>
> [1] 6
>
>
>
> $init.it
>
> [1] NA
>
>
>
> $estim.prec
>
> [1] 6.103516e-05

#### 多項式の解

```r
# x^2 + 3x + 2 = 0 の解
polyroot(c(2, 3, 1))
```

> [1] -1+0i -2-0i

#### 関数の微分

```r
f <- expression( a*x^3 )  # 対象の関数を定義
D(f, "x")                 # xで微分
```

> a * (3 * x^2)

#### 二階微分

```r
DD <- function(expr, name, order = 1) {
  if(order < 1) stop("'order' must be >= 1")
  if(order == 1) D(expr, name)
  else DD(D(expr, name), name, order - 1)
}
DD(f, "x", 2) # 関数, 微分する変数, 回数
```

> a * (3 * (2 * x))

##### 微分した関数を計算に使う

```r
( g <- deriv(~ a*x^3, "x", func=T) )

g(1)

attr(g(1), "gradient")
```

> function (x)
>
> {
>
>   .value <- a * x^3
>
>   .grad <- array(0, c(length(.value), 1L), list(NULL, c("x")))
>
>   .grad[, "x"] <- a * (3 * x^2)
>
>   attr(.value, "gradient") <- .grad
>
>   .value
>
> }

> [1] 1
>
> attr(,"gradient")
>
>      x
>
> [1,] 3

>      x
>
> [1,] 3

#### 関数の積分

```r
# 関数を定義
f <- function(x) x^2

# 対象の数式, 範囲の下限, 上限
integrate(f, 0, 1)

# sinなど定義済の関数はそのまま引数に書くことができる
integrate(sin, 0, pi)
```

> 0.3333333 with absolute error < 3.7e-15
>
> 2 with absolute error < 2.2e-14

#### 関数の最小化

```r
f <- function(x) {
  x^3 + 3 * x^2 + 5 * x + 7
}

optim(1, f)
```

> $par
>
> [1] -1.809251e+74   # その時のパラメーター値
>
>
>
> $value
>
> [1] -5.922387e+222  # 関数の最小値
>
>
>
> $counts
>
> function gradient
>
> 502       NA
>
>
>
> $convergence
>
> [1] 1
>
>
>
> $message
>
> NULL

```r
nlm(f, 1, fscale=-1)
```

> $minimum
>
> [1] -161522464741 # 関数の最小値
>
>
>
> $estimate
>
> [1] -5447         # その時のパラメーター値
>
>
>
> $gradient
>
> [1] 88976660
>
>
>
> $code
>
> [1] 5
>
>
>
> $iterations
>
> [1] 7

#### 関数の最大化

```r
optim(1, f, control=list(fnscale=-1))
```

> $par
>
> [1] -1.809251e+74   # その時のパラメーター値
>
>
>
> $value
>
> [1] -5.922387e+222  # 関数の最大値
>
>
>
> $counts
>
> function gradient
>
> 502       NA
>
>
>
> $convergence
>
> [1] 1
>
>
>
> $message
>
> NULL

#### FFT

```r
sampling <- 4096            # サンプル数
n <- 0:(sampling-1)
samplefreq <- 44100         # 周波数(Hz)
t <- n/samplefreq           # 時間軸(s)
f <- n*samplefreq/sampling  # 周波数軸(Hz)
wave <- sin(100*2*pi*t)     # 対象とする関数

plot(t, wave, type="l", xlim=c(0,0.02), ylim=c(-1,1))         # 時間領域
spec = abs(fft(wave))^2 # フーリエ変換, 2乗してパワースペクトル
plot(f, spec, type="l", xlim = c(20,samplefreq/2), log="xy")  # 周波数領域
```

## 9.文字列

### 文字列操作

```r
files <- c("01.doc", "002.doc", "0003.docx", "00004.xls")

# 文字数
nchar(files)

# 大／小文字
tolower(files)
toupper(files)

# 全／半角
library(Nippon)
zen2han("１２３４５ＡＢＣ")
```

> [1] 6 7 9 9
>
> [1] "01.doc"    "002.doc"   "0003.docx" "00004.xls"
>
> [1] "01.DOC"    "002.DOC"   "0003.DOCX" "00004.XLS"
>
> [1] "12345ABC"

### 文字コード

```r
library(foreign)
utf8str <- iconv("text",'SHIFT_JIS','UTF-8')
iconv(utf8str,'UTF-8','SHIFT_JIS')
```

### 正規表現

```r
grep("\\.doc$", files) # needle,heystack
```

> [1] 1 2

```r
grep("\\.ppt$", files) # needle,heystack
```

> integer(0)

```r
regexpr(".doc", files) # needle,heystack
attr(result,"match.length")
attr(result,"useBytes")
#regexpr("日本語", str, useBytes=F)  #全角文字の場合
```

> [1]  5  5  5 -1
>
> [1]  4  4  4 -1
>
> [1] TRUE
>
> [1]  4  4  4 -1
>
> [1] TRUE

### 完全一致

```r
match("002.doc", files) # needle,heystack

grep("^002.doc$", files) # needle,heystack

file <- c("002.doc","003.doc")
match(file,files) # needle,heystack
```

> [1] 2
>
> [1] 2
>
> [1] NA  1 NA NA

### 部分一致

```r
file <- c(".doc",".xls")
charmatch(file,files) # needle,heystack
```

> [1] NA  1 NA NA

### ベクトルの要素同士で部分一致

```r
library(stringr)
str_detect(files,file) # heystack,needle

file <- c(".doc",".doc",".xls",".xls")
str_detect(files,file) # heystack,needle
```

> length(file) != length(files)のときは、file[1]の値と比較される
>
> [1]  TRUE FALSE  TRUE  TRUE

> length(file) == length(files)のとき
>
> [1]  TRUE  TRUE FALSE  TRUE

### ベクトルの要素同士で完全一致

```r
file <- c(".doc",".xls")
is.element(file,files) # needle,heystack
```

> [1] NA  1 NA NA

### 置換

#### replace

```r
sub("0", "_", files)
```

> [1] "_1.doc"    "_02.doc"   "_003.docx" "_0004.xls"

#### replaceAll

```r
gsub("0", "_", files)
```

> [1] "_1.doc"    "__2.doc"   "___3.docx" "____4.xls"

#### 1文字ごと

```r
chartr("dx0", "DX_", files)
```

> "_1.Doc"    "__2.Doc"   "___3.DocX" "____4.Xls"

### 切り出し

substrとsubstringの2種類があり、引数にベクトルを与えて処理を行う場合に使い分ける必要がある

単に文字列に対して1箇所のみ切り出す場合にはどちらを使用しても同じ結果が得られる

```r
fs1 <- "01.doc,002.doc,0003.docx,00004.xls"
fs2 <- c("01.doc", "002.doc", "0003.docx", "00004.xls")
```

#### 引数が{スカラー, スカラー}

```r
substr(fs1, 8, 14)
# [1] "002.doc"

substring(fs1, 8, 14)
# [1] "002.doc"
```

#### 引数が{スカラー, ベクトル}

```r
substr(fs1, 8:12,14:18)
# [1] "002.doc"

substring(fs1, 8:12,14:18)
# [1]  "002.doc" "02.doc," "2.doc,0" ".doc,00" "doc,000"
```

#### 引数が{ベクトル, スカラー}

```r
substr(fs2, 2, 6)
# [1] "1.doc" "02.do" "003.d" "0004."

substring(fs2, 2, 6)
# [1] "1.doc" "02.do" "003.d" "0004."
```

#### 引数が{ベクトル, ベクトル}

```r
substr(fs2, 2:5,6:9)
# [1] "1.doc" "2.doc" "3.doc" "4.xls"

substring(fs2, 2:5,6:9)
# [1] "1.doc" "2.doc" "3.doc" "4.xls"
```

### 分解

```r
unlist(strsplit("a.b.c", "."))
# [1] "" "" "" "" ""

unlist(strsplit("a.b.c", "\\."))
# [1] "a" "b" "c"

csv <- "\"a\",\"b\",\"c\",\"d\",\"e\""
unlist(strsplit(csv,NULL))
# [1] "\"" "a"  "\"" ","  "\"" "b"  "\"" ","  "\"" "c"  "\"" ","  "\"" "d"  "\"" ","  "\"" "e"  "\""

unlist(strsplit(csv,","))
# [1] "\"a\"" "\"b\"" "\"c\"" "\"d\"" "\"e\""

(unlist(strsplit(csv,",")))[1]
# [1] "\"a\""
```

### 結合

```r
paste(1:5) # as.character(1:5)
# [1] "1"  "2"  "3"  "4"  "5"

paste("A", 1:5, sep = "")
# [1] "A1" "A2" "A3" "A4" "A5"

paste("A", 1:5, sep = ",")
# [1] "A,1" "A,2" "A,3" "A,4" "A,5"

paste("A", 1:5, sep=",",collapse=" ")
# [1] "A,1 A,2 A,3 A,4 A,5"

sprintf("%5.1f", 1234.5678)
sprintf("%-10f", 1234.5678)
sprintf("%3d", as.integer(1234.5678))
sprintf("%3i", 1234.5678)
sprintf("%e", 1234.5678)
sprintf("%s", as.character(1234.5678))
```

### 文字列の類似度を求める

```r
args <- commandArgs(trailingOnly=TRUE)
if ((!is.null(args)) && (length(args)>0)) {
  arg1 <- args[1]
  cat(arg1)
} else {
  arg1 <- "北海道札幌市豊平区旭町一丁目 北海道札幌市東区本町二条１０丁目 北海道札幌市東区本町二条１１丁目 北海道札幌市東区東雁来十条１丁目 北海道札幌市東区東雁来十条２丁目 北海道札幌市東区東雁来十条３丁目 北海道札幌市東区東雁来十条４丁目 北海道札幌市東区東雁来十一条１丁目 北海道札幌市東区東雁来十一条２丁目 北海道札幌市東区東雁来十一条３丁目 北海道札幌市東区東雁来十一条４丁目 北海道札幌市東区東雁来十二条２丁目 北海道札幌市東区東雁来十二条３丁目 北海道札幌市東区東雁来十二条４丁目 北海道札幌市東区東雁来十三条２丁目 北海道札幌市東区東雁来十三条３丁目"
}

##install.packages("stringdist")
library(stringdist)

tests <- unlist(strsplit(arg1," "))

dic <- read.csv("stringDist.csv", header=F, stringsAsFactors=F)

for (test in tests) {
  minT <-list("")
  minV <- 1
  for (i in 1:nrow(dic)) {
    d <- stringdist(
      chartr("1234567890一二三四五六七八九〇","１２３４５６７８９０１２３４５６７８９０",test),
      chartr("1234567890一二三四五六七八九〇","１２３４５６７８９０１２３４５６７８９０",dic[i, 1]),
      method = "jaccard")
    if (test == dic[i, 1]){
      minT <- list(dic[i, 1])
      minV <- d
      break
    } else if (minV==d){
      minT <- c(dic[i, 1], minT)
      minV <- d
    } else if (minV>d){
      minT <- list(dic[i, 1])
      minV <- d
    }
  }

  if (minV<=0.5){
    print(paste(test, ",", minT, ": ", minV, sep=""))
  }
}
```

## 10.ファイル操作

### コマンドライン引数を取得

```r
args <- commandArgs(trailingOnly=TRUE)
if ((!is.null(args)) && (length(args)>0)) {
  arg1 <- args[1]
  cat(arg1)
}
```

### カレントディレクトリを設定

```r
setwd(paste(gsub("\\\\","/",Sys.getenv("USERPROFILE")),"/Documents/R/work/g",sep=""))
cat(getwd())
```

### オンラインのデータを取得

```r
curl <- "https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv"
cdestfile <- "iris.csv"
download.file(curl,cdestfile)
```

### テキストファイル

```r
data <- scan("data.txt", what = character(), sep = "\n", blank.lines.skip = F)
```

### CSV, TSVなど

```r
data <- read.table("data.txt")
write.table(data, "out.txt", append=T)
data <- read.table("data.txt",skip=1) # 1行目がコメント行
write.table(data, "out.txt", quote=F, col.names=F, append=T)
data <- read.table("data.txt",header=T) # 1行目がヘッダ行
data <- read.table("data.txt",sep="\t") # 区切り文字がタブ
data <- read.table("data.txt",sep=",") # 区切り文字がカンマ
data <- read.table("data.txt",skip=10,nrows=15) # 10行目から15行目まで読む
data <- read.table("data.txt",comment.char="\#") # コメント行の開始文字を設定
data <- read.table("iris.csv",sep=",",header=T,row.names=NULL) # 行名に連番を生成する
data <- read.table("iris.csv",sep=",",header=T,row.names="Name") # "Name"列を行名として使う
data <- read.table("iris.csv",sep=",",header=T,row.names=1) # "1"列目は"Name"列
data <- read.table("iris.csv",sep=",",header=T,row.names=paste("No.",1:100,sep="")) # 文字列ベクトルの要素を行名として使う（ここではpasteで接頭辞を追加）
data <- read.fwf("data.txt") # 固定長
data <- read.table("data.txt",sep="\t",header=F,quote="\"",dec=".") # read.fwfと同様
```

もしも以下のエラー(??は整数)が表示される場合には、文字エンコーディングを指定する必要がある

```
Error in scan(file, what, nmax, sep, dec, quote, skip, nlines, na.strings,  : 
  line 1 did not have ?? elements
```

```r
data <- read.table("data.csv", fileEncoding="UTF-8", sep=",", header=F)
```

### xlsx

```r
install.packages("xlsx", dep=T)
library(xlsx)
data <- read.xlsx("data.xlsx", sheetName="Sheet1")
```

### xlsx

```r
install.packages("openxlsx", dep=T)
library(openxlsx)
data <- read.xlsx("data.xlsx", sheet=1)
data <- readWorkbook("iris.xlsx",sheet=1)
loadWorkbook("iris.xlsx") # 仮想ブックとして読込み
```

### xls, xlsx

```r
install.packages("readxl")
library(readxl)
path <- system.file("data.xlsx", package = "readxl")

# シート単体を読込む
read_excel(path)
read_excel(path,1)
read_excel(path,"Sheet1")

# 全てのシートを読込む
lapply(excel_sheets(path),read_excel,path=path)
```

### arff

```r
install.packages("farff")
library(farff)
data <- readARFF("data.arff", data.reader = "readr", tmp.file = tempfile(), convert.to.logicals = TRUE, show.info = TRUE)
```

### テキストファイル

```r
NEWFILE=file(paste(getwd(), "/data.txt", sep = ""),open="w")
for(i in c(1,2,3,4,5)) {
  for(j in c("a","b","c")) {
    cat(i,"\t",j,"\n",file=NEWFILE)
  }
}
```

### コンソールの内容

```r
sink(paste(getwd(), "/data.txt", sep = ""))
sink()
```

### バイナリファイルに保存

```r
save(data, file="data.dat")
rm(data)
data <- load("data.dat")
```

### リストを書き出す

```r
list <- matrix(1:8, ncol=2)
write(list, "data.txt", append = T, ncolumns=4)
```

### データフレームを書き出す

```r
df <- data.frame(vx = 1:4, vy = rnorm(4))
write.table(df, "data.txt", append=T, quote=F, col.names=F)
```

### xlsx

```r
install.packages("xlsx", dep=T)
library(xlsx)
data <- data.frame(a=1:2, b=c("P","Q"))
write.xlsx(x, "data.xlsx", sheetName="Sheet1")
```

### xlsx

```r
install.packages("openxlsx", dep=T)
library(openxlsx)

# 仮想ブックを作成
wb <- createWorkbook()

#ワークシートを追加
addWorksheet(wb, "Sheet4")

# 文字色・背景色
negStyle <- createStyle(fontColour = "white", bgFill = "red")
posStyle <- createStyle(fontColour = "black", bgFill = "grey")

# 出力
writeData(wb, sheet=1, x=-5:5)
writeData(wb, sheet=1, x=LETTERS[1:11], startCol=2)

# 条件付き書式
conditionalFormat(wb, 1, cols=1, rows=1:11, rule="!=0", style = negStyle)
conditionalFormat(wb, 1, cols=1, rows=1:11, rule="==0", style = posStyle)
saveWorkbook(wb, "data.xlsx",overwrite = TRUE)
```

### arff

```r
install.packages("farff")
library(farff)
data <- data.frame(a=1:2, b=c("P","Q"))
write.arff(data, "data.arff", relation = deparse(substitute(x)))
```

### グラフ等を画像ファイルへ出力する

```r
# 必要に応じて、まず作業ディレクトリを変更する
setwd("c:/work")
```

サポートしている作図デバイスを確認

```r
options("device") # 既定の作図デバイス
help("Devices") # ヘルプ参照
```

| type                | description
| ------------------- | -----------
| pdf                 | Write PDF graphics commands to a file
| postscript          | Writes PostScript graphics commands to a file
| xfig                | Device for XFIG graphics file format
| bitmap              | bitmap pseudo-device via Ghostscript (if available).
| pictex              | Writes TeX/PicTeX graphics commands to a file (of historical interest only)
| X11                 | The graphics device for the X11 windowing system
| cairo_pdf, cairo_ps | PDF and PostScript devices based on cairo graphics.
| svg                 | SVG device based on cairo graphics.
| png                 | PNG bitmap device
| jpeg                | JPEG bitmap device
| bmp                 | BMP bitmap device
| tiff                | TIFF bitmap device

### PDF出力

```r
plot(1:10)
dev.copy(pdf, file="finename.pdf", height=11.69, pointsize = 18, width=8.27)
dev.off()
```

or

```r
pdf(file="finename.pdf", height=11.69, pointsize = 18, width=8.27)
plot(1:10)
dev.off()
```

### PNG出力

```r
png(file="finename.png", height=595, pointsize = 18, width=847)
plot(1:10)
dev.off()
```

### EPS出力

```r
X11()
plot(1:10)
dev.copy2eps(file="finename.eps", width=6)
```

or

```r
X11()
plot(1:10)
dev.print(file="finename.eps", height=10, horizontal=FALSE, width=10)
```

---

Copyright (c) 2016-2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.
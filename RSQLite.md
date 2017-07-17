# RSQLite

## 準備

```r
install.packages("RSQLite")
library("RSQLite")
library(RSQLite.extfuns) # 拡張関数
init_extensions(con)     #
```

## 接続

```r
con = dbConnect(SQLite(), "sqlite.db", synchronous="off") # ファイル名を指定
con = dbConnect(SQLite(), "",          synchronous="off") # 空文字だと一時ファイル
con = dbConnect(SQLite(), ":memory:",  synchronous="off") # オンメモリ
```

## 表の一覧を取得

```r
dbListTables(con)
```

```r
dbListFields(con, "TABLE_NAME")
```

## 戻り値のないクエリを実行

```r
result.send <- dbSendQuery(con, "create table TABLE_NAME(name text, id int)")
result.send <- dbSendQuery(con, "insert into TABLE_NAME values('佐藤', 1)")
result.send <- dbSendQuery(con, "update TABLE_NAME set id=2 where name='鈴木'")
print( dbGetInfo(result.send) )
```

## クエリの実行結果をdataframeとして取得

```r
result <- dbGetQuery(con, "select * from TABLE_NAME")
result <- dbReadTable(con, "TABLE_NAME")
```

```r
dbWriteTable(con, "TABLE_NAME", iris)
```

## トランザクションの利用

```r
dbBegin(con) # dbBeginTransaction(con)

result.send <- dbSendQuery(con, "DELETE FROM TABLE_NAME WHERE id=1")

dbRollback(con) # ロールバック
dbCommit(con)   # コミット
```

## プリペアードステートメント

```r
dbBeginTransaction(con)
val <- data.frame(val1='山田', val2=3) # 適当なデータ

# セミコロンに続いてデータフレームのカラム名で指定
query <- "INSERT INTO TABLE_NAME(name, id) VALUES (:val1,:val2)"
result.send <- dbSendPreparedQuery(con, query, val)
dbCommit(con)
```

## 切断

```r
dbDisconnect(con)
```

---

Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.
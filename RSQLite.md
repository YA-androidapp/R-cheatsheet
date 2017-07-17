# RSQLite


```r
install.packages("RSQLite")
library("RSQLite")
init_extensions(con)     #
```


```r
```


```r
dbListTables(con)
```

```r
dbListFields(con, "TABLE_NAME")
```


```r
result.send <- dbSendQuery(con, "create table TABLE_NAME(name text, id int)")
print( dbGetInfo(result.send) )
```


```r
result <- dbGetQuery(con, "select * from TABLE_NAME")
result <- dbReadTable(con, "TABLE_NAME")
```

```r
dbWriteTable(con, "TABLE_NAME", iris)
```


```r
dbBegin(con) # dbBeginTransaction(con)

result.send <- dbSendQuery(con, "DELETE FROM TABLE_NAME WHERE id=1")

```


```r
dbBeginTransaction(con)

query <- "INSERT INTO TABLE_NAME(name, id) VALUES (:val1,:val2)"
result.send <- dbSendPreparedQuery(con, query, val)
dbCommit(con)
```


```r
dbDisconnect(con)
```

---

Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.

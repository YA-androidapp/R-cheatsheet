# iris
# install.packages("MASS")
# install.packages("DMwR")
library(MASS) # 線形判別分析
library(DMwR) # SMOTE
data.iris <- rbind(iris[1:50,], iris[51:100,], iris[106:111,])

# 線形判別分析(不均衡データ)
data.iris.lda <- lda(Species ~ ., data = data.iris, CV = TRUE)
( tab.iris <- table(data[, 5], data.iris.lda$class) )
#              setosa versicolor virginica
#   setosa         50          0         0
#   versicolor      0         50         0
#   virginica       0          1         5

# SMOTE
data.iris.smote <- SMOTE(Species ~ ., data = data.iris, perc.over = 500, k = 5, perc.under = 100)
table(data.iris.smote[, 5])
#     setosa versicolor  virginica
#         19         11         36

# 線形判別分析(オーバーサンプリングしたデータ)
data.iris.lda <- lda(Species ~ ., data = data.iris.smote, CV = TRUE)
( tab.iris.smote <- table(data.iris.smote[, 5], data.iris.lda$class) )
#              setosa versicolor virginica
# setosa         19          0         0
# versicolor      0         11         0
# virginica       0          0        36

# 分類精度の確認
sum(diag(tab.iris)) / sum(tab.iris)
# [1] 0.990566
sum(diag(tab.iris.smote)) / sum(tab.iris.smote)
# [1] 1

# spam
library(kernlab)
data(spam)
data.spam <- rbind(head(spam, 500), tail(spam, 2500))
table(data.spam[, 58]) # 標本数を確認
# nonspam    spam
#    2500     500

# 線形判別分析(不均衡データ)
data.spam.lda <- lda(type ~ ., data = data.spam, CV = TRUE)
( tab.spam <- table(data.spam[, 58], data.spam.lda$class) )
#           nonspam spam
# nonspam    2440   60
# spam        220  280

# SMOTE
data.spam.smote <- SMOTE(type ~ ., data = data.spam, perc.over = 500, k = 5, perc.under = 100)
table(data.spam.smote[, 58])
# nonspam    spam
#    2500    3000

# 線形判別分析(オーバーサンプリングしたデータ)
data.spam.smote.lda <- lda(type ~ ., data = data.spam.smote, CV = TRUE)
( tab.spam.smote <- table(data.spam.smote[, 58], data.spam.smote.lda$class) )
#         nonspam spam
# nonspam    2348  152
# spam        192 2808

# 分類精度の確認
sum(diag(tab.spam)) / sum(tab.spam)
# [1] 0.9066667
sum(diag(tab.spam.smote)) / sum(tab.spam.smote)
# [1] 0.9374545
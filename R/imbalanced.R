# install.packages("DMwR")
# install.packages("dplyr")
# install.packages("e1071")
library(caret)
library(DMwR) # SMOTE()関数用
library(dplyr)
library(e1071)

## 不均衡データとする前の状態の精度評価を行う

# データセットを用意
data <- iris %>%
  filter(Species %in% c("versicolor", "virginica")) %>%
  select(Sepal.Length, Petal.Width, Species) %>%
  mutate(Species=as.factor(as.character(Species)))
head(data, 3)
#   Sepal.Length Petal.Width    Species
# 1          7.0         1.4 versicolor
# 2          6.4         1.5 versicolor
# 3          6.9         1.5 versicolor

train_index <- createDataPartition(data$Species, p=0.7, list=FALSE)
train_data <- data[train_index,] # 訓練データ
test_data <- data[-train_index,] # 評価データ

# プロット
myplot <- function(data) {
  plot(Sepal.Length ~ Petal.Width, data=data, col=Species, pch=19,
       xlim=c(1, 2.5), ylim=c(4.5, 8))
}
myplot(train_data)

# SVM
computeSVM <- function(data) {
  cpsvm.train<-svm(Species~.,data)
  cpsvm.predict<-predict(cpsvm.train,newdata=test_data[,-3])
  table(test_data$Species,cpsvm.predict)
}
computeSVM(train_data)
#           cpsvm.predict
#            versicolor virginica
# versicolor         15         0
# virginica           2        13

# Random Forest
computeRF <- function(data) {
  model <- train(data %>% select(-Species), data$Species,
                 method="rf", preProcess=c("center", "scale"),
                 trControl=trainControl(method="oob"), ntree=2000)
  all_pred <- extractPrediction(list(model),
                                testX=test_data %>% select(-Species),
                                testY=test_data$Species)
  pred <- all_pred %>% filter(dataType == "Test")
  cm <- confusionMatrix(pred$pred, pred$obs)
  cm$table
}
computeRF(train_data)
#           Reference
#            Prediction   versicolor virginica
# versicolor         15         3
# virginica           0        12



## 不均衡データの精度評価を行う

# 不均衡データとする
data_imbalanced <- train_data %>%
  slice(c(1:35, sample(36:70, size = 6, replace = FALSE)))

myplot(data_imbalanced)
computeSVM(data_imbalanced)
#           cpsvm.predict
#            versicolor virginica
# versicolor         15         0
# virginica           6         9
computeRF(data_imbalanced)
#           Reference
#            Prediction   versicolor virginica
# versicolor         15         7
# virginica           0         8



## 不均衡データに対してオーバーサンプリングを行ったうえで精度評価を行う

# オーバーサンプリング
data_smote <- SMOTE(Species ~ ., data = data_imbalanced)
myplot(data_smote)
computeRF(data_smote)
#           Reference
#            Prediction   versicolor virginica
# versicolor         15         7
# virginica           0         8
data_imbalanced %>% count(Species)
# # A tibble: 2 × 2
#      Species     n
#       <fctr> <int>
# 1 versicolor    35
# 2  virginica     6
data_smote %>% count(Species)
# # A tibble: 2 × 2
#      Species     n
#       <fctr> <int>
# 1 versicolor    24
# 2  virginica    18


# クラスの重みづけを調整したうえで精度評価を行う

# SVM
computeSVM <- function(data) {
  wts<-100/table(data$Species)
  cpsvm.train<-svm(Species~., data, class.weights=wts)
  cpsvm.predict<-predict(cpsvm.train,newdata=test_data[,-3])
  table(test_data$Species,cpsvm.predict)
}
computeSVM(train_data)
#           cpsvm.predict
#            versicolor virginica
# versicolor         15         0
# virginica           3        12
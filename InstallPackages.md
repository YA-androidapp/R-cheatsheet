# CRANで公開されているすべてのパッケージをインストール

```r
packs <- available.packages()
nrow(packs)
head(packs)
```

## オンラインでインストール

```r
sapply(packs[, "Package"], function(p) if(!require(p, character.only=TRUE)){try(install.packages(p))})
```

## ネットワークに接続されたPCでダウンロードして、隔離されたPCでインストール

```r
# PC1でダウンロード
dir = "C:/Users/Admin/Downloads/Rpackages"
sapply(packs[, "Package"], function(p) try(download.packages(p, dir, type="source")))

# ダウンロード済みファイルの一覧を取得し、各々インストールを実施
ls.tgz <- list.files(dir, full.names=TRUE, pattern=".tar.gz")

  # 1. try(install.packages(ls.tgz, repos = NULL, type = "source"))
  #  OR
  # 2. try(install.packages(packs[, "Package"], contriburl = paste("file:", dir, sep=""), dependencies = TRUE, type = "source"))
  #  OR
# 3. 依存関係を満たさずインストールされないことがあるため何度か再試行を行うほうが良い
for(1:5){
  sapply(ls.tgz, function(p) if(!require(p, character.only=TRUE)){try(install.packages(p, repos = NULL, type = "source"))})
}
```

# Task Viewsを基に、分野ごとにパッケージをインストール

```r
install.packages("ctv")
library("ctv")

install.views("Bayesian")
install.views("ChemPhys")
install.views("ClinicalTrials")
install.views("Cluster")
install.views("DifferentialEquations")
install.views("Distributions")
install.views("Econometrics")
install.views("Environmetrics")
install.views("ExperimentalDesign")
install.views("ExtremeValue")
install.views("Finance")
install.views("FunctionalData")
install.views("Genetics")
install.views("Graphics")
install.views("HighPerformanceComputing")
install.views("MachineLearning")
install.views("MedicalImaging")
install.views("MetaAnalysis")
install.views("Multivariate")
install.views("NaturalLanguageProcessing")
install.views("NumericalMathematics")
install.views("OfficialStatistics")
install.views("Optimization")
install.views("Pharmacokinetics")
install.views("Phylogenetics")
install.views("Psychometrics")
install.views("ReproducibleResearch")
install.views("Robust")
install.views("SocialSciences")
install.views("Spatial")
install.views("SpatioTemporal")
install.views("Survival")
install.views("TimeSeries")
install.views("WebTechnologies")
install.views("gR")
```

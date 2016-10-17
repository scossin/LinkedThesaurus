##### recherche des CUI dans RxNorm
rm(list=ls())
map <- read.table("1100versUMLS.csv",sep="\t",header=T, stringsAsFactors = F)
writeLines(unique(map$CUI), "CUI.txt")

##### faire tourner le programme JAVA "SearchRxNormCode"
rxnorm <- read.table("dci_CUI_RxNorm.txt",sep="\t")
colnames(rxnorm) <- c("CUI","RXCUI")
map2 <- merge (map, rxnorm, by="CUI")
voir <- subset (map2, RXCUI == -999)

# # pour la thèse
# library(xtable)
# bool <- table(termes_CUI$V1) < 6
# noms <- names(table(termes_CUI$V1))[bool]
# these <- subset (termes_CUI, V1 %in% noms)
# these <- subset (termes_CUI, V1 == "C0068978")
# these$V3 <- NULL
# print(xtable(these),include.rownames = F)
# 
# fivenum(table(termes_CUI$V1))

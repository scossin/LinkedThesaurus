### On récupère les synonymes UMLS
map <- read.table("../versUMLS/1100versUMLS.csv",sep="\t",header=T,stringsAsFactors = F)
writeLines(unique(map$CUI), "dci_CUI.txt")

### le programme JAVA "Retrieve-Synonymes" récupère les synonymes
termes_CUI <- read.table("dci_CUI_termes.txt",sep="\t",quote="")
colnames(termes_CUI) <- c("CUI","synonymes")
  
# ajout des libellés principaux des concepts UMLS
ajout <- subset (map, select=c(CUI, lib_atome))
ajout$lib_atome <- tolower(ajout$lib_atome)
colnames(ajout) <- colnames(termes_CUI)
termes_CUI <- rbind (termes_CUI, ajout)
termes_CUI <- unique(termes_CUI)

# ajout des libellés des dci
ajout <- subset (map, select=c(CUI, dci))
ajout$dci <- tolower(ajout$dci)
colnames(ajout) <- colnames(termes_CUI)
termes_CUI <- rbind (termes_CUI, ajout)
termes_CUI <- unique(termes_CUI)

## 
write.table(termes_CUI, "dci_CUI_termes_libprincipaux.csv",col.names = T, row.names = F,quote=T,sep="\t")

## indexer ensuite avec le programme JAVA "indexation synonymes"
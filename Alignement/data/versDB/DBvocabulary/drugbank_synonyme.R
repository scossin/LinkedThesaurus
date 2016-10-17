##### Denormalise le fichier DB
rm(list=ls())
getwd()
df <- read.table("drugbank vocabulary.csv",sep=",",header=T,quote="\"",fill = T,stringsAsFactors =  F)
explose <- subset (df, select=c("DrugBank.ID","Synonyms"))

## séparer les synonymes
temp <- lapply(explose$Synonyms, function(x){
  x <- unlist(strsplit(x," \\| "))
})

## Nombre de synonymes par id
longueur <- unlist(lapply(temp, length))
## répète autant de fois les id que le nombre de synonymes
id_rep <- rep(explose$DrugBank.ID,longueur)
synonymes <- unlist(temp)
## combine id et synonymes
tab <- data.frame(DrugBank.ID = id_rep, synonyme = synonymes)

## ajout common name
ajout <- subset (df, select=c("DrugBank.ID","Common.name"))
colnames(ajout) <- colnames(tab)
tab <- rbind (ajout, tab)
tab <- unique(tab)

####
tab$termino <- "drugbank"
tab <- tab[,c(1,3,2)]
colnames(tab) <- c("code","termino","synonyme")
write.table(tab, "drugbank_synonymes.csv",sep="\t",row.names = F, col.names = T,quote=F)

### liste des libellés pour l'alignement
writeLines(tolower(tab$synonyme), "../versDB/libellesDB.txt")

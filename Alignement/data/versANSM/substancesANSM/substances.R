## Date de mise à jour 03/10/2016
### téléchargement du fichier sur le site de l'ANSM : 
# download.file(url="http://agence-prd.ansm.sante.fr/php/ecodex/telecharger/lirecomp.php",
#               destfile = "COMPO.txt")
rm(list=ls())
ANSM_COMPO <- read.table("COMPO.txt",sep="\t",fileEncoding = "ISO8859-1",quote="")
## code et libellé de la substance : 
ANSM_COMPO <- ANSM_COMPO[,3:4]
colnames(ANSM_COMPO) <- c("code","substance")
##
bool <- ANSM_COMPO$substance == ""
sum(bool)
voir <- subset (ANSM_COMPO, bool)
print(voir)
voir <- subset (ANSM_COMPO, code %in% voir$code)
voir <- voir[order(voir$code),]
voir <- unique(voir)
print (voir, row.names=F)

## Comme on peut le voir, la valeur est vide dans la colonne substance
ANSM_COMPO <- subset (ANSM_COMPO, !bool)

# dataframe substance :
substances <- subset (ANSM_COMPO, select=c("code","substance"))
substances <- unique(substances)
# nombre de codes différents :
length(unique(substances$code)) ## 4771
# nombre de substances différentes :
length(unique(substances$substance)) ## 5907

substances$libelle <- tolower(substances$substance)
## retire les accents
substances$libelle <- iconv(substances$libelle, to='ASCII//TRANSLIT')
## retire les espaces début et de fin
substances$libelle <- gsub("^[ ]+|[ ]+$","",substances$libelle)
bool <- grepl("\\[",substances$libelle)
voir <- subset (substances, bool)
substances$libelle <- gsub("[[:punct:]]"," ",substances$libelle)
substances$libelle <- gsub("^[ ]+|[ ]+$","",substances$libelle)
## pour indexation
write.table(substances, "substances_ANSM.csv",sep="\t",col.names=F, row.names=F)

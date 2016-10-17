library(test)
rm(list=ls())
bool <- ANSM_COMPO$substance == ""
print (sum(bool))
voir <- subset (ANSM_COMPO, bool)
voir <- subset (ANSM_COMPO, code %in% voir$code)
voir <- voir[order(voir$code),]
voir <- unique(subset (voir, select=c("code","substance")))
print (voir, row.names=F)

## Comme on peut le voir, la valeur est vide dans la colonne substance, bien que
# un libellé est présent pour un autre médicament
# on fait l'hypothèse que ces codes correspondent bien à ces libellés,
# on enlève les valeurs vides
ANSM_COMPO <- subset (ANSM_COMPO, !bool)

# dataframe substance :
substances <- subset (ANSM_COMPO, select=c("code","substance"))
substances <- unique(substances)
# nombre de codes différents :
length(unique(substances$code))
# nombre de substances différentes :
length(unique(substances$substance))

#
substances$libelle <- tolower(substances$substance)
substances$libelle <- retirer_accent(substances$libelle)
substances$libelle <- retirer_espace(substances$libelle)
bool <- grepl("\\[",substances$libelle)
voir <- subset (substances, bool)
substances$libelle <- gsub("[[:punct:]]"," ",substances$libelle )
substances$substance <- substances$libelle
write.table(substances, "substances_ANSM.csv",sep="\t",col.names=F, row.names=F)



################# NEW !! 
######################### Utiliser la fraction thérapeutique pour aligner et pas les SA 
rm(list=ls())
library(test)
ANSM_COMPO <- ANSM_COMPO
table(ANSM_COMPO$nature)

ft <- subset (ANSM_COMPO, nature == "FT")
CIS_ft <- subset (ANSM_COMPO, CIS %in% ft$CIS)
CIS_ft <- unique(ft$CIS)

### CIS qui ont un SA mais non pas la FT associée alors que d'autres médicaments l'ont ...
voir <- subset (ANSM_COMPO, !CIS %in% CIS_ft$CIS & code %in% CIS_ft$code)
table(voir$nature)

CIS_sans_ft <- subset (ANSM_COMPO, !code %in% CIS_ft$code)
table(CIS_sans_ft$nature)
bool<- grepl("opathi",CIS_sans_ft$substance,ignore.case = T)
sum(bool)
bool1<- grepl("CH",CIS_sans_ft$dosage,ignore.case = T)
sum(bool1)
voir <- subset (CIS_sans_ft, bool1)
CIS_sans_ft <- subset (CIS_sans_ft, !bool1 & !bool)
length(unique(CIS_sans_ft$code))

bool <- grepl("dompéridone",ANSM_COMPO$substance, ignore.case = T)
sum(bool)
voir <- subset (ANSM_COMPO, bool)

bool <- grepl("sodique",ANSM_COMPO$substance,ignore.case = T)
voir <- subset (ANSM_COMPO, bool)
length(unique(voir$substance))
voir <- subset (ANSM_COMPO, code %in% voir$code, select=c(code,substance))
voir <- unique(voir)
voir <- voir[order(voir$code),]
bool <- !grepl("sodique",voir$substance,ignore.case = T)
voir2 <- subset (voir, bool)
### stop : pravastatine sodique, normalement la FT est pravastatine mais ça ne figure pas
## c'est mal foutu, ça ne sert à rien de continuer par là
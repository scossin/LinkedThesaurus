rm(list=ls())
library(IMthesaurusANSM)
df <- thesaurus72013$df

variables <- c("thesaurus2009","thesaurus2010", "thesaurus2011", "thesaurus032012", 
"thesaurus122012", "thesaurus72013","thesaurus2014","thesaurus012015",
"thesaurus062015")

### chargement de toutes les extractions
df <- NULL
i <- variables[1]
for (i in variables){
  temp <- get(i)$df_decompose
  temp$origine <- NULL
  temp <- unique(temp)
  temp$thesaurus <- i
  df <- rbind (df, temp)
}

## merge avec la table : 
df$mol1 <- gsub ("^[ ]+|[ ]+$","",df$mol1)
df$mol2 <- gsub ("^[ ]+|[ ]+$","",df$mol2)
df <- unique(df)

## chaque thésaurus : date de la parution jusqu'à date - 1 de la parution de la mise à jour
dates_min <- c("29/06/2009", "17/12/2010","16/09/2011","29/03/2012","20/12/2012","31/07/2013","10/01/2014",
               "01/01/2015","01/06/2015")
dates_min <- as.Date(dates_min,format="%d/%m/%Y")
dates_max <- dates_min - 1
dates_max <- dates_max[-1]
dates_max <- append (dates_max, as.Date("31/12/2015",format="%d/%m/%Y"))
thesaurus <- data.frame(thesaurus = variables, date_min = dates_min, date_max=dates_max)
df2 <- merge (df, thesaurus, by="thesaurus") ## ajout des dates


## on retient les AD et les CI : 
table(df2$niveau)
df3 <- subset (df2, niveau %in% c("PC","PE","AD","CI"))

## possibilite de voir des interactions:  
voir <- subset (df3, mol2 == "SPIRONOLACTONE")

##################### Alignement entre le thesaurus et le sniiram avec le programme JAVA
## chargement molecules SNIIRAM 
## on a d'abord dénombré la liste des codes CIP13 présents entre le 1er janvier 2010 et 31122015
# on se restreint à ce subset pour les alignements
getwd()
sniiram <- read.table("molecules_SNIIRAM.csv",sep="\t",header=T,stringsAsFactors = F)
nrow(sniiram) ## 13 302 versus 23 532 au total dans la table SNIIRAM
moleculessniiram <- unique(sniiram$PHA_NOM_PA)

# méningocoque vaccin : case vide pour la substance !
bool <- moleculessniiram == ""
sum(bool)
moleculessniiram <- moleculessniiram[!bool]
moleculessniiram <-data.frame(molecule=moleculessniiram)
write.table(moleculessniiram, "moleculessniiram.csv",sep="\t",col.names = T, row.names=F)

### molecule du thesaurus pour AD et CI : 
moleculesthesaurus <- unique(c(df3$mol1, df3$mol2))
length(moleculesthesaurus)
writeLines(moleculesthesaurus, "moleculesthesaurus.txt")

###### résultats de l'alignement thésaurus vers sniiram
resultats <- read.table("moleculesthesaurusproposition.txt",sep="\t",fill=T,header=F,stringsAsFactors = F,
                        quote="")
colnames(resultats)<- c("thesaurus","score","sniiram","code")
resultats$code <- NULL
resultats<-unique(resultats)
bool <- resultats$thesaurus == resultats$sniiram
sum(bool) ## 564 perfect match
perfect <- subset (resultats, bool)
resultats<- subset (resultats,!bool)
bool <- resultats$score=="pas trouvé"
sum(bool)
pastrouve <- subset (resultats, bool)
length(unique(toupper(pastrouve$thesaurus))) ## 425 molécules du thésaurus non trouvés dans sniiram
resultats<- subset (resultats,!bool)

### match imparfait : alignement manuel : 
resultats$score <- as.numeric(resultats$score)
resultats <- resultats[order(-resultats$score),]
resultats_manu <- resultats
if (!file.exists("resultats_manu.csv")){
  write.table(resultats_manu, "resultats_manu.csv",sep="\t",col.names = T, row.names=F)
}
resultats_manu <- read.table("resultats_manu.csv",sep="\t",header=T,quote="")
manu1 <- subset(resultats_manu, manu==1)
perfect$manu <- "auto"
perfect2 <- rbind (perfect, manu1)

######################## BILAN DE L ALIGNEMENT : 
sniiram_non_matcher <- subset (sniiram, !sniiram$PHA_NOM_PA %in% perfect2$sniiram)
## molecules dans le sniiram non matché
bool <- moleculessniiram$molecule %in% perfect2$sniiram
moleculessniiram$molecule[!bool]
## molécules dans le thésaurus non matché ++ : ceux-ci sont plus importants à rechercher
# est-ce qu'il s'agit de molécules non rembrousées / vendues en ville ?
bool <- moleculesthesaurus %in% perfect2$thesaurus
moleculesthesaurus[!bool]
colnames(perfect2)
length(moleculesthesaurus)

## améliorer cette partie : 


######################################### filtrer la voie +++ 
library(test)
ANSM_CIS <- ANSM_CIS
colnames(ANSM_CIS)
table(ANSM_CIS$voie)
ANSM_CIS <- subset (ANSM_CIS, select=c("CIS","voie","princeps"))
ANSM_CIP <- subset (ANSM_CIP,select=c("CIP13","CIS"))
ajout_voie <- merge (ANSM_CIS, ANSM_CIP, by="CIS")
ajout_voie <- unique(ajout_voie)
sniiram <- merge (sniiram, ajout_voie, by.x="PHA_CIP_C13",by.y="CIP13",all.x=T)
colnames(sniiram)
sum(is.na(sniiram$voie))
voir <- subset (sniiram, is.na(voie))
## retire l'homéopathie : 
voir <- subset (voir, !PHA_ATC_L07 == "HOMEOPATHIE")
write.table(voir, "ajouter_la_voie.csv",sep="\t",col.names = T, row.names=F)


######## fichiers pour l'analyse des interactions : 
perfect3 <- merge (perfect2, sniiram, by.x="sniiram",by.y="PHA_NOM_PA", all.x=T)
## liste des codes CIP pour chaque molécule
tab <- tapply(perfect3$PHA_CIP_C13, perfect3$thesaurus, function(x){
  paste(x)
})
tab2 <- lapply(tab, function(x){
  paste(x, collapse=";")
})
tab <- data.frame(molecule = names(tab2), CIP13= as.character(tab2))
write.table(tab, "moleculesCIP5102016.txt",sep="\t",col.names=F, row.names=F, quote=F)

## liste des interactions dans le format demandé par le programme :
interaction <- subset (df3, mol1 %in% perfect3$thesaurus & mol2 %in% perfect3$thesaurus)
interaction$date_min <- format(interaction$date_min, format="%d/%m/%Y")
interaction$date_max <- format(interaction$date_max, format="%d/%m/%Y")
write.table(interaction, "interactions_details.csv",sep="\t",col.names=T, row.names=F)
interaction$niveau<- NULL
interaction$thesaurus <- NULL
write.table(interaction, "interactions.csv",sep="\t",col.names=T, row.names=F)



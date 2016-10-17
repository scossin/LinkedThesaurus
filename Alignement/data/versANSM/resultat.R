#################### Mapping entre les substances du thésaurus 2013 et la base ANSM
rm(list=ls())
resultat <- read.table("csv/dci2013_substances_ANSM.csv",sep="\t",fill=T,quote="", stringsAsFactors = F)
resultat$V4 <-NULL
colnames(resultat) <- c("dci","score","substance","code")
resultat$score <- as.numeric(resultat$score)

get_perfect <- function(resultat){
  bool <- resultat$dci == resultat$substance
  perfect <- subset (resultat, bool, select=c(dci,code))
  perfect<-unique(perfect)
  bool <- table(perfect$dci) > 1
  if (any(bool)){
    cat ("certains dci ont plusieurs codes : \n")
    voir <- subset (perfect, bool)
    print (voir)
  }
  cat(length(unique(perfect$dci)), " perfect match troués \n")
  return(perfect)
}

get_perfect_non <- function(resultat){
  bool <- resultat$dci2 == resultat$substance
  perfect <- subset (resultat, bool, select=c(dci,dci2,code))
  perfect<-unique(perfect)
  bool <- table(perfect$dci) > 1
  if (any(bool)){
    cat ("certains dci ont plusieurs codes : \n")
    voir <- subset (perfect, bool)
    print (voir)
  }
  cat(length(unique(perfect$dci)), " perfect match troués \n")
  return(perfect)
}

get_partial <- function(resultat, seuil){
  partial <- subset (resultat, score > seuil, select=c(dci,code))
  partial<-unique(partial)
  bool <- table(partial$dci) > 1
  if (any(bool)){
    cat ("certains dci ont plusieurs codes : \n")
    noms <- names(table(partial$dci)[bool])
    print (noms)
    cat(length(unique(partial$dci)), " partial match troués \n")
    return(list(partial=partial, dci = noms))
  }
  cat(length(unique(partial$dci)), " partial match troués \n")
  return(partial)
}

perfect <- get_perfect(resultat)

resultat <- subset (resultat, !code %in% perfect$code)

partial4 <- get_partial (resultat, 4)$partial
plusieurs <- get_partial (resultat, 4)$dci
voir <- subset (resultat, dci %in% plusieurs)
partial4 <- subset (partial4, !dci == "vitamine a")

## 
resultat <- subset (resultat, !code %in% partial4$code)
partial3 <- get_partial (resultat, 3)$partial
plusieurs <- get_partial (resultat, 3)$dci
voir <- subset (resultat, dci %in% plusieurs)
partial3 <- subset (partial3, !dci %in% c("vitamine a","p a s sodique"))

### ya aminosalicylate à récupérer
library(test)
bool <- grepl("Quadrasa",ANSM_CIS$princeps, ignore.case = T)
any(bool)
voir <- subset (ANSM_CIS, bool)
voir2 <- subset (ANSM_COMPO, CIS %in% voir$CIS)
##

voir_substance <- function(nom_commercial){
  bool <- grepl(nom_commercial,ANSM_CIS$princeps, ignore.case = T)
  if (!any(bool)){
    cat("aucun nom commercial ", nom_commercial, "trouvé dans le répertoire du médicament")
  } else {
    voir <- subset (ANSM_CIS, bool)
    voir2 <- subset (ANSM_COMPO, CIS %in% voir$CIS)
    return (voir2)
  }
}

voir_substance("fenbufen")

resultat <- subset (resultat, !code %in% partial3$code)
resultat <- resultat[with(resultat, order(-score)),]
nom_fichier <- "csv/resultat_manuel1.csv"
if (file.exists(nom_fichier)){
  cat ("le fichier ", nom_fichier, " existe déjà \n")
} else {
  write.table(resultat,nom_fichier ,sep="\t", col.names=T, row.names=F)
}
manu1 <- read.table(nom_fichier, sep="\t", header=T,quote="")
manu1 <- subset(manu1, manu == 1, select=c(dci, code))
manu1 <- unique(manu1)

sofar <- rbind (perfect, partial4, partial3,manu1)

###
dci <- readLines("csv/dci2013.txt")
bool <- dci %in% sofar$dci
non_trouve <- dci[!bool]
### exclus manuellement par la pharmaco : 
exclus <- readLines("csv/exclus_dci_manuel.txt")
bool <- non_trouve %in% exclus

non_trouve <- non_trouve[!bool]
non_trouve <- data.frame(dci = non_trouve)

### modifications mnauelles des libelles
non_trouve$dci2 <- as.character(non_trouve$dci)
remplacer <- function(regex, remplacement){
  bool <- grepl(regex, non_trouve$dci)
  if (any(bool)){
    print (non_trouve$dci[bool])
    non_trouve$dci2[bool] <- remplacement
    return (non_trouve)
  } else {
    cat (regex, "pas trouvé \n")
    return(non_trouve)
  }
}
non_trouve <- remplacer ("rougeoleux","rougeole")
non_trouve <- remplacer ("tioguanine","thioguanine")
non_trouve <- remplacer ("succinylcholine","suxamethonium")
non_trouve <- remplacer ("ricinus","ricin")
non_trouve <- remplacer ("styrenesulfonate","polystyrene sulfonate de calcium")
non_trouve <- remplacer ("piroxicam","piroxicam-betacyclodextrine (complexe)")
non_trouve <- remplacer ("p a s sodique","p a s sodique anhydre")
non_trouve <- remplacer ("pimethixene","pimetixene")
non_trouve <- remplacer ("immunoglobulines equines antilymphocyte humain","immunoglobuline equine anti-thymocytes humains")
non_trouve <- remplacer ("benethamine-penicilline","benethamine penicilline")
non_trouve <- remplacer ("pimethixene","pimetixene")
non_trouve <- remplacer ("norepinephrine","noradrenaline")
non_trouve <- remplacer ("acetylsulfafurazol","acetyl sulfafurazol")
non_trouve <- remplacer ("catioresine sulfo sodique","sodium (polystyrene sulfonate de)")
non_trouve <- remplacer ("peg-interferon alfa-2a","peginterferon alfa-2a")

## autre nom
non_trouve <- remplacer ("dicitrate trimagnesien","citrate de magnesium")
### non commercialisé :
non_trouve <- remplacer ("guanethidine","")
non_trouve <- remplacer ("azatadine","")
non_trouve <- remplacer ("barbital","")
non_trouve <- remplacer ("colestilan","")
non_trouve <- remplacer ("delorazepam","")
non_trouve <- remplacer ("fenbufene","")
# excipient 
non_trouve <- remplacer ("nonoxynol","")
# métabolite de l'amitriptyline deja present dans le thesaurus :
non_trouve <- remplacer ("nortriptyline","")


## ajout des acides 
bool <- grepl("^acide",dci)
acides <- dci[bool]
acides2 <- gsub ("acide ","",acides)
acides2 <- gsub ("ique$","ate",acides2)

bool <- grepl("acide",non_trouve$dci)
non_trouve <- subset (non_trouve, !bool)
non_trouve <- rbind (non_trouve, data.frame(dci=acides, dci2 = acides2))
bool <- non_trouve$dci2 == ""
non_trouve <- subset (non_trouve, !bool)
#writeLines(non_trouve$dci2,"csv/non_trouve.txt")

resultat_non <-  read.table("csv/non_trouve_ANSM.csv",sep="\t",fill=T,quote="", stringsAsFactors = F)
resultat_non$V4 <-NULL
colnames(resultat_non) <- c("dci2","score","substance","code")
resultat_non <- merge (resultat_non, non_trouve, by="dci2")

perfect_non <- get_perfect_non(resultat_non)
sofar$dci2 <- sofar$dci
sofar <- rbind (sofar, perfect_non)

resultat_non <- subset (resultat_non, !code %in% perfect_non$code)
resultat_non$score <- as.numeric(resultat_non$score)
resultat_non <- resultat_non[order(-resultat_non$score),]
nom_fichier <- "csv/resultat_manuel2.csv"
if (file.exists(nom_fichier)){
  cat ("le fichier ", nom_fichier, " existe déjà \n")
} else {
  write.table(resultat_non,nom_fichier ,sep="\t", col.names=T, row.names=F)
}

manu2 <- read.table(nom_fichier, sep="\t", header=T,quote="")
manu2 <- subset(manu2, manu == 1, select=c(dci, dci2,code))
manu2 <- unique(manu2)
sofar <- rbind (sofar, manu2)

### ce qui reste là : les non commercialisés
bool <- dci %in% sofar$dci
dci[!bool]

save(sofar, file="dci2013_substances_ANSM.rdata")


### 



#### bilan :

rm(list=ls())
load("dci2013_substances_ANSM.rdata")
dci <- readLines("csv/dci2013.txt")
bool <- dci %in% sofar$dci
non_trouve <- dci[!bool]

### perfect, partial ...
substances <- subset (ANSM_COMPO, select=c(code, substance))
substances <- unique(substances)
substances$substance <- tolower(substances$substance)
substances$substance <- retirer_accent(substances$substance)
substances$substance <- retirer_espace(substances$substance)
sofar2 <- merge (sofar, substances,by="code")


bool <- sofar2$dci == sofar2$substance | sofar2$dci2 == sofar2$substance
sum(bool)
voir <- subset (sofar2, bool)
length(unique(voir$dci)) ### 710 perfect match
voir2 <- subset (sofar2, !bool & !dci %in% voir$dci)
length(unique(voir2$dci))

710+273+37
length(non_trouve)
length(dci)

##
voir2$substance
bool_base <- grepl("base",voir2$substance)
sum(bool)
base <- subset (voir2, bool_base)
length(unique(base$dci)) #### 55 bases (710+55 = 765)
218/1020

bool_chlorhydrate <- grepl("chlorhydrate",voir2$substance,ignore.case = T)
chlorhydrate <- subset (voir2, bool_chlorhydrate & !bool_base)
length(unique(chlorhydrate$dci)) ### 116 chlorydate (273-55) (273-55 - 116 = 102)

bool_maleate <- grepl("maleate",voir2$substance,ignore.case = T)
maleate <- subset (voir2, bool_maleate & !bool_base)
length(unique(maleate$dci)) ### 116 chlorydate (273-55) (273-55 - 116 = 102)

bool_sodique <- grepl("sodique",voir2$substance)
sodique <- subset (voir2, bool_sodique & !bool_chlorhydrate & !bool_base)
length(unique(sodique$dci)) ### 24

sum(bool)

bool <- sofar2$nature == "SA"
sofar2$FT <- ifelse (bool, 0, 1)

tab <- tapply(sofar2$FT, sofar2$dci, sum)
tab <- data.frame(dci = names(tab), frequenceFT = as.numeric(tab))
voir <- subset (tab, frequenceFT==2)
voir2 <- merge (voir, sofar2, by="dci")
voir3 <- subset (ANSM_COMPO, code == 3641)
voir4<- subset (ANSM_COMPO, CIS %in% voir3$CIS)
voir4 <- voir4[order(voir4$CIS),]
bool <- tab==2
sum(bool)

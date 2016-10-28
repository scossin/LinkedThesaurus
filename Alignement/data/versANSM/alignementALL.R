###### Mapping entre toutes les substances du thésaurus et les substances de la base ANSM
rm(list=ls())
### toutes les molécules des thesauri ont été extraites depuis 2010
## On cherche à trouver un lien entre ces molécules et les substances du répertoire ANSM
## Les substances du répertoire ANSM ont été indexées dans Lucene
dci <- readLines("../dciThesaurus/moleculesthesaurus.txt")
length(dci) ## Le programme JAVA recherche dans l'index ces 1131 libellés
resultat <- read.table("substancesANSM/moleculesthesaurus_proposition.txt",sep="\t",fill=T,quote="", stringsAsFactors = F)
colnames(resultat) <- c("dci2","score","substance","code")
resultat$dci <- dci
resultat$score <- as.numeric(resultat$score)
colnames(resultat)
## colonnes : 
# dci : libellé comme il apparait dans le thésaurus des interactions
# dci2 : libellé normalisé par le programme JAVA, comme il est recherché dans l'index
# score : score renvoyé par Lucene
# substance : libellé de la substance du répertoire des médicaments de l'ANSM
# code : code de la substance dans le répertoire des médicaments de l'ANSM

## fonction pour détecter un match parfait
get_perfect <- function(resultat){
  bool <- resultat$dci2 == resultat$substance
  perfect <- subset (resultat, bool)
  cat(length(unique(perfect$dci)), " perfect match trouvés \n")
  return(perfect)
}


########
#### Etape 1 : validation automatique

perfect <- get_perfect(resultat)
# relation
perfect$manu <- "same"
# méthode 
perfect$validation <- "automatique"
resultat <- subset (resultat, !code %in% perfect$code)




########
#### Etape 2 : validation semi-automatique
## j'ai pris un score de 4 arbitrairement
partial4 <- subset (resultat, score > 4) 
partial4 <- partial4[order(-partial4$score),]
## ouverture du fichier dans un tableur Excel et validation semi-automatique
if (!file.exists("manu/imparfait1.csv")){
  write.table(partial4, "manu/imparfait1.csv",sep="\t",col.names=T, row.names=F)
}
partial4 <- read.table("manu/imparfait1.csv",sep="\t",header=T)
table(partial4$manu)
partial4 <- subset (partial4, manu != 0)
partial4$validation <- "semiautomatique"
perfect2 <- rbind (perfect, partial4)
resultat <- subset (resultat, !code %in% perfect2$code)


########
#### Etape 2 bis : validation semi-automatique encore
bool <- !is.na(resultat$score)
partial <- subset (resultat, bool)
partial <- partial[order(-partial$score),]
######
if (!file.exists("manu/imparfait2.csv")){
  write.table(partial, "manu/imparfait2.csv",sep="\t",col.names=T, row.names=F)
}
partial <- read.table("manu/imparfait2.csv",sep="\t",header=T,quote="")
partial <- subset (partial, manu != 0)
partial$validation <- "semiautomatique"
perfect3 <- rbind (perfect2, partial)
resultat <- subset (resultat, !code %in% perfect3$code)


########
#### Etape 3 : validation manuelle
## j'essaie de comprendre manuellement pourquoi certaines molécules du thésaurus
# n'ont pas été trouvées dans les substances du répertoire de l'ANSM

## ménages : 
trouve <- perfect3
partial <- NULL
perfect2 <- NULL
perfect <- NULL
perfect3 <- NULL
partial4 <- NULL
resultat <- NULL

## non trouvé  : 
bool <- dci %in% trouve$dci
non_trouve <- unique(dci[!bool])
length(unique(non_trouve)) ## 82 molécules non trouvées
non_trouve <- data.frame(dci = non_trouve)
# on va modifier le libellé de la substance pour pouvoir la trouver
non_trouve$dci2 <- as.character(non_trouve$dci)
# liste des molecules exclues par le service de pharmacovigilance
exclus <- readLines("manu/exclus_dci_manuel.txt")
bool <- non_trouve$dci %in% toupper(exclus)
sum(bool)
non_trouve$dci2[bool] <- "exclusServicePharmacovigilance"
# modifications manuelles des libelles

# fonction pour remplacer dci2
remplacer <- function(regex, remplacement){
  bool <- grepl(regex, non_trouve$dci,ignore.case = T)
  if (any(bool)){
    print (non_trouve$dci[bool])
    non_trouve$dci2[bool] <- remplacement
    return (non_trouve)
  } else {
    cat (regex, "pas trouvé \n")
    return(non_trouve)
  }
}

## variations lexicales :
non_trouve <- remplacer ("tioguanine","thioguanine")
non_trouve <- remplacer ("pimethixene","pimetixene")
non_trouve <- remplacer ("acetylsulfafurazol","acetyl sulfafurazol")
non_trouve <- remplacer ("peg-interferon alfa-2a","peginterferon alfa-2a")
non_trouve <- remplacer ("aliskiren","aliskirene")
non_trouve <- remplacer ("bupropion","bupropione")
non_trouve <- remplacer ("CERTOLUZUMAB","CERTOLIZUMAB")
non_trouve <- remplacer ("ESLICARBAMAZEPINE","ESLICARBAZEPINE")
non_trouve <- remplacer ("ESCLICARBAZEPINE","ESLICARBAZEPINE")
non_trouve <- remplacer ("MYRISTALKONIUM","MIRISTALKONIUM")
non_trouve <- remplacer ("ALUMINIUM","GEL D'HYDROXYDE D'ALUMINIUM ET DE CARBONATE DE MAGNÉSIUM CODESSÉCHÉS")
non_trouve <- remplacer ("ETORECOXIB","ETORICOXIB")

## famipridine : il y en a 2 
non_trouve <- remplacer ("FAMPRIDINE","AMIFAMPRIDINE")
non_trouve <- rbind (non_trouve, data.frame(dci = "FAMPRIDINES",dci2="FAMPRIDINE"))

## autre nom
non_trouve <- remplacer ("rougeoleux","rougeole")
non_trouve <- remplacer ("succinylcholine","suxamethonium")
non_trouve <- remplacer ("ricinus","ricin")
non_trouve <- remplacer ("styrenesulfonate","polystyrene sulfonate de calcium")
non_trouve <- remplacer ("piroxicam","piroxicam-betacyclodextrine (complexe)")
non_trouve <- remplacer ("p a s sodique","p a s sodique anhydre")
non_trouve <- remplacer ("immunoglobulines equines antilymphocyte humain","immunoglobuline equine anti-thymocytes humains")
non_trouve <- remplacer ("norepinephrine","noradrenaline")
non_trouve <- remplacer ("catioresine sulfo sodique","sodium (polystyrene sulfonate de)")
non_trouve <- remplacer ("dicitrate trimagnesien","citrate de magnesium")

## non commercialisé :
non_trouve <- remplacer ("azatadine","NonCommercialisé")
non_trouve <- remplacer ("barbital","NonCommercialisé")
non_trouve <- remplacer ("colestilan","NonCommercialisé")
non_trouve <- remplacer ("delorazepam","NonCommercialisé")
non_trouve <- remplacer ("fenbufene","NonCommercialisé")
# excipient 
non_trouve <- remplacer ("nonoxynol","Excipient")
# métabolite de l'amitriptyline deja present dans le thesaurus :
non_trouve <- remplacer ("nortriptyline","Metabolite")
# familles ou aliments non presents
non_trouve <- remplacer("fer par voie injectable","Famille")
non_trouve <- remplacer("voie vaginale","Famille")
non_trouve <- remplacer("voie orale","Famille")
non_trouve <- remplacer("pamplemousse","Aliment")
non_trouve <- remplacer("preservatifs","Dispositif")
non_trouve <- remplacer("theine","Aliment")

## ajout des acides 
bool <- grepl("^acide",dci,ignore.case = T)
acides <- dci[bool]
acides2 <- gsub ("acide ","",acides,ignore.case = T)
acides2 <- gsub ("ique$","ATE",acides2,ignore.case = T)
bool <- grepl("acide",non_trouve$dci,ignore.case = T)
non_trouve <- rbind (non_trouve, data.frame(dci=acides, dci2 = acides2))

## on retire tous ceux qu'on ne va pas chercher : 
sort(table(non_trouve$dci2))
exclus <- c("exclusServicePharmacovigilance","NonCommercialisé",
            "Aliment","Dispositif","Metabolite","Excipient","Famille")
exclus <- subset (non_trouve, dci2 %in% exclus)
non_trouve <- subset (non_trouve, !dci2 %in% exclus$dci2)

### Recherche dans l'index Lucene les molécules non trouvées
## après modifications de leurs libellés
fichier <- "substancesANSM/moleculesthesaurus_non_trouve.txt"
if (!file.exists(fichier)){
  writeLines(non_trouve$dci2,fichier)
}
## le programme JAVA sort un fichier .txt, le modifier par .csv 
# Le fichier est ensuite ouvert dans LibreOffice pour validation semi-automatique
resultat_non <-  read.table("manu/non_trouve_proposition.csv",sep="\t",fill=T,quote="", stringsAsFactors = F)
colnames(resultat_non) <- c("dci2","score","substance","code", "manu")
resultat_non$dcirenommer <- non_trouve$dci2
resultat_non$dci <- non_trouve$dci
# dci : libellé comme il apparait dans le thésaurus des interactions
# dcirenommer : libellé remplacé manuellement 
# dci2 : libellé renommé, comme il est recherché dans l'index
# score : score renvoyé par Lucene
# substance : libellé de la substance du répertoire des médicaments de l'ANSM
# code : code de la substance dans le répertoire des médicaments de l'ANSM
perfect_non <- subset (resultat_non, manu !=0)
trouve$dcirenommer <- NA
perfect_non$validation <- "manuelle"

perfect4 <- rbind (trouve, perfect_non)
table(perfect4$manu)

### Au total, les non trouvés : 
bool <- dci %in% perfect4$dci
sum(!bool) ### 49 non matchés 
dci[!bool] ## Ces molécules présentent dans le thésaurus ne sont pas trouvées
# dans le répertoire des médicaments de l'ANSM

bool <- !dci %in% exclus$dci & !dci %in% perfect4$dci
dci_exclusajout <- dci[bool] ## "MAGNESIUM (HYDROXDE DE)" "PEG-INTERFERON"   non trouvés et non exclus par le service de pharmacovigilance
dci_exclusajout <- data.frame (dci = dci_exclusajout, dci2="")
colnames(exclus)
exclus <- rbind (exclus, dci_exclusajout)

output <- perfect4
colonnes <- c("dci","dcirenommer","manu","code","substance","validation")
output <- subset (output, select=colonnes)
colnames(output) <- c("dci","dcirenommer","relation","code","substance","validation")

### colonnes : 
# dci : libellé comme il apparait dans le thésaurus des interactions
# dcirenommer : dci remplacé manuellement, dans certains cas, par celui-ci pour matcher 
# relation : dci - relation - substance ANSM (relation du triplet)
# code : code de la substance dans le répertoire des médicaments de l'ANSM
# substance : libellé de la substance du répertoire des médicaments de l'ANSM
# validation : automatique, semiautomatique ou manuel

#### Export (commentés)
# write.table(output,"RelationThesaurusRepertoireTemp1.csv",sep="\t",col.names=T, row.names=F)
#write.table(exclus,"exclus.csv",sep="\t",col.names=T, row.names=F)
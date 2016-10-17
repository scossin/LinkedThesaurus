###### Mapping entre toutes les substances du thésaurus et les substances de la base ANSM
rm(list=ls())
resultat <- read.table("moleculesthesaurus_proposition.txt",sep="\t",fill=T,quote="", stringsAsFactors = F)
## toutes les molécules des thésaurus
dci <- readLines("../dciThesaurus/moleculesthesaurus.txt")
colnames(resultat) <- c("dci2","score","substance","code")
resultat$dci <- dci
resultat$score <- as.numeric(resultat$score)

get_perfect <- function(resultat){
  bool <- resultat$dci2 == resultat$substance
  perfect <- subset (resultat, bool)
  cat(length(unique(perfect$dci)), " perfect match trouvés \n")
  return(perfect)
}

perfect <- get_perfect(resultat)
perfect$manu <- "same"
resultat <- subset (resultat, !code %in% perfect$code)
partial4 <- subset (resultat, score > 4) 
partial4 <- partial4[order(-partial4$score),]

######
if (!file.exists("manu/imparfait1.csv")){
  write.table(partial4, "manu/imparfait1.csv",sep="\t",col.names=T, row.names=F)
}
partial4 <- read.table("manu/imparfait1.csv",sep="\t",header=T)
table(partial4$manu)
partial4 <- subset (partial4, manu != 0)
perfect2 <- rbind (perfect, partial4)
resultat <- subset (resultat, !code %in% perfect2$code)
bool <- !is.na(resultat$score)
partial <- subset (resultat, bool)
partial <- partial[order(-partial$score),]

######
if (!file.exists("manu/imparfait2.csv")){
  write.table(partial, "manu/imparfait2.csv",sep="\t",col.names=T, row.names=F)
}
partial <- read.table("manu/imparfait2.csv",sep="\t",header=T,quote="")
partial <- subset (partial, manu != 0)
perfect3 <- rbind (perfect2, partial)
resultat <- subset (resultat, !code %in% perfect3$code)

## non trouvé  : 
bool <- dci %in% perfect3$dci
non_trouve <- dci[!bool]
non_trouve <- data.frame(dci = non_trouve)
non_trouve$dci2 <- as.character(non_trouve$dci)
### liste des molecules exclues par le service de pharmacovigilance
exclus <- readLines("manu/exclus_dci_manuel.txt")
bool <- non_trouve$dci %in% toupper(exclus)
sum(bool)
non_trouve$dci2[bool] <- ""
### modifications mnauelles des libelles
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

### famipridine : il y en a 2 
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

### non commercialisé :
non_trouve <- remplacer ("azatadine","")
non_trouve <- remplacer ("barbital","")
non_trouve <- remplacer ("colestilan","")
non_trouve <- remplacer ("delorazepam","")
non_trouve <- remplacer ("fenbufene","")
# excipient 
non_trouve <- remplacer ("nonoxynol","")
# métabolite de l'amitriptyline deja present dans le thesaurus :
non_trouve <- remplacer ("nortriptyline","")
# familles ou aliments non presents
non_trouve <- remplacer("fer par voie injectable","")
non_trouve <- remplacer("voie vaginale","")
non_trouve <- remplacer("voie orale","")
non_trouve <- remplacer("pamplemousse","")
non_trouve <- remplacer("preservatifs","")
non_trouve <- remplacer("theine","")

## ajout des acides 
bool <- grepl("^acide",dci,ignore.case = T)
acides <- dci[bool]
acides2 <- gsub ("acide ","",acides,ignore.case = T)
acides2 <- gsub ("ique$","ATE",acides2,ignore.case = T)
bool <- grepl("acide",non_trouve$dci,ignore.case = T)
non_trouve <- rbind (non_trouve, data.frame(dci=acides, dci2 = acides2))
bool <- non_trouve$dci2 == ""
sum(bool)
non_trouve <- subset (non_trouve, !bool)

if (!file.exists("non_trouve.txt")){
  writeLines(non_trouve$dci2,"non_trouve.txt")
}

## le programme JAVA sort un fichier .txt, le modifier par .csv apres ajout d une colonne manu
resultat_non <-  read.table("manu/non_trouve_proposition.csv",sep="\t",fill=T,quote="", stringsAsFactors = F)
colnames(resultat_non) <- c("dci2","score","substance","code", "manu")
resultat_non$dci <- non_trouve$dci
perfect_non <- subset (resultat_non, manu !=0)
perfect3$dci2 <- perfect3$dci
perfect4 <- rbind (perfect3, perfect_non)
table(perfect4$manu)

bool <- dci %in% perfect4$dci
sum(!bool) ### 49 non matchés 
dci[!bool]

##
bool_base <- grepl("base",perfect4$substance)
sum(bool)
base <- subset (perfect4, bool_base)
length(unique(base$dci)) #### 55 bases (710+55 = 765)
218/1020

bool_chlorhydrate <- grepl("chlorhydrate",perfect4$substance,ignore.case = T)
chlorhydrate <- subset (perfect4, bool_chlorhydrate & !bool_base)
length(unique(chlorhydrate$dci)) ### 116 chlorydate (273-55) (273-55 - 116 = 102)

bool_maleate <- grepl("maleate",perfect4$substance,ignore.case = T)
maleate <- subset (perfect4, bool_maleate & !bool_base)
length(unique(maleate$dci)) ### 116 chlorydate (273-55) (273-55 - 116 = 102)

bool_sodique <- grepl("sodique",perfect4$substance)
sodique <- subset (perfect4, bool_sodique & !bool_chlorhydrate & !bool_base)
length(unique(sodique$dci)) ### 24

sum(bool)

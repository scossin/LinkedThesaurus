##### Dans alignementALL, j'ai recherché des alignements 1 à 1
### Or il est peut être possible qu'il existe 1 molécule dans le thésuarus
## correspond à plusieurs molécules dans le répertoire ANSM 
rm(list=ls())
alignement1 <- read.table("RelationThesaurusRepertoireTemp1.csv",sep="\t",header=T,
                          stringsAsFactors = F)

## toutes les dci, renommés ou non : 
alldci <- unique(c(alignement1$dci, alignement1$dcirenommer))
bool <- (is.na(alldci))
alldci <- alldci[!bool]
writeLines(as.character(alldci), "manuSuite/dcithesaurusSuite.txt")

## resultats
resultat <- read.table("manuSuite/dcithesaurusSuitePropositions.txt",sep="\t",quote="",
                       fill=T,stringsAsFactors = F)
colnames(resultat) <- c("dci","score","substance","code")

## Je procède par élimination : 
# je retire tous les codes du répertoire des médicaments que je connais
# je recherche dans les libellés des codes que je ne connais pas

bool <- resultat$code %in% alignement1$code
resultat <- subset (resultat, !bool)
resultat$score <- as.numeric(resultat$score)
## enlève les non trouvés
resultat <- subset (resultat, !is.na(score))
resultat <- resultat[order(-resultat$score),]
fichier <- "manuSuite/alignementmanu2.csv"
if (!file.exists(fichier)){
  write.table(resultat,fichier, sep="\t",col.names=T, row.names=F,quote=F)
}
resultat <- read.table("manuSuite/alignementmanu2.csv",sep="\t",quote="", stringsAsFactors = F)
colnames(resultat) <- c("dci","score","substance","code", "manu")
resultat$substance <- NULL

## charge les substances
substances <- read.table("substancesANSM/substances_ANSM.csv",sep="\t",header=F, stringsAsFactors = F)
colnames(substances) <- c("code","substances","libelle")
substances$libelle <- NULL
resultat2 <- merge (resultat, substances, by="code")

## pareil pour alignement1
alignement1$substance <- NULL
all(alignement1$code %in% substances$code)
alignement1 <- merge (alignement1, substances, by="code")
colnames(resultat2)
colnames(alignement1)

bool <- resultat2$dci %in% alignement1$dcirenommer
sum(bool)
resultat2$dcirenommer <- ifelse (bool, resultat2$dci, NA)
resultat2$dci <- ifelse (bool, NA, resultat2$dci)
colnames(resultat2)
colnames(alignement1)
resultat2$validation <- "semiautomatique"
resultat2$score <- NULL
colnames(resultat2)[3] <- "relation"

##
both <- rbind (alignement1, resultat2)
both <- unique(both)

## je dois rajouter les dci pour les dci renommées 

temp <- subset (alignement1, !is.na(dcirenommer),select=c(dci, dcirenommer))
temp <- unique(temp)
colnames(temp) <- c("dciajout","dcirenommer")

both2 <- merge (both, temp, by="dcirenommer",all.x=T)
bool <- is.na(both2$dci)
sum(bool)
both2$dci <- ifelse (bool, both2$dciajout, both2$dci)
both2$dciajout <- NULL

both2 <- both2[order(both2$dci),]
both3 <- subset (both2, select = c("dci","dcirenommer","relation","code","substances","validation"))

#### au final : 
table(both3$relation)
keep <- subset (both3, relation %in% c("same","hasform","formof") )
write.table(keep,"RelationThesaurusRepertoireFinal28102016.csv",sep="\t",col.names=T, row.names=F,na = "")
# write.table(dci_exclusajout,"exclus.csv",sep="\t",col.names=T, row.names=F)

### pour un alignement en aveugle
louis <- both3
louis$relation <- ""
colnames(louis)
bool <- louis$validation =="automatique"
sum(bool)
temp <- subset (louis, bool)
louis <- subset (louis, !code %in% temp$code)
write.table(louis,"RelationAvalider28102016.csv",sep="\t",col.names=T, row.names=F,na="")

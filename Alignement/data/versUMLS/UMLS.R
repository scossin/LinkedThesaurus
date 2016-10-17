### résultats des alignements
rm(list=ls())
getwd()
map1 <- read.table("dci_thesaurus_to_umls.txt",sep="\t",fill=T, quote="", stringsAsFactors = F)
colnames(map1) <- c("dci","code_atome","termino","lib_atome","CUI","lib_CUI")

## non trouvé
bool <- map1$code_atome == " non trouvé"
sum(bool) / nrow(map1) ## 9%

## non exact match : 
bool_non_exact <- (tolower (map1$dci) != tolower(map1$lib_atome)) & map1$code_atome != " non trouvé"
sum(bool_non_exact) ### 44 non exacts match parmi les trouvés
voir <- subset (map1, bool_non_exact)

## non exact match mais validé manuellement : 
valide_manu <- c("Sodium (oxybate de)","Alpha-pinene","Insuline humaine recombinante",
                 "Loflazepate","Potassium (citrate de)","Sodium (docusate de)","Sodium (nitroprussiate de)",
                 "Terpinol","Tenofovir disoproxil","Alpha-tocopherol",
                 "Sodium (chlorure de)", "Sodium (bicarbonate de)")

## on refait passer ceux qui :
# n'ont pas été trouvé
# n'ont pas été validé manuellement si pas exact match
bool_non_valide <- (!(tolower (map1$dci) == tolower(map1$lib_atome)) & !map1$dci %in% valide_manu) |
  map1$code_atome == " non trouvé"
sum(bool_non_valide) ## 139

to_map2 <- subset (map1, bool_non_valide)
sum(to_map2$code_atome == " non trouvé")

## pour la these : 
# nrow(map1) - length(valide_manu)
# (nrow(map1) - length(valide_manu)) / 1102
# extraction <- subset (map1, lib_atome %in% c("Aciclovir","Oxybate de sodium","Acide folinique",
#                                             "aceprometazine") | dci == "Acide alendronique")
# library(xtable)
# extraction$code_atome <- NULL
# colnames(extraction) <- c("libellé thesaurus","terminologie","libellé synonyme","identifiant du concept","libellé préféré")
# titre <- "Exemples d'alignement vers l'UMLS. Pour chaque libellé du thésaurus, un libellé similaire est recherché
# parmi tous les termes contenus dans les terminologies de l'UMLS. Le libellé du thésaurus est ainsi rattaché à un concept UMLS. 
# Le libellé préféré du concept est donné à titre indicatif"
# print(xtable(extraction,caption = titre), include.rownames = F)

##
map1 <- subset (map1, !bool_non_valide)

### les acides : 
## on enlève les terminaisons par e
to_map2$dci2 <- gsub ("(e )|e$"," ",to_map2$dci)
to_map2$dci2 <- gsub ("iqu $","ic",to_map2$dci2)

## modifications manuelles : 
modif_manuel_map2 <- function(regex, transformation){
  bool <- grepl(regex,to_map2$dci, ignore.case = T) | grepl(regex,to_map2$dci2, ignore.case = T)
  print (to_map2$dci[bool])
  to_map2$dci2[bool] <- transformation
  return (to_map2)
}

modif_manuel_map2_remplacer <- function(regex, transformation){
  bool <- grepl(regex,to_map2$dci,ignore.case = T) | grepl(regex,to_map2$dci2,ignore.case = T)
  print (to_map2$dci[bool])
  to_map2$dci2[bool] <- gsub(regex, transformation,to_map2$dci2[bool])
  return (to_map2)
}

to_map2 <- modif_manuel_map2("gallium", "citrate gallium")
to_map2 <- modif_manuel_map2("Abciximab", "Abciximab")
to_map2 <- modif_manuel_map2("Alteplase", "Alteplase")
to_map2 <- modif_manuel_map2("Benethamine", "Benethamine penicillin")
to_map2 <- modif_manuel_map2("methylene", "methylene blue")
to_map2 <- modif_manuel_map2("Canrenoate", "Canrenoate Potassium")
to_map2 <- modif_manuel_map2("sulfoconjugues", "Estrogens Conjugated")
to_map2 <- modif_manuel_map2("Fampridines", "Fampridine")
to_map2 <- modif_manuel_map2("Cafeine", "Caffeine")
to_map2 <- modif_manuel_map2("Charbon", "Charcoal")
to_map2 <- modif_manuel_map2("^Or", "Gold")
to_map2 <- modif_manuel_map2("Kaolin", "Kaolin")
to_map2 <- modif_manuel_map2_remplacer("calcic", "calcium")
to_map2 <- modif_manuel_map2_remplacer("humain", "human")
to_map2 <- modif_manuel_map2_remplacer("sodic", "sodium")
to_map2 <- modif_manuel_map2("Reglisse", "licorice")
to_map2 <- modif_manuel_map2("Sodium \\(citrate de\\)", "citrate sodium")
to_map2 <- modif_manuel_map2("Sodium \\(citrat diacid de\\)", "sodium acid citrate")
to_map2 <- modif_manuel_map2("picosulfate", "sodium picosulfate")
to_map2 <- modif_manuel_map2("ricinoleate", "sodium ricinoleate")
to_map2 <- modif_manuel_map2("jaune", "Live Attenuated Yellow Fever Virus Vaccine [EPC]")
to_map2 <- modif_manuel_map2("rougeol", "MEASLES VIRUS VACCINE,LIVE ATTENUATED")
to_map2 <- modif_manuel_map2("rubeol", "Live Attenuated Rubella Virus Vaccine")
to_map2 <- modif_manuel_map2("grippe", "Live Attenuated Influenza A Virus Vaccine")
to_map2 <- modif_manuel_map2("Mycophenolate", "mycophenolate sodium")
to_map2 <- modif_manuel_map2("Mycophenolate", "mycophenolate sodium")
to_map2 <- modif_manuel_map2("Povidone iodee", "Povidone-Iodine")
to_map2 <- modif_manuel_map2("aurothiopropanol", "sodium aurothiopropanol sulfonate")
to_map2 <- modif_manuel_map2("lapin", "antithymocyte immunoglobulin (rabbit)")
to_map2 <- modif_manuel_map2("equines", "thymocyte immunoglobulin equine")
to_map2 <- modif_manuel_map2("Magnesium \\(hydroxyde de\\)", "Magnesium Hydroxide")
to_map2 <- modif_manuel_map2("Magnesium \\(trisilicate de\\)", "Magnesium trisilicate")
to_map2 <- modif_manuel_map2("Esclicarbazepin", "Eslicarbazepine")
to_map2 <- modif_manuel_map2("DIPHENHYDRAMINE", "DIPHENHYDRAMINE DIACEFYLLINATE")
to_map2 <- modif_manuel_map2("sulfafurazol", "sulfafurazol")
to_map2 <- modif_manuel_map2("arsenieux", "trioxide arsenic")
to_map2 <- modif_manuel_map2("catioresine", "polystyrene sulfonate")
to_map2 <- modif_manuel_map2("trimagnesien", "magnesium citrate")
to_map2 <- modif_manuel_map2("Insulin human", "Regular Insulin Human")
to_map2 <- modif_manuel_map2("Insulin aspart", "Biphasic insulin aspart")
to_map2 <- modif_manuel_map2("Liothyronin sodium", "Liothyronine sodium")
to_map2 <- modif_manuel_map2("Inde", "Senna alexandrina")
to_map2 <- modif_manuel_map2("khartoum", "Senna alexandrina")
to_map2 <- modif_manuel_map2("Thyroxines", "Thyroxine")
to_map2 <- modif_manuel_map2("Botuli", "Botulinum Toxins")
to_map2 <- modif_manuel_map2("Racemi", "RACEMENTHOL")
to_map2 <- modif_manuel_map2("gel d'hydroxy", "hydroxide aluminium")
to_map2 <- modif_manuel_map2("p a s sodique", "acid aminosalicylic")
to_map2 <- modif_manuel_map2("varicelle", "Varicella-zoster vaccine")



## ajout de l'alcool et du jus de pamplemousse :
alignement_sup <- c(unique(to_map2$dci2),c("grapefruit food","ethanol","latex condom"))
writeLines(alignement_sup,"dci_umls2.txt")

## Lancer le programme JAVA pour aligner vers l'UMLS "dci_umls2.txt"
# normalement on devrait avoir tout: 
map2 <- read.table("dci_umls2_mapping.txt",sep="\t",fill=T, quote="", stringsAsFactors = F)
colnames(map2) <- c("dci","code_atome","termino","lib_atome","CUI","lib_CUI")
bool <- map2$code_atome == " non trouvé"
sum(bool)
voir <- subset (map2, bool)

##  Heparin sodique/iodur d sodium => heparine sodique deja present

## fusionner map2 et to_map2 : 
to_map2 <- subset (to_map2, select=c("dci","dci2"))
## ajout :
ajout <- data.frame(dci = c("jus de pamplemousse","alcool","préservatifs en latex"),
                    dci2=c("grapefruit food","ethanol","latex condom"))
to_map2 <- rbind (to_map2, ajout)
colnames(map2)[1] <- "dci2"
colnames(map2)
map3 <- merge (map2, to_map2, by="dci2")

library(plyr)
map <- rbind.fill (map1, map3)
bool <- map$CUI == ""
sum(bool)

## 2 n'ont pas de map
voir <- subset (map,bool)
map <- subset (map, !bool)

#write.table(map, "1100versUMLS.csv",sep="\t", col.names=T, row.names = F)
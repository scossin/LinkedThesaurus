# library(devtools)
# devtools::install_github("scossin/IMthesaurusANSM")

library(IMthesaurusANSM)
source("ThesaurusToRDF_POO.R")
## modifier le prefixe directement dans le fichier
source("prefixe.R")
# thesaurus2016 : a remplacé par la version souhaitée
test <- new(Class="ThesaurusToRDF",thesaurus = thesaurus2016, 
            dossier_ttl = "triplets", prefixe = prefixe)

test$create_fichier_familles()
test$create_fichier_molecules()
test$create_fichier_ddi()
test$create_fichier_contient()
test$create_fichier_participe()
test$create_fichier_enumerated()
test$Hermit_subclassof()
test$create_contient_hermitoutputsubclassof()

## concat les fichiers : 
list.files("triplets/")
fichiers <- c("ontologyInteractionSans.owl","familles.ttl","molecules.ttl","contient.ttl","DDI.ttl",
              "participe.ttl","contient_subclassof.ttl")
temp <- c()
for (i in fichiers){
  i<-paste (test$dossier_ttl, i, sep="/")
  ajout <- readLines(i)
  print (length(ajout))
  temp <- append(temp, ajout)
}
length(temp)
writeLines(temp, paste(test$dossier_ttl,"/thesaurus2016.owl",sep=""))
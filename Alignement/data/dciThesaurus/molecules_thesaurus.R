### creer un fichier txt des molécules du thésaurus
library(test)
MOL <- c(thesaurus$thesaurus2016$mol_famille_2016$molecule,
         thesaurus$thesaurus2016$molecules_seules_2016$molecule)
MOL <- unique(MOL)
MOL <- tolower(MOL)
writeLines(MOL,"dci_thesaurus.txt")



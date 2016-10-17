rm(list=ls())
library(test)
mol_familles <- mol_famille_2013
mol_seules <- molecules_seules_2013
#mol_familles <- read.table("/home/cossin/DP/Donnees_ANSM/Interaction/output/062015/mol_famille_thesaurus.csv",sep="\t",header=T)
#mol_seules <- read.table("/home/cossin/DP/Donnees_ANSM/Interaction/output/062015/mol_thesaurus_seules.csv",sep="\t",header=T)
dci <- as.character(unique(c(mol_familles$molecule, mol_seules$molecule)))
dci <- retirer_accent(dci)
dci <- retirer_espace(dci)
dci <- tolower(dci)

writeLines(dci, "csv/dci2013.txt")

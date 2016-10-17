setRefClass(
  # Nom de la classe
  "ThesaurusToRDF",
  # Attributs
  fields =  c(
    ### un objet de type thesaurus
    thesaurus = "ANY",
    tab_interaction = "data.frame",
    familles = "data.frame",
    molecules="data.frame",
    
    ### Pour les identifiants : 
    longueur_x_max = "numeric",
    longueur_hash = "numeric",
    
    ### dossier où sera stocké les fichiers au format ttl : 
    dossier_ttl = "character",
    
    ### prefix : 
    prefixe="character"
  ),
  
  # Fonctions :
  methods=list(
    ### Constructeur
    initialize = function(thesaurus, dossier_ttl, prefixe, 
                          longueur_x_max = 100, longueur_hash = 2){
      if (class(thesaurus) != "Thesaurus"){
        stop("thesaurus doit être de classe Thesaurus")
      }
      
      ## pour charger la fonction
      md5_5("test",longueur_x_max = 100, longueur_hash = 2)
      ###
      thesaurus <<- thesaurus
      tab_interaction <<- thesaurus$df
      familles <<- thesaurus$mol_famille
      molecules <<- thesaurus$molecules_seules
      ## interaction
      colnames(tab_interaction)[1:2] <<- c("protagoniste1","protagoniste2")
      colonnes_tab_interaction <- c("protagoniste1","protagoniste2","mecanisme")
      check_colonnes (tab_interaction, colonnes_tab_interaction)
      temp <- add_id_df(tab_interaction,colonnes_tab_interaction,longueur_x_max,longueur_hash)
      temp$id_interaction <- paste(temp$id_protagoniste1, temp$id_protagoniste2, sep="_")
      tab_interaction <<- temp
      tab_interaction$niveau <<- ifelse (!is.na(tab_interaction$PC),"PC",
                                         ifelse (!is.na(tab_interaction$PE),"PE",
                                                 ifelse(!is.na(tab_interaction$AD),"AD","CI")))
      
      ## famille
      colonnes_famille <- c("molecule","famille")
      check_colonnes (familles, colonnes_famille)
      familles <<- add_id_df(familles,colonnes_famille,longueur_x_max,longueur_hash)
      bool <- familles$famille == ""
      familles <<- subset (familles, !bool)
      
      ## molecule
      colonnes_molecule <- c("molecule")
      check_colonnes (molecules, colonnes_molecule)
      molecules <<- add_id_df(molecules,colonnes_molecule,longueur_x_max,longueur_hash)
      molecules$famille <<- NULL
      
      if (!dir.exists(dossier_ttl)){
        stop("le dossier ", dossier_ttl, " n'existe pas")
      } else {
        dossier_ttl <<- dossier_ttl
      }
      
      prefixe <<- prefixe
    },
    
    ################ Fonctions utilisées par le constructeur #####################
    check_colonnes = function(df, vecteur_colonnes){
      if (all(vecteur_colonnes %in% colnames(df))){
        return (T)
      } else {
        stop("Les colonnes de ", deparse(substitute(df)), "doivent contenir les colonnes suivantes :", vecteur_colonnes)
      }
    },
    #### ajouter un identifiant aux colonnes
    add_id_df = function(df, nom_colonnes,longueur_x_max,longueur_hash){
      for (i in nom_colonnes){
        num_colonne <- which(colnames(df) %in% i)
        temp <- as.character(df[,num_colonne])
        df[,length(df)+1] <- ifelse (is.na(df[,num_colonne]) | df[,num_colonne] == "", NA, 
                                     sapply(temp, md5_5, longueur_x_max,longueur_hash))
        colnames(df)[length(df)] <- paste ("id_",i,sep="")
      }
      return(df)
    },
    
    
    ##################### fonctions pour créer les fichiers à charger
    create_fichier_contient = function(){
      assertion <- paste (":",familles$id_famille, " :contient ", ":",familles$id_molecule, " .", sep="")
      assertion <- transforme_ajout(assertion, "RELATION CONTIENT")
      nom_fichier <- "contient.ttl"
      writeLines(assertion, paste(dossier_ttl, "/",nom_fichier,sep=""))
      cat ("fichier", nom_fichier, "créé avec succès \n")
      return(T)
    },
    
    ## relation participe : 
    create_fichier_participe = function(){
      assertion1 <- paste (":", tab_interaction$id_protagoniste1, " :participe1", " :",tab_interaction$id_interaction,".",sep="")
      assertion2 <- paste (":", tab_interaction$id_protagoniste2, " :participe2", " :",tab_interaction$id_interaction,".",sep="")
      assertion <- transforme_ajout(c(assertion1,assertion2), "RELATION PARTICIPE")
      nom_fichier <- "participe.ttl"
      writeLines(assertion, paste(dossier_ttl, "/",nom_fichier,sep=""))
      cat ("fichier", nom_fichier, "créé avec succès \n")
      return(T)
    },
    
    create_fichier_familles = function(){
      familles2 <- subset (familles, select=c("id_famille","famille"))
      familles2 <- unique(familles2)
      ## nom de la classe différent du nom de l'individu : 
      #nom_classe <- paste (":",familles2$id_famille,"CLASS",sep="")
      nom_classe <- paste (":",familles2$id_famille,sep="")
      #classe_famille <- ":Familles a owl:Class ."
      assertion <- paste (":",familles2$id_famille, " a owl:NamedIndividual , ", nom_classe, ", :Familles;
                          rdfs:label ", "\"", familles2$famille, "\" .", sep="")
      assertion <- paste (":",familles2$id_famille, " a owl:NamedIndividual , :Familles;
                          rdfs:label ", "\"", familles2$famille, "\" .", sep="")
      #assertion <- paste (classe_famille, assertion, sep="\n")
      assertion <- transforme_ajout(assertion, "FAMILLES")
      nom_fichier <- "familles.ttl"
      writeLines(assertion, paste(dossier_ttl, "/",nom_fichier,sep=""))
      cat ("fichier", nom_fichier, "créé avec succès \n")
      return (T)
    },
    
    create_fichier_molecules = function(MOL){
      familles2 <- subset (familles, select=c("id_molecule","molecule"))
      familles2 <- unique(familles2)
      molecules2 <- rbind (molecules, familles2)
      #classe_molecules <- ":Molecules a owl:Class ."
      assertion <- paste (":",molecules2$id_molecule, " a owl:NamedIndividual , :Molecules;
                          rdfs:label ", "\"", molecules2$molecule, "\" .", sep="")
      #assertion <- paste (classe_molecules, assertion, sep="\n")
      assertion <- transforme_ajout(assertion, "MOLECULES")
      nom_fichier <- "molecules.ttl"
      writeLines(assertion, paste(dossier_ttl, "/",nom_fichier,sep=""))
      cat ("fichier", nom_fichier, "créé avec succès \n")
      return (T)
    },
    
    create_fichier_ddi = function(){
      #classe_ddi <- ":DDI a owl:Class ."
      label_mecanisme <- gsub("\"","",tab_interaction$mecanisme)
      label_description <- gsub("\"","",tab_interaction$description_interaction)
      label_interaction <- paste (tab_interaction$protagoniste1, " interagit avec ", tab_interaction$protagoniste2,sep="")
      assertion <- paste (":",tab_interaction$id_interaction," a owl:NamedIndividual , :DDI;
                          rdfs:label ", "\"", label_interaction, "\";
                          :niveau ", "\"", tab_interaction$niveau, "\";
                          :mecanisme ", "\"", label_mecanisme, "\";
                          :description ", "\"", label_description, "\" .", sep="")
      #assertion <- paste (classe_ddi, assertion, sep="\n")
      assertion <- transforme_ajout(assertion, "DDI")
      nom_fichier <- "DDI.ttl"
      writeLines(assertion, paste(dossier_ttl, "/",nom_fichier,sep=""))
      cat ("fichier", nom_fichier, "créé avec succès \n")
    },
    
    create_fichier_enumerated =function(x){
      temp <- NULL
      familles$id_molecule <<- as.character(familles$id_molecule)
      familles$id_famille <<- as.character(familles$id_famille)
      liste_famille <- unique(familles$id_famille)

      for (i in liste_famille){
        ## l'individu n'a pas le meme IRI que la classe :
        #y <- paste (i,"CLASS ",sep="")
        listes_id_molecule <- paste (":",familles$id_molecule[familles$id_famille == i],sep="")
        listes_id_molecule <- paste(listes_id_molecule, collapse="\n")
        assertion <- paste(":",i," rdf:type owl:Class ;
                           owl:equivalentClass [ rdf:type owl:Class ;
                           owl:oneOf (", listes_id_molecule,")];
                           rdfs:subClassOf :Familles .",sep="")
        temp <- append (temp, assertion)
      }
      assertion <- transforme_ajout(temp, "ENUMERATED CLASSE")
      nom_fichier <- "enumerated.txt"
      writeLines(assertion, paste(dossier_ttl, "/",nom_fichier,sep=""))
      cat ("fichier", nom_fichier, "créé avec succès \n")
    },
    
    Hermit_subclassof = function(){
      if (!file.exists(paste(dossier_ttl, "/HermiT.jar",sep=""))){
        stop("fichier HermiT.jar non trouvé")
      }
      if (!file.exists(paste(dossier_ttl, "/enumerated.txt",sep=""))){
        stop("fichier enumerated.txt non trouvé")
      }
      cat ("lancement de Hermit pour créer les subclassof \n")
      commande_Hermit <- paste(
        "java -jar ", dossier_ttl, 
        "/HermiT.jar -c -o ", dossier_ttl, "/hermitoutputsubclassof.txt ", 
        dossier_ttl, "/enumerated.txt",sep="")
      cat (commande_Hermit, "\n")
      system(commande_Hermit)
      cat ("fichier output créé avec succès \n")
    },
    
    create_contient_hermitoutputsubclassof = function(){
      fichier_output <- paste(dossier_ttl, "/hermitoutputsubclassof.txt",sep="")
      if (!file.exists(fichier_output)){
        stop(fichier_output, " non trouvé")
      }
      resultat<- readLines(fichier_output)
      dat1 <- data.frame(do.call(rbind, strsplit(resultat, split = " ")))
      dat1$X4 <- NULL
      dat1$X2 <- gsub("<http://thesaurus#|rdf>|>","",dat1$X2)
      dat1$X3 <- gsub("<http://thesaurus#|rdf>|>","",dat1$X3)
      dat1 <- subset (dat1, X1 == "SubClassOf(")
      dat1$X1 <- NULL
      dat1 <- subset (dat1, X3 != "Familles")
      assertion <- paste (":",dat1$X2, " rdfs:subClassOf ", ":",dat1$X3, " .",sep="")
      ## change subclassof par contient :
      assertion <- paste (":",dat1$X2, " :appartient ", ":",dat1$X3, " .",sep="")
      assertion <- transforme_ajout(assertion, "SUBCLASS OF INFERED")
      nom_fichier <- "contient_subclassof.ttl"
      writeLines(assertion, paste(dossier_ttl, "/",nom_fichier,sep=""))
      cat ("fichier", nom_fichier, "créé avec succès \n")
    },
    
    transforme_ajout= function(ajout, titre){
      ajout <- paste (ajout, collapse="\n")  
      ajout <- paste (prefixe,"
# #################################################################
# #
# #   ",    titre,"
# #
# #################################################################
", ajout , sep="")
      return(ajout)
    },
    
    ### pour créer des les identifiants
    md5_5 = function(x, longueur_x_max, longueur_hash){
      library(digest)
      x <- as.character(x)
      md5 <- substr(digest(object = x,algo = "md5",serialize = F),1,longueur_hash)
      x <- gsub("[^[:alnum:]]", "",x)
      bool <- nchar(x) > longueur_x_max
      x <- ifelse (bool, substr(x, 1, longueur_x_max), x)
      x <- paste (x, md5, sep="")
      return(x)
    }
    )
  )
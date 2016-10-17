package versDB;

import java.io.IOException;

import gov.nih.nlm.uts.webservice.UtsFault_Exception;
import versUMLS.UMLSAPI;

// Cette classe permet de récupérer une liste de synonymes UMLS à partir d'une liste de CUI
// CUI correspondants aux concepts dans le thesaurus

public class RetrieveSynonyms {

	public static void main(String[] args) throws UtsFault_Exception, IOException {
		// TODO Auto-generated method stub
		
		UMLSAPI umls = new UMLSAPI();
		umls.ticket();
		
		// contient la liste des CUI des dci du thésaurus
		String fichier_CUI = "data/versDB/dci_CUI.txt" ;
		// fichier de sortie
		String fichier_synonymes = "data/versDB/dci_CUI_termes.txt";
		umls.synonymesCUI_file(fichier_CUI, fichier_synonymes);
	}

}

package versUMLS;

import java.io.IOException;

import gov.nih.nlm.uts.webservice.UtsFault_Exception;

// Cette classe a pour but de rechercher les codes RxNorm à partir de concepts UMLS
// Notamment pour rattacher un terme du thesaurus à un code RxNorm

public class SearchRxNormCode {

	public static void main(String[] args) throws UtsFault_Exception, IOException {
		// TODO Auto-generated method stub
		UMLSAPI umls = new UMLSAPI();
		umls.ticket();
		
		// récupère les codes RxNorm des concepts trouvés 
		String fichier_CUI = "data/versUMLS/CUI.txt";
		String fichier_sortie = "data/versUMLS/dci_CUI_RxNorm.txt";
		umls.search_RxNorm_file(fichier_CUI, fichier_sortie);	
	}

}

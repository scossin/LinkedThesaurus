package versUMLS;

import java.io.IOException;

import gov.nih.nlm.uts.webservice.UtsFault_Exception;


// Cette classe a pour but de trouver les concepts UMLS attachés aux termes du thesaurus des interactions de l'ANSM 
// Alignement du thésaurus des interactions médicamenteuses de l'ANSM vers l'UMLS

public class ThesaurusToUMLS {

	public static void main(String[] args) throws UtsFault_Exception, IOException {
		UMLSAPI umls = new UMLSAPI();
		umls.ticket();
		
		// premier fichier
		String fichier_dci = "data/dciThesaurus/dci_thesaurus.txt";
		String fichier_dci_mapper ="data/versUMLS/dci_thesaurus_to_umls.txt";
		umls.search_concept_file(fichier_dci, fichier_dci_mapper);
		
		// deuxième fichier : les non trouvés et non exact sont checkés dans le programme R et modifiés pour permettre l'alignement
		String fichier_dci2 = "data/versUMLS/dci_umls2.txt";
		String fichier_dci_mapper2 ="data/versUMLS/dci_umls2_mapping.txt";
		umls.search_concept_file(fichier_dci2, fichier_dci_mapper2);
		
	}
}

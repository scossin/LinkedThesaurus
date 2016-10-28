package versANSM;

import java.io.IOException;

import versDB.Alignement_drugs;

public class thesaurustoSubstances {

	/*
	 * Cette classe recherche les libellés du thésaurus dans l'index des substances
	 */
	
	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		
		// Etape 1 : Alignement automatique et semi-automatique
		String moleculesthesaurus = "data/dciThesaurus/moleculesthesaurus.txt";
		String fichierOutput = "data/versANSM/substancesANSM/moleculesthesaurus_proposition.txt";
		
		Alignement_drugs alignement = new Alignement_drugs(moleculesthesaurus, fichierOutput, "Index_Substances");
		alignement.set_alignement();
		//alignement.writeProposition();
		
		// Etape 2 : validation manuelle
		moleculesthesaurus = "data/versANSM/substancesANSM/moleculesthesaurus_non_trouve.txt";
		fichierOutput = "data/versANSM/manu/non_trouve_proposition.txt";
		alignement = new Alignement_drugs(moleculesthesaurus, fichierOutput, "Index_Substances");
		alignement.set_alignement();
		//alignement.writeProposition();
		
		// Etape 3 : plus haut, j'ai matché 1 à 1, je recherche maintenant des relations 1 à N
		moleculesthesaurus = "data/versANSM/manuSuite/dcithesaurusSuite.txt";
		fichierOutput = "data/versANSM/manuSuite/dcithesaurusSuitePropositions.txt";
		alignement = new Alignement_drugs(moleculesthesaurus, fichierOutput, "Index_Substances");
		alignement.set_alignement_dci(10);
		alignement.writeProposition();
	}

}

package versANSM;

import java.io.IOException;

import versDB.Alignement_drugs;

public class thesaurustoSubstances {

	/*
	 * Cette classe recherche les libellés du thésaurus dans l'index des substances
	 */
	
	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		
		
		String moleculesthesaurus = "data/dciThesaurus/moleculesthesaurus.txt";
		String proposition = "data/versANSM/moleculesthesaurus_proposition.txt";
		
		Alignement_drugs alignement = new Alignement_drugs(moleculesthesaurus, proposition, "Index_Substances", null);
		alignement.set_alignement();
		//alignement.writeProposition();
		
		// deuxieme tentative : modification des libelles
		moleculesthesaurus = "data/versANSM/non_trouve.txt";
		proposition = "data/versANSM/non_trouve_proposition.txt";
		alignement = new Alignement_drugs(moleculesthesaurus, proposition, "Index_Substances", null);
		alignement.set_alignement();
		//alignement.writeProposition();
	}

}
